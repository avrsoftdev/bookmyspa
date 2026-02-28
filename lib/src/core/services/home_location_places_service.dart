import 'dart:convert';
import 'dart:io';

import '../../features/location/domain/entities/location_entity.dart';

class HomeLocationSuggestion {
  final String description;
  final String placeId;

  const HomeLocationSuggestion({
    required this.description,
    required this.placeId,
  });
}

class HomeLocationPlacesService {
  final String apiKey;

  HomeLocationPlacesService(this.apiKey);

  Future<List<HomeLocationSuggestion>> autocomplete(
    String input, {
    String? sessionToken,
    double? lat,
    double? lng,
    int radiusMeters = 50000,
  }) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Maps API key is not configured');
    }

    final params = <String>[
      'input=${Uri.encodeComponent(input)}',
      'types=geocode',
      'components=country:in',
      if (sessionToken != null && sessionToken.isNotEmpty)
        'sessiontoken=$sessionToken',
      if (lat != null && lng != null)
        'location=${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}',
      if (lat != null && lng != null) 'radius=$radiusMeters',
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

      return (data['predictions'] as List<dynamic>? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .map(
            (m) => HomeLocationSuggestion(
              description: m['description'] as String? ?? '',
              placeId: m['place_id'] as String? ?? '',
            ),
          )
          .where((s) => s.description.isNotEmpty && s.placeId.isNotEmpty)
          .toList();
    } on SocketException {
      throw Exception('No internet connection');
    } finally {
      client.close(force: true);
    }
  }

  Future<LocationEntity> getPlaceAsLocation(String placeId) async {
    if (apiKey.isEmpty) {
      throw Exception('Google Maps API key is not configured');
    }

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
      '?place_id=$placeId'
      '&fields=formatted_address,geometry,address_components'
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

      String city = '';
      String country = '';
      String countryCode = '';
      final components = result['address_components'] as List<dynamic>? ?? [];
      for (final c in components) {
        final comp = c as Map<String, dynamic>;
        final types = (comp['types'] as List<dynamic>? ?? [])
            .map((e) => e.toString())
            .toSet();
        if (city.isEmpty &&
            (types.contains('locality') ||
                types.contains('administrative_area_level_2') ||
                types.contains('sublocality_level_1'))) {
          city = comp['long_name'] as String? ?? '';
        }
        if (country.isEmpty && types.contains('country')) {
          country = comp['long_name'] as String? ?? '';
          countryCode = comp['short_name'] as String? ?? '';
        }
      }

      if (formatted.isEmpty || lat == null || lng == null) {
        throw Exception('Incomplete place details returned');
      }
      if (country.toLowerCase() != 'india' &&
          countryCode.toUpperCase() != 'IN') {
        throw Exception('Please select a location within India');
      }

      return LocationEntity(
        latitude: lat,
        longitude: lng,
        address: formatted,
        city: city,
        country: country,
      );
    } on SocketException {
      throw Exception('No internet connection');
    } finally {
      client.close(force: true);
    }
  }
}
