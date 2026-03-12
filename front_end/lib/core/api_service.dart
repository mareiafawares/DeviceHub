import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  
  // تأكدي دائماً أن الـ IP يطابق جهازك الحالي (مثلاً 192.168.1.2)
  final String _baseUrl = 'http://192.168.1.2:8000/';

  ApiService(this._dio) {
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 30);

    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }

  // دالة Login باستخدام FormData
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

  // دالة POST العامة
  Future<Response> post(String path, {dynamic data, Options? options}) async {
    return await _dio.post(path, data: data, options: options);
  }

  // دالة PUT المعدلة (أصبحت الاختيارات اختيارية وليست required)
  Future<Response> put(
    String path, {
    dynamic data, 
    Options? options, 
    Map<String, dynamic>? queryParameters, // تعديل النوع وحذف required
  }) async {
    return await _dio.put(
      path, 
      data: data, 
      options: options, 
      queryParameters: queryParameters,
    );
  }

  // دالة GET العامة
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  // دالة DELETE العامة (ستحتاجينها لاحقاً في صفحة AdminUsersPage)
  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    return await _dio.delete(path, data: data, options: options);
  }
}