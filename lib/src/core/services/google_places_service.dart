import 'dart:convert';
import 'dart:io';

class PlaceSuggestion {
  final String description;
  final String placeId;
  PlaceSuggestion({required this.description, required this.placeId});
}

class PlaceDetails {
  final String formattedAddress;
  final double lat;
  final double lng;
  PlaceDetails({
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });
}

class GooglePlacesService {
  final String apiKey;
  GooglePlacesService(this.apiKey);

  Future<List<PlaceSuggestion>> autocomplete(
    String input, {
    String? sessionToken,
    String? type,
    double? lat,
    double? lng,
    int radiusMeters = 50000,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Maps API key is not configured');
    }
    final params = <String>[
      'input=${Uri.encodeComponent(input)}',
      'components=country:in',
      if (type != null && type.isNotEmpty) 'types=$type',
      if (sessionToken != null && sessionToken.isNotEmpty)
        'sessiontoken=$sessionToken',
      if (lat != null && lng != null)
        'locationbias=circle:$radiusMeters@${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}',
      'key=$apiKey',
    ].join('&');
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json?$params',
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') {
        throw Exception(data['error_message'] ?? 'Places API error: $status');
      }
      final preds = (data['predictions'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .map(
            (m) => PlaceSuggestion(
              description: m['description'] as String? ?? '',
              placeId: m['place_id'] as String? ?? '',
            ),
          )
          .where((p) => p.description.isNotEmpty && p.placeId.isNotEmpty)
          .toList();
      return preds;
    } on SocketException {
      throw Exception('No internet connection');
    } finally {
      client.close(force: true);
    }
  }

  Future<PlaceDetails> getPlaceDetails(String placeId) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Maps API key is not configured');
    }
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=formatted_address,geometry'
      '&key=$apiKey',
    );
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body) as Map<String, dynamic>;
      final status = data['status'] as String?;
      if (status != 'OK') {
        throw Exception(
          data['error_message'] ?? 'Places Details error: $status',
        );
      }
      final result = data['result'] as Map<String, dynamic>? ?? {};
      final formatted = result['formatted_address'] as String? ?? '';
      final geometry = result['geometry'] as Map<String, dynamic>? ?? {};
      final location = geometry['location'] as Map<String, dynamic>? ?? {};
      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (formatted.isEmpty || lat == null || lng == null) {
        throw Exception('Incomplete place details returned');
      }
      return PlaceDetails(formattedAddress: formatted, lat: lat, lng: lng);
    } on SocketException {
      throw Exception('No internet connection');
    } finally {
      client.close(force: true);
    }
  }
}
