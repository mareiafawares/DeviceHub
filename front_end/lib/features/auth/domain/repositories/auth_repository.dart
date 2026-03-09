// features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  // التعديل: إرجاع Map بدلاً من String
  Future<Map<String, dynamic>> login(String email, String password);
  
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  });
}
