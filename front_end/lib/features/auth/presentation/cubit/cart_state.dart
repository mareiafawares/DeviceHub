import '../../data/models/cart_item_model.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartUpdated extends CartState {
  final List<CartItemModel> items;
  final double totalPrice;

  CartUpdated(this.items, this.totalPrice);
}