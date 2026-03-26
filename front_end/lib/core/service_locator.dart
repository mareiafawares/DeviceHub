import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import 'auth/token_storage.dart';
import 'network/dio_client.dart';
import 'network/favorite_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/product_cubit.dart';
import '../features/auth/presentation/cubit/order_cubit.dart';
import '../features/auth/presentation/cubit/favorite_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (!getIt.isRegistered<TokenStorage>()) {
    getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  }

  if (!getIt.isRegistered<Dio>()) {
    getIt.registerLazySingleton<Dio>(() => createDio(getIt<TokenStorage>()));
  }

  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerLazySingleton<ApiService>(() => ApiService(getIt<Dio>(), getIt<TokenStorage>()));
  }

  if (!getIt.isRegistered<FavoriteService>()) {
    getIt.registerLazySingleton<FavoriteService>(() => FavoriteService(getIt<TokenStorage>()));
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt<ApiService>()));
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory<AuthCubit>(() => AuthCubit(getIt<AuthRepository>(), getIt<TokenStorage>()));
  }
  
  if (!getIt.isRegistered<ProductCubit>()) {
    getIt.registerFactory<ProductCubit>(() => ProductCubit(getIt<AuthRepository>()));
  }
  
  if (!getIt.isRegistered<OrderCubit>()) {
    getIt.registerFactory<OrderCubit>(() => OrderCubit(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<FavoriteCubit>()) {
    getIt.registerFactory<FavoriteCubit>(() => FavoriteCubit(getIt<FavoriteService>()));
  }
}