import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/cubit/auth_cubit.dart';
import '../features/auth/presentation/cubit/product_cubit.dart';
import '../features/auth/presentation/cubit/order_cubit.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  if (!getIt.isRegistered<Dio>()) {
    getIt.registerSingleton<Dio>(Dio());
  }

  if (!getIt.isRegistered<ApiService>()) {
    getIt.registerSingleton<ApiService>(ApiService(getIt<Dio>()));
  }

  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<ApiService>()),
    );
  }

  if (!getIt.isRegistered<AuthCubit>()) {
    getIt.registerFactory(() => AuthCubit(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<ProductCubit>()) {
    getIt.registerFactory(() => ProductCubit(getIt<AuthRepository>()));
  }

  if (!getIt.isRegistered<OrderCubit>()) {
    getIt.registerFactory(() => OrderCubit(getIt<AuthRepository>()));
  }
}