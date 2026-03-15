import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../data/models/order_model.dart';

abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  Future<Map<String, dynamic>> createShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
    File? imageFile,
  });

  Future<List<Map<String, dynamic>>> getPendingShopRequests();

  Future<void> updateShopStatus({
    required int userId,
    required bool approve,
  });

  Future<List<Map<String, dynamic>>> getAllUsers();

  Future<void> deleteUser(int userId);

  Future<List<Map<String, dynamic>>> getShopProducts(int shopId);

  Future<void> addProduct(int shopId, Map<String, dynamic> productData);

  Future<void> updateProduct(int productId, Map<String, dynamic> productData);

  Future<void> deleteProduct(int productId);

  Future<Either<String, List<OrderModel>>> getShopOrders(int shopId);

  Future<Either<String, String>> updateOrderStatus({
    required int orderId,
    required String status,
  });
}