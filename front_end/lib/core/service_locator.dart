import 'package:front_end/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:front_end/features/auth/domain/repositories/auth_repository.dart';
import 'package:front_end/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'api_service.dart';

final getIt =GetIt.instance;
void setupServiceLocator() {
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerSingleton<ApiService>(ApiService(getIt()));
  getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt <ApiService>()));
 getIt.registerFactory(() => AuthCubit(getIt<AuthRepository>()));
}