import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api_service.dart';
import '../models/order_model.dart';
import '../models/product_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._api);

  final ApiService _api;

  static String _errorDetail(dynamic detail, String fallback) {
    if (detail == null) return fallback;
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] != null) return first['msg'].toString();
      return detail.join('; ');
    }
    return fallback;
  }

  static String? _tokenFrom(Map<String, dynamic> data) {
    final t = data['access_token'] ?? data['accessToken'] ?? data['token'];
    return t is String && t.isNotEmpty ? t : null;
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await _api.login(email, password);
      final data = _toMap(res.data);
      final token = _tokenFrom(data);
      if (token != null) await _api.saveAccessToken(token);
      return data;
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] : null;
      throw Exception(_errorDetail(detail, 'Login failed'));
    }
  }

  @override
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final res = await _api.signup(username: username, email: email, password: password, role: role);
      final data = _toMap(res.data);
      final token = _tokenFrom(data);
      if (token != null) await _api.saveAccessToken(token);
      return data;
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] : null;
      throw Exception(_errorDetail(detail, 'Registration failed'));
    }
  }

  @override
  Future<Map<String, dynamic>> getMe({String? token}) async {
    try {
      final res = await _api.getMe(token: token);
      final data = res.data;
      if (data is! Map) throw Exception('Invalid getMe response');
      return Map<String, dynamic>.from(data);
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] : null;
      throw Exception(_errorDetail(detail, 'Failed to load profile'));
    }
  }

  @override
  Future<void> clearSession() => _api.clearAccessToken();

  @override
  Future<Map<String, dynamic>> createShopRequest({
    required String shopName,
    required String shopDescription,
    File? imageFile,
  }) async {
    try {
      String imageUrl = '';
      if (imageFile != null && await imageFile.exists()) {
        imageUrl = await _api.uploadImage(imageFile);
      }
      final body = <String, dynamic>{
        'shop_name': shopName,
        'shop_description': shopDescription,
        'image_url': imageUrl,
      };
      final res = await _api.post('users/create-shop', data: body);
      return _toMap(res.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to submit shop request');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingShopRequests() async {
    try {
      final res = await _api.get('admin/shop-requests');
      return List<Map<String, dynamic>>.from(res.data as List);
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Error fetching requests');
    }
  }

  @override
  Future<void> updateShopStatus({required int userId, required bool approve}) async {
    try {
      await _api.put('admin/approve-shop/$userId', queryParameters: {'approve': approve});
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to update status');
    }
  }

  @override
  Future<List<ProductModel>> getAllProducts() async {
    try {
      final res = await _api.get('products/all');
      return (res.data as List).map((j) => ProductModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to load products');
    }
  }

  @override
  Future<List<ProductModel>> getShopProducts(int shopId) async {
    try {
      final res = await _api.get('products/shop/$shopId');
      return (res.data as List).map((j) => ProductModel.fromJson(j as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to fetch products');
    }
  }

  @override
  Future<ProductModel> getProduct(int productId) async {
    try {
      final res = await _api.getProduct(productId);
      return ProductModel.fromJson(Map<String, dynamic>.from(res.data));
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to load product');
    }
  }

  @override
  Future<void> addProduct(int shopId, Map<String, dynamic> productData) async {
    try {
      
      await _api.addProduct(
        shopId: shopId,
        name: productData['name'],
        price: (productData['price'] as num).toDouble(),
        description: productData['description'] ?? '',
        stockQuantity: productData['stock_quantity'] ?? 0,
        imageUrls: List<String>.from(productData['image_urls'] ?? []),
        shop_category: productData['shop_category'] ?? 1, 
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to add product');
    }
  }

  @override
  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      await _api.updateProduct(productId, productData);
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to update product');
    }
  }

  @override
  Future<void> deleteProduct(int productId) async {
    try {
      await _api.delete('products/delete/$productId');
    } on DioException catch (e) {
      throw Exception(e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to delete product');
    }
  }

  @override
  Future<Either<String, String>> createOrder(OrderModel order) async {
    try {
      final res = await _api.post('orders/create', data: order.toJson());
      return Right(res.data['message'] ?? 'Order placed successfully');
    } on DioException catch (e) {
      final detail = e.response?.data is Map ? (e.response!.data as Map)['detail'] : 'Failed to place order';
      return Left(_errorDetail(detail, 'Failed to place order'));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<OrderModel>>> getMyOrders() async {
    try {
      final res = await _api.get('orders/my-orders');
      final list = (res.data as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_errorDetail(e.response?.data?['detail'], 'Failed to fetch your orders'));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, List<OrderModel>>> getShopOrders(int shopId) async {
    try {
      final res = await _api.get('orders/shop/$shopId');
      final list = (res.data as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
      return Right(list);
    } on DioException catch (e) {
      return Left(_errorDetail(e.response?.data?['detail'], 'Failed to fetch orders'));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> updateOrderStatus({required int orderId, required String status}) async {
    try {
      await _api.put('orders/update-status/$orderId', queryParameters: {'status': status});
      return const Right('Order status updated');
    } on DioException catch (e) {
      return Left(_errorDetail(e.response?.data?['detail'], 'Failed to update status'));
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> uploadProductImage(int productId, File imageFile) async {
    try {
      final imageUrl = await _api.uploadImage(imageFile);
      await _api.addProductImages(productId, [imageUrl]);
    } on DioException catch (e) {
      throw Exception(_errorDetail(e.response?.data?['detail'], 'Failed to upload image'));
    }
  }

  @override
  Future<void> deleteProductImage(int productId, int imageId) async {
    try {
      await _api.deleteProductImage(productId, imageId);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to delete image');
    }
  }

  @override
  Future<void> addProductImages(int productId, List<String> urls) async {
    try {
      await _api.addProductImages(productId, urls);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to add images');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final res = await _api.get('admin/users');
      return List<Map<String, dynamic>>.from(res.data as List);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to load users');
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    try {
      await _api.delete('admin/users/$userId');
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to delete user');
    }
  }

  @override
  Future<void> deleteReview(int productId, int reviewId) async {
    try {
      await _api.delete('products/$productId/reviews/$reviewId');
    } on DioException catch (e) {
      throw Exception(_errorDetail(e.response?.data?['detail'], 'Failed to delete review'));
    }
  }
}