import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/entities/location_entity.dart';
import '../../domain/usecases/get_current_location_usecase.dart';

enum LocationStatus { initial, loading, success, error }

class LocationState {
  final LocationStatus status;
  final LocationEntity? location;
  final String? errorMessage;

  const LocationState({
    this.status = LocationStatus.initial,
    this.location,
    this.errorMessage,
  });

  LocationState copyWith({
    LocationStatus? status,
    LocationEntity? location,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class LocationBloc extends ChangeNotifier {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;

  LocationState _state = const LocationState();
  LocationState get state => _state;
  bool _inProgress = false;
  bool _isManualOverride = false;
  StreamSubscription<Position>? _positionSub;
  bool get isManualOverride => _isManualOverride;

  LocationBloc(this._getCurrentLocationUseCase);

  Future<void> getCurrentLocation({bool force = false}) async {
    if (_isManualOverride && !force) return;
    if (_inProgress) return;
    _inProgress = true;
    _state = _state.copyWith(
      status: LocationStatus.loading,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final location = await _getCurrentLocationUseCase();
      _state = _state.copyWith(
        status: LocationStatus.success,
        location: location,
        clearErrorMessage: true,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      );
    }

    notifyListeners();
    _inProgress = false;
  }

  void setManualLocation(LocationEntity location) {
    _isManualOverride = true;
    _state = _state.copyWith(
      status: LocationStatus.success,
      location: location,
      clearErrorMessage: true,
    );
    notifyListeners();
  }

  void clearManualOverride({bool refreshFromDevice = true}) {
    _isManualOverride = false;
    if (refreshFromDevice) {
      getCurrentLocation(force: true);
    } else {
      notifyListeners();
    }
  }

  void startAutoUpdate() {
    if (_positionSub != null) return;
    final settings = const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 50,
    );
    _positionSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((_) {
          getCurrentLocation();
        }, onError: (_) {});
  }

  void stopAutoUpdate() {
    _positionSub?.cancel();
    _positionSub = null;
  }

  void resetState() {
    _isManualOverride = false;
    _state = const LocationState();
    notifyListeners();
  }
}
