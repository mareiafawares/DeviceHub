// ignore: depend_on_referenced_packages
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api_service.dart';
import '../models/order_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Login failed");
    }
  }

  @override
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      await apiService.post('users/', data: {
        'username': username,
        'email': email,
        'password': password,
        'role': role,
      });
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Registration failed");
    }
  }

  
  @override
  Future<Map<String, dynamic>> createShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
  }) async {
    try {
      final response = await apiService.post(
        'users/create-shop/$userId',
        data: {
          'shop_name': shopName,
          'shop_description': shopDescription,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to submit shop request");
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getPendingShopRequests() async {
    try {
      final response = await apiService.get('admin/shop-requests');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Error fetching requests");
    }
  }

  @override
  Future<void> updateShopStatus({required int userId, required bool approve}) async {
    try {
      await apiService.put(
        'admin/approve-shop/$userId',
        queryParameters: {'approve': approve},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to update status");
    }
  }

  
  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await apiService.get('admin/users');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to load users");
    }
  }

  @override
  Future<void> deleteUser(int userId) async {
    try {
      await apiService.delete('admin/users/$userId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to delete user");
    }
  }

 
  @override
  Future<List<Map<String, dynamic>>> getShopProducts(int shopId) async {
    try {
      final response = await apiService.get('products/shop/$shopId');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to fetch products");
    }
  }

  @override
  Future<void> addProduct(int shopId, Map<String, dynamic> productData) async {
    try {
      FormData formData = FormData.fromMap({
        "name": productData['name'],
        "price": productData['price'],
        "description": productData['description'] ?? "No description",
        "stockQuantity": productData['stockQuantity'] ?? 0,
        "image": await MultipartFile.fromFile(
          productData['imageUrl'],
          filename: productData['imageUrl'].split('/').last,
        ),
      });

      await apiService.post('products/add/$shopId', data: formData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to add product");
    }
  }

  @override
  Future<void> updateProduct(int productId, Map<String, dynamic> productData) async {
    try {
      await apiService.put('products/update/$productId', data: productData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to update product");
    }
  }

  @override
  Future<void> deleteProduct(int productId) async {
    try {
      await apiService.delete('products/delete/$productId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to delete product");
    }
  }

  

  @override
  Future<Either<String, List<OrderModel>>> getShopOrders(int shopId) async {
    try {
      final response = await apiService.get('orders/shop/$shopId');
      final List ordersJson = response.data;
      final orders = ordersJson.map((e) => OrderModel.fromJson(e)).toList();
      return Right(orders);
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? "Failed to fetch orders");
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> updateOrderStatus({
    required int orderId,
    required String status,
  }) async {
    try {
      await apiService.put(
        'orders/update-status/$orderId',
        queryParameters: {'status': status},
      );
      return const Right("Order status updated successfully");
    } on DioException catch (e) {
      return Left(e.response?.data['detail'] ?? "Failed to update order status");
    } catch (e) {
      return Left(e.toString());
    }
  }
}