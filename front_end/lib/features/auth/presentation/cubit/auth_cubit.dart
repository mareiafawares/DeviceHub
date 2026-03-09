import "package:flutter_bloc/flutter_bloc.dart";
import '../../domain/repositories/auth_repository.dart';


abstract class AuthState {}
class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthSuccess extends AuthState {
  final String token;
  final String? userRole; 
  AuthSuccess(this.token, {this.userRole});
}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}


class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;
  
  AuthCubit(this.authRepository) : super(AuthInitial());

  
  Future<void> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      emit(AuthError("يرجى إدخال جميع البيانات"));
      return;
    }
    emit(AuthLoading());
    try {
      final result = await authRepository.login(email, password);
      emit(AuthSuccess(
        result['access_token'] ?? '', 
        userRole: result['role']?.toString().toLowerCase()
      ));
    } catch (e) {
      emit(AuthError("خطأ في تسجيل الدخول: تأكد من الإيميل وكلمة المرور"));
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
        role: role
      );
      
      
      emit(AuthSuccess("Registration Successful", userRole: role)); 
    } catch (e) {
      emit(AuthError("فشل إنشاء الحساب: ${e.toString()}"));
    }
  }
}