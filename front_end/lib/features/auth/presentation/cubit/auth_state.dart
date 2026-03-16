import '../../data/models/user_model.dart';

/// Base type for all auth-related states.
sealed class AuthState {
  const AuthState();
}

/// No user session (initial or after logout).
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Auth operation in progress (login, register, restore, refresh).
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated. [user] from API; [token] kept for refresh/me.
final class AuthSuccess extends AuthState {
  const AuthSuccess({
    required this.token,
    required this.user,
    this.userRole,
    this.userId,
  });

  final String token;
  final UserModel user;
  final String? userRole;
  final int? userId;
}

/// Auth operation failed (login, register, or API error).
final class AuthError extends AuthState {
  const AuthError(this.message);
  final String message;
}

/// Shop request submitted; seller flow then refreshes user.
final class ShopRequestSuccess extends AuthState {
  const ShopRequestSuccess();
}

/// Admin: list of pending shop requests loaded.
final class PendingShopsLoaded extends AuthState {
  const PendingShopsLoaded(this.shops);
  final List<Map<String, dynamic>> shops;
}

/// Admin: list of all users loaded.
final class UsersLoaded extends AuthState {
  const UsersLoaded(this.users);
  final List<Map<String, dynamic>> users;
}

/// Admin: shop approved or rejected.
final class ShopApprovalSuccess extends AuthState {
  const ShopApprovalSuccess(this.message);
  final String message;
}
