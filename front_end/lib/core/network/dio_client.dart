import 'package:dio/dio.dart';
import '../auth/token_storage.dart';
import 'auth_interceptor.dart';

const String kBaseUrl = 'http://192.168.100.61:8001/';

const Duration _connectTimeout = Duration(seconds: 30);
const Duration _receiveTimeout = Duration(seconds: 30);
const Duration _sendTimeout = Duration(seconds: 30);

/// Builds a Dio instance with base URL, timeouts, logging, and auth interceptor.
Dio createDio(TokenStorage tokenStorage) {
  final dio = Dio(BaseOptions(
    baseUrl: kBaseUrl,
    connectTimeout: _connectTimeout,
    receiveTimeout: _receiveTimeout,
    sendTimeout: _sendTimeout,
    headers: <String, dynamic>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.addAll(<Interceptor>[
    LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ),
    AuthInterceptor(tokenStorage),
  ]);

  return dio;
}
