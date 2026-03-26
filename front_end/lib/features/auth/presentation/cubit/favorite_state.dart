

import 'package:front_end/features/auth/data/models/favorite_model.dart';

abstract class FavoriteState {}

class FavoriteInitial extends FavoriteState {}

class FavoriteLoading extends FavoriteState {}

class FavoriteLoaded extends FavoriteState {
  final List<FavoriteProductModel> favorites;
  FavoriteLoaded(this.favorites);
}

class FavoriteError extends FavoriteState {
  final String message;
  FavoriteError(this.message);
}


class FavoriteToggleSuccess extends FavoriteState {
  final int productId;
  final bool isFavorite;
  FavoriteToggleSuccess(this.productId, this.isFavorite);
}