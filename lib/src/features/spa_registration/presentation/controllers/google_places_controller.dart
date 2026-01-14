import 'dart:async';
import '../../../../core/services/google_places_service.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class GooglePlacesController extends ChangeNotifier {
  final GooglePlacesService service;
  final double? Function()? biasLatProvider;
  final double? Function()? biasLngProvider;
  GooglePlacesController({
    required this.service,
    this.biasLatProvider,
    this.biasLngProvider,
  });

  final List<PlaceSuggestion> suggestions = [];
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;
  String _lastQuery = '';
  String? _sessionToken;

  void onQueryChanged(String q) {
    _lastQuery = q;
    _debounce?.cancel();
    if (q.trim().length < 3) {
      suggestions.clear();
      errorMessage = null;
      notifyListeners();
      return;
    }
    _sessionToken ??= const Uuid().v4();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _fetchSuggestions(q.trim());
    });
  }

  Future<void> _fetchSuggestions(String q) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final lat = biasLatProvider?.call();
      final lng = biasLngProvider?.call();
      final establishments = await service.autocomplete(
        q,
        sessionToken: _sessionToken,
        type: 'establishment',
        lat: lat,
        lng: lng,
      );
      final addresses = await service.autocomplete(
        q,
        sessionToken: _sessionToken,
        type: 'address',
        lat: lat,
        lng: lng,
      );
      final merged = <String, PlaceSuggestion>{};
      for (final s in [...establishments, ...addresses]) {
        merged[s.placeId] = s;
      }
      suggestions
        ..clear()
        ..addAll(merged.values.toList());
      if (suggestions.isEmpty) {
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

  Future<PlaceDetails> selectSuggestion(PlaceSuggestion s) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final details = await service.getPlaceDetails(s.placeId);
      suggestions.clear();
      _sessionToken = null;
      isLoading = false;
      notifyListeners();
      return details;
    } catch (e) {
      isLoading = false;
      errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
