import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api_service.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  // 1. تسجيل الدخول - استلام كامل البيانات
  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);
      // نعيد الخريطة (Map) كاملة لكي يقرأ الـ UserModel حقول الحالة
      return response.data; 
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Login failed");
    }
  }

  // 2. إنشاء حساب جديد
  @override
  Future<void> signUp({
    required String username, 
    required String email, 
    required String password, 
    required String role
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

  // 3. طلب إنشاء متجر (تم التعديل ليرجع Map بدلاً من void)
  @override
  Future<Map<String, dynamic>> createShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
  }) async {
    try {
      final response = await apiService.put(
        'users/create-shop/$userId', 
        data: {
          'shop_name': shopName,
          'shop_description': shopDescription,
        },
      );
      // إرجاع البيانات الجديدة (المستخدم مع المتجر الجديد) لكي يقرأها الـ Cubit
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to submit shop request");
    }
  }

  // 4. جلب طلبات المتاجر المعلقة (للأدمن)
  @override
  Future<List<Map<String, dynamic>>> getPendingShopRequests() async {
    try {
      final response = await apiService.get('admin/shop-requests');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Error fetching requests");
    }
  }

  // 5. قبول أو رفض طلب المتجر
  @override
  Future<void> updateShopStatus({
    required int userId,
    required bool approve,
  }) async {
    try {
      await apiService.put(
        'admin/approve-shop/$userId',
        queryParameters: {'approve': approve},
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to update status");
    }
  }

  // 6. جلب كل المستخدمين
  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final response = await apiService.get('admin/users'); 
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to load users");
    }
  }

  // 7. حذف المستخدم
  @override
  Future<void> deleteUser(int userId) async {
    try {
      await apiService.delete('admin/users/$userId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "Failed to delete user");
    }
  }
}