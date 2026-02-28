import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/services/home_location_places_service.dart';

class HomeLocationPickerController extends ChangeNotifier {
  final HomeLocationPlacesService service;
  final double? Function()? biasLatProvider;
  final double? Function()? biasLngProvider;

  HomeLocationPickerController({
    required this.service,
    this.biasLatProvider,
    this.biasLngProvider,
  });

  final List<HomeLocationSuggestion> suggestions = [];
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;
  String? _sessionToken;
  bool suppressNextQuery = false;

  void onQueryChanged(String query) {
    if (suppressNextQuery) {
      suppressNextQuery = false;
      suggestions.clear();
      errorMessage = null;
      notifyListeners();
      return;
    }

    _debounce?.cancel();
    if (query.trim().length < 3) {
      suggestions.clear();
      errorMessage = null;
      notifyListeners();
      return;
    }

    _sessionToken ??= const Uuid().v4();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _fetchSuggestions(query.trim());
    });
  }

  Future<void> _fetchSuggestions(String query) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final lat = biasLatProvider?.call();
      final lng = biasLngProvider?.call();
      final results = await service.autocomplete(
        query,
        sessionToken: _sessionToken,
        lat: lat,
        lng: lng,
      );
      suggestions
        ..clear()
        ..addAll(results);

      if (results.isEmpty) {
        errorMessage = 'No suggestions';
      }
    } catch (e) {
      suggestions.clear();
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void clearSuggestions({bool notify = true}) {
    suggestions.clear();
    errorMessage = null;
    isLoading = false;
    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
