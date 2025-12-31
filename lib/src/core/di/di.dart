import '../../features/location/data/repositories/location_repository_impl.dart';
import '../../features/location/domain/repositories/location_repository.dart';
import '../../features/location/domain/usecases/get_current_location_usecase.dart';
import '../../features/location/presentation/bloc/location_bloc.dart';
import '../../features/auth/data/datasources/google_auth_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/check_auth_status.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/spa_browse/domain/repositories/spa_repository.dart';
import '../../features/spa_browse/data/repositories/spa_repository_impl.dart';
import '../../features/spa_browse/domain/usecases/stream_spas_by_category_usecase.dart';
import '../../features/spa_browse/domain/usecases/stream_spa_by_id_usecase.dart';
import '../../features/spa_browse/domain/usecases/stream_spas_by_owner_usecase.dart';
import '../../features/spa_browse/presentation/controllers/favorites_controller.dart';
import '../../features/cart/presentation/bloc/cart_bloc.dart';
import '../../features/bookings/presentation/controllers/bookings_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/theme_cubit.dart';
import '../theme/locale_cubit.dart';
import '../services/admob_service.dart';

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
  // Auth
  sl.register<GoogleAuthDataSource>(GoogleAuthDataSource());
  sl.register<AuthRepository>(AuthRepositoryImpl(google: sl.get()));
  sl.register<LoginUseCase>(LoginUseCase(sl.get()));
  sl.register<LogoutUseCase>(LogoutUseCase(sl.get()));
  sl.register<CheckAuthStatusUseCase>(CheckAuthStatusUseCase(sl.get()));
  sl.register<AuthController>(
    AuthController(
      loginUseCase: sl.get(),
      logoutUseCase: sl.get(),
      checkAuthStatusUseCase: sl.get(),
    ),
  );

  // Location
  sl.register<LocationRepository>(LocationRepositoryImpl());
  sl.register<GetCurrentLocationUseCase>(GetCurrentLocationUseCase(sl.get()));
  sl.register<LocationBloc>(LocationBloc(sl.get()));

  sl.register<SpaRepository>(SpaRepositoryImpl(FirebaseFirestore.instance));
  sl.register<StreamSpasByCategoryUseCase>(
    StreamSpasByCategoryUseCase(sl.get()),
  );
  sl.register<StreamSpaByIdUseCase>(StreamSpaByIdUseCase(sl.get()));
  sl.register<StreamSpasByOwnerUseCase>(StreamSpasByOwnerUseCase(sl.get()));

  // Favorites
  sl.register<FavoritesController>(
    FavoritesController(
      firestore: FirebaseFirestore.instance,
      authController: sl.get(),
    ),
  );

  // Cart
  sl.register<CartBloc>(CartBloc());

  sl.register<BookingsController>(BookingsController());

  final prefs = await SharedPreferences.getInstance();
  sl.register<SharedPreferences>(prefs);
  final themeCubit = ThemeCubit(prefs);
  await themeCubit.load();
  sl.register<ThemeCubit>(themeCubit);
  final localeCubit = LocaleCubit(prefs);
  await localeCubit.load();
  sl.register<LocaleCubit>(localeCubit);
  sl.register<AdMobService>(AdMobService(FirebaseFirestore.instance));
}
