import 'package:dio/dio.dart';
import 'package:front_end/features/auth/data/models/favorite_model.dart';
import '../auth/token_storage.dart';
import 'dio_client.dart';

class FavoriteService {
  final Dio _dio;

  FavoriteService(TokenStorage tokenStorage) : _dio = createDio(tokenStorage);

  Future<bool?> toggleFavorite(int productId, int userId) async {
    try {
      final response = await _dio.post(
        'api/favorites/toggle/$productId',
        queryParameters: {'user_id': userId},
      );

      if (response.statusCode == 200) {
        return response.data['is_favorite'];
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
    return null;
  }

  Future<List<FavoriteProductModel>> getFavorites(int userId) async {
    try {
      final response = await _dio.get('api/favorites/all/$userId');

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => FavoriteProductModel.fromJson(json)).toList();
      }
    } catch (e) {
      print("Error fetching favorites: $e");
    }
    return [];
  }
}