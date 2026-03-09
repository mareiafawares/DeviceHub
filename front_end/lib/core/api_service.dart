import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  
 
  final String _baseUrl = 'http://192.168.1.7:8000/';

  ApiService(this._dio) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
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

  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  Future<dynamic> get(String s) async {}
}