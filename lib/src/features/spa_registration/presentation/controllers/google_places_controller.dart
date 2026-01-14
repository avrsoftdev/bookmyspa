import 'dart:async';
import '../../../../core/services/google_places_service.dart';
import 'package:flutter/foundation.dart';

class GooglePlacesController extends ChangeNotifier {
  final GooglePlacesService service;
  GooglePlacesController({required this.service});

  final List<PlaceSuggestion> suggestions = [];
  bool isLoading = false;
  String? errorMessage;

  Timer? _debounce;
  String _lastQuery = '';

  void onQueryChanged(String q) {
    _lastQuery = q;
    _debounce?.cancel();
    if (q.trim().length < 3) {
      suggestions.clear();
      errorMessage = null;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      await _fetchSuggestions(q.trim());
    });
  }

  Future<void> _fetchSuggestions(String q) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final res = await service.autocomplete(q);
      suggestions
        ..clear()
        ..addAll(res);
      if (res.isEmpty) {
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
