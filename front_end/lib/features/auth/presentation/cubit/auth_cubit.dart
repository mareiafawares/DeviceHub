import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/auth/token_storage.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/models/user_model.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repo, this._storage) : super(const AuthInitial());

  final AuthRepository _repo;
  final TokenStorage _storage;

  static String _err(Object e) =>
      e.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();

  /// Restore session on app start: load token from storage, then GET /auth/me.
  Future<void> restoreSession() async {
    emit(const AuthLoading());
    final token = await _storage.getToken();
    if (token == null || token.isEmpty) {
      emit(const AuthInitial());
      return;
    }
    try {
      final data = await _repo.getMe();
      final user = UserModel.fromJson(data);
      emit(AuthSuccess(
        token: token,
        user: user,
        userRole: user.role.toLowerCase(),
        userId: user.id,
      ));
    } catch (_) {
      await _storage.clear();
      emit(const AuthInitial());
    }
  }

  static const Duration _loginTimeout = Duration(seconds: 20);

  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError('Please enter email and password'));
      return;
    }
    emit(const AuthLoading());
    try {
      final result = await _repo.login(email, password).timeout(
        _loginTimeout,
        onTimeout: () => throw Exception('Login timed out'),
      );
      final token = result['access_token'] as String? ?? result['accessToken'] as String? ?? '';
      if (token.isEmpty) throw Exception('No token in response');
      final me = await _repo.getMe(token: token).timeout(
        _loginTimeout,
        onTimeout: () => throw Exception('Request timed out'),
      );
      final user = UserModel.fromJson(me);
      emit(AuthSuccess(
        token: token,
        user: user,
        userRole: user.role.toLowerCase(),
        userId: user.id,
      ));
    } catch (e) {
      emit(AuthError(_err(e).isNotEmpty ? _err(e) : 'Login failed'));
    }
  }

  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  }) async {
    final u = username.trim();
    final e = email.trim();
    if (u.isEmpty || e.isEmpty || password.isEmpty) {
      emit(AuthError('Please enter username, email and password'));
      return;
    }
    emit(const AuthLoading());
    try {
      final result = await _repo.signUp(username: u, email: e, password: password, role: role).timeout(
        _loginTimeout,
        onTimeout: () => throw Exception('Registration timed out'),
      );
      final token = result['access_token'] as String? ?? result['accessToken'] as String? ?? '';
      if (token.isEmpty) throw Exception('No token in response');
      final me = await _repo.getMe(token: token).timeout(
        _loginTimeout,
        onTimeout: () => throw Exception('Request timed out'),
      );
      final user = UserModel.fromJson(me);
      emit(AuthSuccess(
        token: token,
        user: user,
        userRole: user.role.toLowerCase(),
        userId: user.id,
      ));
    } catch (e) {
      emit(AuthError(_err(e).isNotEmpty ? _err(e) : 'Registration failed'));
    }
  }

  Future<void> logout() async {
    await _repo.clearSession();
    emit(const AuthInitial());
  }

  /// Refresh current user from GET /auth/me (token from state or storage).
  /// Safe to call repeatedly; only one request in flight at a time.
  Future<void> refreshFromMe() async {
    final t = state is AuthSuccess ? (state as AuthSuccess).token : null;
    final token = t ?? await _storage.getToken() ?? '';
    if (token.isEmpty) return;
    try {
      final data = await _repo.getMe();
      final user = UserModel.fromJson(data);
      if (!isClosed) {
        emit(AuthSuccess(
          token: token,
          user: user,
          userRole: user.role.toLowerCase(),
          userId: user.id,
        ));
      }
    } catch (_) {
      if (state is AuthSuccess) rethrow;
    }
  }

  /// Admin: refresh user from getAllUsers (legacy).
  Future<void> refreshUserData(int userId) async {
    try {
      final users = await _repo.getAllUsers();
      final raw = users.firstWhere((u) => u['id'] == userId);
      final user = UserModel.fromJson(raw);
      final token = await _storage.getToken() ?? '';
      emit(AuthSuccess(
        token: token,
        user: user,
        userRole: user.role.toLowerCase(),
        userId: user.id,
      ));
    } catch (_) {}
  }

  /// Submits shop request then refreshes user. Does not emit [AuthLoading] or [ShopRequestSuccess]
  /// so [AuthGate] keeps showing the seller home. Returns true on success, false on error.
  Future<bool> submitShopRequest({
    required String shopName,
    required String shopDescription,
    File? imageFile,
  }) async {
    try {
      await _repo.createShopRequest(
        shopName: shopName,
        shopDescription: shopDescription,
        imageFile: imageFile,
      );
      await refreshFromMe();
      return true;
    } catch (e) {
      emit(AuthError('Failed to submit: ${_err(e)}'));
      return false;
    }
  }

  Future<void> deleteShop(int shopId) async {
    emit(const AuthLoading());
    try {
      await _repo.deleteUser(shopId);
      await refreshFromMe();
    } catch (e) {
      emit(AuthError('Failed to delete shop: ${_err(e)}'));
    }
  }

  Future<void> fetchPendingShops() async {
    emit(const AuthLoading());
    try {
      final shops = await _repo.getPendingShopRequests();
      emit(PendingShopsLoaded(shops));
    } catch (e) {
      emit(AuthError('Failed to load requests: ${_err(e)}'));
    }
  }

  Future<void> approveOrRejectShop({required int userId, required bool approve}) async {
    emit(const AuthLoading());
    try {
      await _repo.updateShopStatus(userId: userId, approve: approve);
      await fetchPendingShops();
      emit(ShopApprovalSuccess(approve ? 'Shop approved!' : 'Shop rejected.'));
    } catch (e) {
      emit(AuthError('Action failed: ${_err(e)}'));
    }
  }

  Future<void> fetchAllUsers() async {
    emit(const AuthLoading());
    try {
      final users = await _repo.getAllUsers();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(AuthError('Error fetching users: ${_err(e)}'));
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _repo.deleteUser(userId);
      await fetchAllUsers();
    } catch (e) {
      emit(AuthError('Failed to delete user: ${_err(e)}'));
    }
  }
}
