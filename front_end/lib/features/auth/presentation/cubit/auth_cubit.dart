import "package:flutter_bloc/flutter_bloc.dart";
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

  // ==================== 1. نظام تسجيل الدخول ====================
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError("Please enter all required fields"));
      return;
    }

    emit(AuthLoading());
    try {
      final Map<String, dynamic> result = await authRepository.login(email, password);
      final user = UserModel.fromJson(result);

      emit(AuthSuccess(
        result['access_token'] ?? '',
        user: user, 
        userRole: user.role.toLowerCase(),
        userId: user.id,
      ));
    } catch (e) {
      emit(AuthError("Login failed: ${e.toString()}"));
    }
  }

  // ==================== 2. دالة تحديث بيانات المستخدم ====================
  Future<void> refreshUserData(int userId) async {
    try {
      final users = await authRepository.getAllUsers();
      final currentUserData = users.firstWhere((u) => u['id'] == userId);
      final updatedUser = UserModel.fromJson(currentUserData);

      emit(AuthSuccess(
        "session_token", 
        user: updatedUser,
        userRole: updatedUser.role.toLowerCase(),
        userId: updatedUser.id,
      ));
      
      // طباعة عدد المتاجر للتأكد من التحديث
      print("DEBUG: User status refreshed: Total Shops = ${updatedUser.shops.length}");
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

  // ==================== 3. نظام التسجيل (Sign Up) ====================
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(AuthLoading());
    try {
      await authRepository.signUp(
        username: username,
        email: email,
        password: password,
        role: role,
      );
      emit(AuthRegistrationSuccess()); 
    } catch (e) {
      emit(AuthError("Registration failed: ${e.toString()}"));
    }
  }

  // ==================== 4. وظائف البائع (Seller) & إدارة المتاجر ====================

  // إرسال طلب إنشاء متجر جديد
  Future<void> submitShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
  }) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.createShopRequest(
        userId: userId,
        shopName: shopName,
        shopDescription: shopDescription,
      );
      
      final updatedUser = UserModel.fromJson(result);

      // نرسل حالة نجاح الطلب أولاً
      emit(ShopRequestSuccess());

      // ثم نحدث حالة الـ AuthSuccess باليوزر الجديد اللي صار عنده متجر زيادة في القائمة
      emit(AuthSuccess(
        "session_token", 
        user: updatedUser,
        userRole: updatedUser.role.toLowerCase(),
        userId: updatedUser.id,
      ));
    } catch (e) {
      emit(AuthError("Failed to submit shop request: ${e.toString()}"));
    }
  }

  // دالة حذف المتجر (نستخدم الـ shopId الآن وليس userId)
  Future<void> deleteShop(int shopId) async {
    emit(AuthLoading());
    try {
      // هنا بننادي دالة الحذف من السيرفر باستخدام الـ ID الخاص بالمحل
      await authRepository.deleteUser(shopId); // تأكدي من اسم الدالة بالسيرفر لحذف المتجر
      
      // بعد الحذف، نحتاج لعمل Refresh لبيانات اليوزر عشان تختفي من القائمة بالفلتر
      // ملاحظة: نحتاج الـ userId الحالي لعمل refresh
      // إذا الـ state هي AuthSuccess نقدر نطول الـ userId
      if (state is AuthSuccess) {
        final currentUserId = (state as AuthSuccess).userId;
        await refreshUserData(currentUserId!);
      }
      
      print("DEBUG: Shop $shopId deleted");
    } catch (e) {
      emit(AuthError("Failed to delete shop: ${e.toString()}"));
    }
  }

  // ==================== 5. وظائف الأدمن (Admin) ====================

  Future<void> fetchPendingShops() async {
    emit(AuthLoading());
    try {
      final shops = await authRepository.getPendingShopRequests();
      emit(PendingShopsLoaded(shops));
    } catch (e) {
      emit(AuthError("Failed to load shop requests"));
    }
  }

  Future<void> approveOrRejectShop({required int userId, required bool approve}) async {
    emit(AuthLoading());
    try {
      await authRepository.updateShopStatus(userId: userId, approve: approve);
      final updatedShops = await authRepository.getPendingShopRequests();
      emit(PendingShopsLoaded(updatedShops));
      emit(ShopApprovalSuccess(approve ? "Shop approved!" : "Shop rejected."));
    } catch (e) {
      emit(AuthError("Action failed: ${e.toString()}"));
    }
  }

  Future<void> fetchAllUsers() async {
    emit(AuthLoading());
    try {
      final users = await authRepository.getAllUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AuthError("Error fetching users"));
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await authRepository.deleteUser(userId);
      fetchAllUsers(); 
    } catch (e) {
      emit(AuthError("Failed to delete user"));
    }
  }
}