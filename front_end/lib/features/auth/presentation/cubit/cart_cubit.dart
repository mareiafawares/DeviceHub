import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/models/cart_item_model.dart';
import '../../../../features/auth/data/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends HydratedCubit<CartState> {
  CartCubit() : super(CartInitial());

  void addToCart(ProductModel product, String shopName, {int quantity = 1}) {
    List<CartItemModel> currentItems = _getCurrentItems();
    int index = currentItems.indexWhere((item) => item.product.id == product.id);
    
    if (index >= 0) {
      currentItems[index].quantity += quantity;
    } else {
      currentItems.add(CartItemModel(
        product: product, 
        shopName: shopName, 
        quantity: quantity,
        isSelected: true,
      ));
    }
    _updateCart(currentItems);
  }

  void incrementQuantity(int productId) {
    List<CartItemModel> currentItems = _getCurrentItems();
    int index = currentItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      currentItems[index].quantity++;
      _updateCart(currentItems);
    }
  }

  void decrementQuantity(int productId) {
    List<CartItemModel> currentItems = _getCurrentItems();
    int index = currentItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0 && currentItems[index].quantity > 1) {
      currentItems[index].quantity--;
      _updateCart(currentItems);
    }
  }

  void removeFromCart(int productId) {
    List<CartItemModel> currentItems = _getCurrentItems();
    currentItems.removeWhere((item) => item.product.id == productId);
    _updateCart(currentItems);
  }

  void toggleSelection(int productId) {
    List<CartItemModel> currentItems = _getCurrentItems();
    int index = currentItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      currentItems[index].isSelected = !currentItems[index].isSelected;
      _updateCart(currentItems);
    }
  }

  void _updateCart(List<CartItemModel> items) {
    double total = 0;
    for (var item in items) {
      if (item.isSelected) {
        double price = double.tryParse(item.product.price.toString()) ?? 0.0;
        total += (price * item.quantity);
      }
    }
    emit(CartUpdated(List.from(items), total));
  }

  void clearCart() {
    _updateCart([]);
  }

  List<CartItemModel> _getCurrentItems() {
    final currentState = state;
    if (currentState is CartUpdated) {
      return List.from(currentState.items);
    }
    return [];
  }

  @override
  Map<String, dynamic>? toJson(CartState state) {
    if (state is CartUpdated) {
      return {
        'items': state.items.map((item) => item.toJson()).toList(),
        'totalPrice': state.totalPrice,
      };
    }
    return null;
  }

  @override
  CartState? fromJson(Map<String, dynamic> json) {
    try {
      final items = (json['items'] as List)
          .map((item) => CartItemModel.fromJson(item))
          .toList();
      final totalPrice = (json['totalPrice'] as num).toDouble();
      return CartUpdated(items, totalPrice);
    } catch (e) {
      return CartInitial();
    }
  }
}