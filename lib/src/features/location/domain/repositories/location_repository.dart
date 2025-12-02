import '../entities/location_entity.dart';

abstract class LocationRepository {
  Future<LocationEntity?> getCurrentLocation();
  Future<bool> requestLocationPermission();
  Future<bool> isLocationServiceEnabled();
}