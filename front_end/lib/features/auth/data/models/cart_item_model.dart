import '../../../../features/auth/data/models/product_model.dart';

class CartItemModel {
  final ProductModel product;
  int quantity;
  final String shopName; 
  bool isSelected;

  CartItemModel({
    required this.product,
    this.quantity = 1,
    required this.shopName,
    this.isSelected = true,
  });

  
  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(), 
      'shopName': shopName,
      'isSelected': isSelected,
    };
  }

  
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product']), 
      quantity: json['quantity'] ?? 1,
      shopName: json['shopName'] ?? 'Unknown Store',
      isSelected: json['isSelected'] ?? true,
    );
  }
}