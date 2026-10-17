import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopsphere/core/connectivity/connectivity_cubit.dart';
import 'package:shopsphere/core/network/api_client.dart';
import 'package:shopsphere/core/network/auth_interceptor.dart';
import 'package:shopsphere/core/network/dio_factory.dart';
import 'package:shopsphere/core/network/network_info.dart';
import 'package:shopsphere/core/session/session_events.dart';
import 'package:shopsphere/core/storage/key_value_store.dart';
import 'package:shopsphere/core/storage/token_storage.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:shopsphere/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:shopsphere/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shopsphere/features/auth/domain/repositories/auth_repository.dart';
import 'package:shopsphere/features/auth/domain/usecases/login_user.dart';
import 'package:shopsphere/features/auth/domain/usecases/session_usecases.dart';
import 'package:shopsphere/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:shopsphere/features/auth/presentation/cubit/login_cubit.dart';
import 'package:shopsphere/features/cart/data/datasources/cart_data_sources.dart';
import 'package:shopsphere/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:shopsphere/features/cart/domain/repositories/cart_repository.dart';
import 'package:shopsphere/features/cart/domain/usecases/cart_usecases.dart';
import 'package:shopsphere/features/cart/presentation/cubit/cart_cubit.dart';
import 'package:shopsphere/features/diagnostics/data/repositories/diagnostics_repository_impl.dart';
import 'package:shopsphere/features/diagnostics/domain/repositories/diagnostics_repository.dart';
import 'package:shopsphere/features/diagnostics/presentation/cubit/error_lab_cubit.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';
import 'package:shopsphere/features/products/domain/repositories/product_repository.dart';
import 'package:shopsphere/features/products/domain/usecases/product_usecases.dart';
import 'package:shopsphere/features/products/presentation/bloc/products_bloc.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_details_cubit.dart';
import 'package:shopsphere/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:shopsphere/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:shopsphere/features/settings/domain/repositories/settings_repository.dart';
import 'package:shopsphere/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:shopsphere/features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'package:shopsphere/features/wishlist/domain/repositories/wishlist_repository.dart';
import 'package:shopsphere/features/wishlist/presentation/cubit/wishlist_cubit.dart';

/// The service locator. Only this file and route builders read from it;
/// widgets and blocs receive their dependencies through constructors.
final GetIt sl = GetIt.instance;

Future<void> configureDependencies() async {
  final prefs = await SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(),
  );

  // Core
  sl
    ..registerSingleton<KeyValueStore>(SharedPreferencesStore(prefs))
    ..registerSingleton<TokenStorage>(
      const SecureTokenStorage(FlutterSecureStorage()),
    )
    ..registerSingleton<SessionEvents>(SessionEvents())
    ..registerLazySingleton<NetworkInfo>(
      () => ConnectivityNetworkInfo(Connectivity()),
    )
    ..registerLazySingleton<ApiClient>(() {
      // Plain client for token refresh + retry (no auth interceptor).
      final refreshClient = createDio();
      return ApiClient(
        createDio(interceptors: [AuthInterceptor(sl(), sl(), refreshClient)]),
      );
    });

  // Data sources
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(sl(), sl()),
    )
    ..registerLazySingleton<ProductRemoteDataSource>(
      () => ProductRemoteDataSourceImpl(sl()),
    )
    ..registerLazySingleton<ProductLocalDataSource>(
      () => ProductLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CartLocalDataSource>(
      () => CartLocalDataSourceImpl(sl()),
    )
    ..registerLazySingleton<CartRemoteDataSource>(
      () => CartRemoteDataSourceImpl(sl()),
    );

  // Repositories
  sl
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl(), sl()),
    )
    ..registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<CartRepository>(
      () => CartRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton<WishlistRepositoryImpl>(
      () => WishlistRepositoryImpl(sl()),
    )
    ..registerLazySingleton<WishlistRepository>(sl.get<WishlistRepositoryImpl>)
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(sl()),
    )
    ..registerLazySingleton<DiagnosticsRepository>(
      () => DiagnosticsRepositoryImpl(sl(), sl()),
    );

  // Use cases
  sl
    ..registerFactory(() => LoginUser(sl()))
    ..registerFactory(() => GetStoredUser(sl()))
    ..registerFactory(() => GetCurrentUser(sl()))
    ..registerFactory(() => WatchSessionExpired(sl()))
    ..registerFactory(
      () => LogoutUser(sl(), [
        sl<CartLocalDataSource>(),
        sl<WishlistRepositoryImpl>(),
        sl<ProductLocalDataSource>(),
      ]),
    )
    ..registerFactory(() => GetProducts(sl()))
    ..registerFactory(() => GetCategories(sl()))
    ..registerFactory(() => GetProductDetails(sl()))
    ..registerFactory(() => LoadCart(sl()))
    ..registerFactory(() => SaveCart(sl()))
    ..registerFactory(CalculateCartSummary.new)
    ..registerFactory(() => PlaceOrder(sl()));

  // State holders
  sl
    ..registerLazySingleton(() => AuthCubit(sl(), sl(), sl(), sl()))
    ..registerLazySingleton(() => SettingsCubit(sl()))
    ..registerLazySingleton(() => ConnectivityCubit(sl()))
    ..registerFactory(() => LoginCubit(sl()))
    ..registerFactory(() => ProductsBloc(sl(), sl()))
    ..registerFactoryParam<ProductDetailsCubit, int, void>(
      (id, _) => ProductDetailsCubit(sl(), id),
    )
    ..registerFactory(() => CartCubit(sl(), sl(), sl(), sl()))
    ..registerFactory(() => WishlistCubit(sl()))
    ..registerFactory(() => ProfileCubit(sl()))
    ..registerFactory(() => ErrorLabCubit(sl()));
}
