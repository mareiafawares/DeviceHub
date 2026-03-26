class UserModel {
  final int id;
  final String username;
  final String email;
  final String role;
  final List<ShopModel> shops;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.shops,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    var shopsFromJson = json['shops'];
    List<ShopModel> shopList = [];

    if (shopsFromJson != null && shopsFromJson is List) {
      shopList = shopsFromJson
          .map((shopData) => ShopModel.fromJson(shopData))
          .toList();
    }

    return UserModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      shops: shopList,
    );
  }

  void operator [](String other) {}
}

class ShopModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final bool isApproved;
  final bool hasShopRequest;

  ShopModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl, 
    required this.isApproved,
    required this.hasShopRequest,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Shop',
      description: json['description'],
      imageUrl: json['image_url'], 
      isApproved: json['is_approved'] ?? false,
      hasShopRequest: json['has_shop_request'] ?? false,
    );
  }
}