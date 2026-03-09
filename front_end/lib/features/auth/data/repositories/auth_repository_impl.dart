import '../../domain/repositories/auth_repository.dart';
import '../../../../core/api_service.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiService apiService;

  AuthRepositoryImpl(this.apiService);

  @override
  
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.login(email, password);

      if (response.statusCode == 200) {
        
        return {
          'access_token': response.data['access_token'],
          'role': response.data['role'],
        };
      } else {
        throw Exception("Login Failed");
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? "فشل تسجيل الدخول");
    }
  }

  @override
  Future<void> signUp({
    required String username, 
    required String email, 
    required String password, 
    required String role
  }) async {
    await apiService.post('users/', data: {
      'username': username,
      'email': email,
      'password': password,
      'role': role,
    });
  }
}