import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location_usecase.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';

// Simple service locator
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  final Map<Type, dynamic> _services = {};

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception('Service of type $T not found');
    }
    return service as T;
  }

  void register<T>(T service) {
    _services[T] = service;
  }
}

final sl = ServiceLocator();

Future<void> initDependencies() async {
  // Location
  sl.register<LocationRepository>(LocationRepositoryImpl());
  sl.register<GetCurrentLocationUseCase>(GetCurrentLocationUseCase(sl.get()));
  sl.register<LocationBloc>(LocationBloc(sl.get()));
}
