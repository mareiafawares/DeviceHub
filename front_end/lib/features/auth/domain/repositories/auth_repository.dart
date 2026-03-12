abstract class AuthRepository {
  Future<Map<String, dynamic>> login(String email, String password);
  
  Future<void> signUp({
    required String username,
    required String email,
    required String password,
    required String role,
  });

  // التأكد من أن الإرسال صار POST ليتوافق مع السيرفر الجديد
  Future<Map<String, dynamic>> createShopRequest({
    required int userId,
    required String shopName,
    required String shopDescription,
  });

  Future<List<Map<String, dynamic>>> getPendingShopRequests();

  Future<void> updateShopStatus({
    required int userId,
    required bool approve,
  });

  Future<List<Map<String, dynamic>>> getAllUsers();

  Future<void> deleteUser(int userId);
}