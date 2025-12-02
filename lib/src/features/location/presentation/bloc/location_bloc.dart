import 'package:flutter/foundation.dart';
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
  }) {
    return LocationState(
      status: status ?? this.status,
      location: location ?? this.location,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class LocationBloc extends ChangeNotifier {
  final GetCurrentLocationUseCase _getCurrentLocationUseCase;
  
  LocationState _state = const LocationState();
  LocationState get state => _state;

  LocationBloc(this._getCurrentLocationUseCase);

  Future<void> getCurrentLocation() async {
    _state = _state.copyWith(status: LocationStatus.loading);
    notifyListeners();

    try {
      final location = await _getCurrentLocationUseCase();
      _state = _state.copyWith(
        status: LocationStatus.success,
        location: location,
      );
    } catch (e) {
      _state = _state.copyWith(
        status: LocationStatus.error,
        errorMessage: e.toString(),
      );
    }
    
    notifyListeners();
  }

  void resetState() {
    _state = const LocationState();
    notifyListeners();
  }
}