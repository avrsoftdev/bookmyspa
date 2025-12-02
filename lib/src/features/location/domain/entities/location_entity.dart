class LocationEntity {
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;

  const LocationEntity({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
  });

  @override
  String toString() {
    return 'LocationEntity(lat: $latitude, lng: $longitude, address: $address)';
  }
}