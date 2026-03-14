class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String imageUrl;
  final String status;
  final int shopId;
  final double? discountPrice;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.imageUrl,
    required this.status,
    required this.shopId,
    this.discountPrice,
    required this.category,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url'] ?? 'https://via.placeholder.com/150',
      status: json['status'] ?? 'Available',
      shopId: json['shop_id'] ?? 0,
      discountPrice: json['discount_price'] != null ? json['discount_price'].toDouble() : null,
      category: json['category'] ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'status': status,
      'shop_id': shopId,
      'discount_price': discountPrice,
      'category': category,
    };
  }
}