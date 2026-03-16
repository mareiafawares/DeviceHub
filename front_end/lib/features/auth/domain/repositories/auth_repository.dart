import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

/// Auth + user/shop/product/order API. Token is managed via [ApiService] + storage.
abstract class AuthRepository {
  /// POST /auth/login. Saves token; returns body (access_token, role, id, shops, …).
  Future<Map<String, dynamic>> login(String email, String password);

  /// POST /auth/signup. Saves token; returns same shape as login.
  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  /// GET /auth/me. [token] optional; pass after login/signup so request is authenticated.
  Future<Map<String, dynamic>> getMe({String? token});

  /// Clear stored token (logout).
  Future<void> clearSession();

  /// POST /users/create-shop — form: shopName, shopDescription, optional image. User from token.
  Future<Map<String, dynamic>> createShopRequest({
    required String shopName,
    required String shopDescription,
    File? imageFile,
  });

  Future<List<Map<String, dynamic>>> getPendingShopRequests();
  Future<void> updateShopStatus({required int userId, required bool approve});
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> deleteUser(int userId);

  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getShopProducts(int shopId);
  Future<ProductModel> getProduct(int productId);
  Future<void> addProduct(int shopId, Map<String, dynamic> productData);
  Future<void> addProductImages(int productId, List<String> urls);
  Future<void> deleteProductImage(int productId, int imageId);
  Future<void> updateProduct(int productId, Map<String, dynamic> productData);
  Future<void> deleteProduct(int productId);

  Future<Either<String, List<OrderModel>>> getShopOrders(int shopId);
  Future<Either<String, String>> updateOrderStatus({
    required int orderId,
    required String status,
  });
}
