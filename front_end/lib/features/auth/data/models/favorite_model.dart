class FavoriteProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final int shopId;
  final String category;
  final String status;

  FavoriteProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.shopId,
    required this.category,
    required this.status,
  });

 
  factory FavoriteProductModel.fromJson(Map<String, dynamic> json) {
    return FavoriteProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'] ?? '',
      shopId: json['shop_id'] ?? 0,
      category: json['category'] ?? '',
      status: json['status'] ?? '',
    );
  }
}