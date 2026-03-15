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
    // دالة مساعدة داخلية لتحويل الأرقام بأمان إلى double
    double toDoubleSafe(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: toDoubleSafe(json['price']),
      stockQuantity: json['stock_quantity'] ?? 0,
      imageUrl: json['image_url']?.toString() ?? 'https://via.placeholder.com/150',
      status: json['status']?.toString() ?? 'Available',
      shopId: json['shop_id'] ?? 0,
      discountPrice: json['discount_price'] != null ? toDoubleSafe(json['discount_price']) : null,
      category: json['category']?.toString() ?? 'General',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id, 
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