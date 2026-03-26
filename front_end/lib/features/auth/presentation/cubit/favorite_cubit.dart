import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:front_end/features/auth/data/models/favorite_model.dart';
import 'favorite_state.dart';
import '../../../../core/network/favorite_service.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  final FavoriteService _favoriteService;
  
  List<FavoriteProductModel> _currentFavorites = [];

  FavoriteCubit(this._favoriteService) : super(FavoriteInitial());

  Future<void> loadFavorites(int userId) async {
    emit(FavoriteLoading());
    try {
      _currentFavorites = await _favoriteService.getFavorites(userId);
      emit(FavoriteLoaded(_currentFavorites));
    } catch (e) {
      emit(FavoriteError("Failed to load favorites"));
    }
  }

  Future<void> toggleFavorite(int productId, int userId) async {
    try {
      final result = await _favoriteService.toggleFavorite(productId, userId);
      
      if (result != null) {
        _currentFavorites = await _favoriteService.getFavorites(userId);
        emit(FavoriteLoaded(List.from(_currentFavorites))); 
      }
    } catch (e) {
      emit(FavoriteError("Error updating favorites"));
    }
  }

  bool isProductFavorite(int productId) {
    return _currentFavorites.any((element) => element.id == productId);
  }
}