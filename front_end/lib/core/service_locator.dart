import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth/token_storage.dart';
import 'network/dio_client.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/product_cubit.dart';
import '../features/auth/presentation/cubit/order_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // 1. Token storage (single source for token; used by Dio + ApiService)
  if (!getIt.isRegistered<TokenStorage>()) {
    getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  }

  // 2. Dio (with auth interceptor reading from TokenStorage)
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => createDio(getIt<TokenStorage>()));
  }

  // 3. API service (save/clear token; all requests go through Dio + interceptor)
  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>(), getIt<TokenStorage>()));
  }

  // 4. Auth repository
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<ApiService>()));
  }

  // 5. Cubits (factory so each BlocProvider gets a new instance when needed)
  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>(), getIt<TokenStorage>()));
  }
  if (!getIt.isRegistered<ProductCubit>()) {
    getIt.registerFactory<ProductCubit>(() => ProductCubit(getIt<AuthRepository>()));
  }
  if (!getIt.isRegistered<OrderCubit>()) {
    getIt.registerFactory<OrderCubit>(() => OrderCubit(getIt<AuthRepository>()));
  }
}
