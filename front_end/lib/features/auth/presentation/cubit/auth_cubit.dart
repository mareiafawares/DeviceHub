import "package:flutter_bloc/flutter_bloc.dart";
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial());

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
    } catch (e) {
      print("Error refreshing data: $e");
    }
  }

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

  Future<void> submitShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
  }) async {
    emit(AuthLoading());
    try {
      await authRepository.createShopRequest(
        userId: userId,
        shopName: shopName,
        shopDescription: shopDescription,
      );
      emit(ShopRequestSuccess());
      await refreshUserData(userId);
    } catch (e) {
      emit(AuthError("Failed to submit: ${e.toString()}"));
    }
  }

  Future<void> deleteShop(int shopId) async {
    emit(AuthLoading());
    try {
      await authRepository.deleteUser(shopId);
      if (state is AuthSuccess) {
        final currentUserId = (state as AuthSuccess).userId;
        await refreshUserData(currentUserId!);
      }
    } catch (e) {
      emit(AuthError("Failed to delete shop: ${e.toString()}"));
    }
  }

  Future<void> fetchPendingShops() async {
    emit(AuthLoading());
    try {
      final shops = await authRepository.getPendingShopRequests();
      emit(PendingShopsLoaded(shops));
    } catch (e) {
      emit(AuthError("Failed to load requests"));
    }
  }

  Future<void> approveOrRejectShop({required int userId, required bool approve}) async {
    emit(AuthLoading());
    try {
      await authRepository.updateShopStatus(userId: userId, approve: approve);
      await fetchPendingShops();
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
      await fetchAllUsers();
    } catch (e) {
      emit(AuthError("Failed to delete user"));
    }
  }
}