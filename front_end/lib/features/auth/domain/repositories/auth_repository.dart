import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../data/models/order_model.dart';
import '../../data/models/product_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);

  Future<Map<String, dynamic>> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<Map<String, dynamic>> getMe({String? token});

  Future<void> clearSession();

  // --- Shops ---
  Future<Map<String, dynamic>> createShopRequest({
    required String shopName,
    required String shopDescription,
    File? imageFile,
  });
  Future<List<Map<String, dynamic>>> getPendingShopRequests();
  Future<void> updateShopStatus({required int userId, required bool approve});

  // --- Users ---
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> deleteUser(int userId);

  // --- Products ---
  Future<List<ProductModel>> getAllProducts();
  Future<List<ProductModel>> getShopProducts(int shopId);
  Future<ProductModel> getProduct(int productId);
  Future<void> addProduct(int shopId, Map<String, dynamic> productData);
  Future<void> addProductImages(int productId, List<String> urls);
  Future<void> deleteProductImage(int productId, int imageId);
  Future<void> updateProduct(int productId, Map<String, dynamic> productData);
  Future<void> deleteProduct(int productId);
  Future<void> uploadProductImage(int productId, File imageFile);
  Future<void> deleteReview(int productId, int reviewId);

  // --- Orders ---
  Future<Either<String, String>> createOrder(OrderModel order);

  Future<Either<String, List<OrderModel>>> getMyOrders();

  Future<Either<String, List<OrderModel>>> getShopOrders(int shopId);

  Future<Either<String, String>> updateOrderStatus({
    required int orderId,
    required String status,
  });
}