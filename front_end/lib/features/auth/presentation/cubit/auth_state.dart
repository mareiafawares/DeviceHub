import '../../data/models/user_model.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final String token;
  final UserModel user; 
  final String? userRole;
  final int? userId;

  AuthSuccess(
    this.token, {
    required this.user, 
    this.userRole,
    this.userId,
  });
}

class AuthRegistrationSuccess extends AuthState {}
class ShopRequestSuccess extends AuthState {} 

class PendingShopsLoaded extends AuthState {
  final List<Map<String, dynamic>> shops;
  PendingShopsLoaded(this.shops);
}

class UsersLoaded extends AuthState {
  final List<Map<String, dynamic>> users;
  UsersLoaded(this.users);
}

class ShopApprovalSuccess extends AuthState {
  final String message;
  ShopApprovalSuccess(this.message);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}