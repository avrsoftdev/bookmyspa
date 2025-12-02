import '../entities/location_entity.dart';
import '../repositories/location_repository.dart';

class GetCurrentLocationUseCase {
  final LocationRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  Future<LocationEntity?> call() async {
    // Check if location service is enabled
    final isServiceEnabled = await _repository.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      throw Exception('Location services are disabled');
    }

    // Request permission
    final hasPermission = await _repository.requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Location permission denied');
    }

    // Get current location
    return await _repository.getCurrentLocation();
  }
}