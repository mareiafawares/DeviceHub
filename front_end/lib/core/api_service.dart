import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'auth/token_storage.dart';

/// HTTP client. Auth header is added by [AuthInterceptor] from [TokenStorage].
/// Call [saveAccessToken] after login/register; [clearAccessToken] on logout.
class ApiService {
  ApiService(this._dio, this._storage);

  final Dio _dio;
  final TokenStorage _storage;

  Future<void> saveAccessToken(String token) => _storage.saveToken(token);
  Future<void> clearAccessToken() => _storage.clear();

  Future<Response> login(String email, String password) => _dio.post(
        'auth/login',
        data: <String, dynamic>{'email': email, 'password': password},
        options: Options(contentType: Headers.jsonContentType),
      );

  Future<Response> signup({
    required String username,
    required String email,
    required String password,
    required String role,
  }) =>
      _dio.post(
        'auth/signup',
        data: <String, dynamic>{
          'username': username,
          'email': email,
          'password': password,
          'role': role,
        },
        options: Options(contentType: Headers.jsonContentType),
      );

  /// GET /auth/me. Pass [token] when calling right after login/register so the
  /// request is authenticated even if storage is not yet updated (e.g. Android).
  Future<Response> getMe({String? token}) {
    final options = (token != null && token.isNotEmpty)
        ? Options(headers: <String, dynamic>{'Authorization': 'Bearer $token'})
        : null;
    return _dio.get('auth/me', options: options);
  }

  /// POST /upload/image – multipart file. Returns the path as returned by the API
  /// (e.g. "/static/uploads/images/...") for use as image_url so the backend stores the path.
  /// Max 10 MB; JPEG, PNG, GIF, WebP. Response: { "url": "/static/uploads/images/..." }.
  Future<String> uploadImage(File file) async {
    const path = 'upload/image';
    final filename = file.path.split('/').last;
    final formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(
        file.path,
        filename: filename,
        contentType: _imageMediaType(filename),
      ),
    });
    final res = await _dio.post(
      path,
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );
    final data = res.data is Map ? res.data as Map<String, dynamic> : null;
    final url = data?['url'] as String?;
    if (url == null || url.isEmpty) throw Exception('No url in upload response');
    return url;
  }

  static MediaType _imageMediaType(String filename) {
    final ext = filename.split('.').last.toLowerCase();
    switch (ext) {
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'webp':
        return MediaType('image', 'webp');
      default:
        return MediaType('image', 'jpeg');
    }
  }

  /// POST /products/add/{shop_id} — JSON body with snake_case and image_urls.
  /// Upload images first via [uploadImage], then pass the returned paths here.
  Future<Response> addProduct({
    required int shopId,
    required String name,
    required double price,
    required String description,
    required int stockQuantity,
    required List<String> imageUrls,
  }) {
    final body = <String, dynamic>{
      'name': name,
      'price': price,
      'description': description,
      'stock_quantity': stockQuantity,
      'image_urls': imageUrls,
    };
    return _dio.post(
      'products/add/$shopId',
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  /// POST /products/{product_id}/images — add images by URLs.
  /// Body: { "urls": ["string"] }.
  Future<Response> addProductImages(int productId, List<String> urls) {
    return _dio.post(
      'products/$productId/images',
      data: <String, dynamic>{'urls': urls},
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  /// DELETE /products/{product_id}/images/{image_id}
  Future<Response> deleteProductImage(int productId, int imageId) {
    return _dio.delete('products/$productId/images/$imageId');
  }

  /// GET /products/{product_id} — fetch single product details (images, reviews, etc.).
  Future<Response> getProduct(int productId) {
    return _dio.get('products/$productId');
  }

  /// PATCH /products/{product_id} — partial update. Send only fields to change (snake_case).
  /// e.g. { "name": "...", "price": 19.99 } or { "stock_quantity": 25 }
  Future<Response> updateProduct(int productId, Map<String, dynamic> body) {
    return _dio.patch(
      'products/$productId',
      data: body,
      options: Options(contentType: Headers.jsonContentType),
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.post(path, data: data, options: options, queryParameters: queryParameters);

  Future<Response> put(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.put(path, data: data, options: options, queryParameters: queryParameters);

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) =>
      _dio.get(path, queryParameters: queryParameters, options: options);

  Future<Response> patch(
    String path, {
    dynamic data,
    Options? options,
    Map<String, dynamic>? queryParameters,
  }) =>
      _dio.patch(path, data: data, options: options, queryParameters: queryParameters);

  Future<Response> delete(String path, {dynamic data, Options? options}) =>
      _dio.delete(path, data: data, options: options);
}
