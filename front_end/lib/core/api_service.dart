import 'dart:io';
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  final String _baseUrl = 'http://192.168.1.5:8000/';

  ApiService(this._dio) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 60);
    _dio.options.receiveTimeout = const Duration(seconds: 60);

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  Future<Response> login(String email, String password) async {
    try {
      var formData = FormData.fromMap({
        'username': email,
        'password': password,
      });

      return await _dio.post(
        'auth/login',
        data: formData,
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> addProduct({
    required int shopId,
    required String name,
    required double price,
    required String description,
    required int stockQuantity,
    required File imageFile,
  }) async {
    try {
      String fileName = imageFile.path.split('/').last;
      FormData formData = FormData.fromMap({
        "name": name,
        "price": price,
        "description": description,
        "stockQuantity": stockQuantity,
        "image": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
        ),
      });

      return await _dio.post(
        'products/add/$shopId',
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> post(
    String path, {
    dynamic data, 
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(
      path, 
      data: data, 
      options: options,
      queryParameters: queryParameters,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data, 
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.put(
      path, 
      data: data, 
      options: options,
      queryParameters: queryParameters,
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters, 
    Options? options,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }
}