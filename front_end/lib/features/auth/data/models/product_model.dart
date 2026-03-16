class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int stockQuantity;
  final String status;
  final int shopId;
  final double? discountPrice;
  final String category;
  final List<ProductImageModel> images; 
  final List<ReviewModel> reviews;      
  final int salesCount;                 

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stockQuantity,
    required this.status,
    required this.shopId,
    this.discountPrice,
    required this.category,
    required this.images,
    required this.reviews,
    required this.salesCount,
  });

  String get imageUrl => images.isNotEmpty ? images[0].url : 'https://via.placeholder.com/150';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
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
      stockQuantity: json['stockQuantity'] ?? json['stock_quantity'] ?? 0,
      status: json['status']?.toString() ?? 'Available',
      shopId: json['shop_id'] ?? 0,
      discountPrice: json['discountPrice'] != null || json['discount_price'] != null 
          ? toDoubleSafe(json['discountPrice'] ?? json['discount_price']) 
          : null,
      category: json['category']?.toString() ?? 'General',
      images: (json['images'] as List?)
              ?.map((i) => ProductImageModel.fromJson(i))
              .toList() ?? [],
      reviews: (json['reviews'] as List?)
              ?.map((r) => ReviewModel.fromJson(r))
              .toList() ?? [],
      salesCount: json['sales_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'status': status,
      'shop_id': shopId,
      'discount_price': discountPrice,
      'category': category,
      'images': images.map((i) => i.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'sales_count': salesCount,
    };
  }
}

class ProductImageModel {
  final int id;
  final String url;

  ProductImageModel({required this.id, required this.url});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? 0,
      url: json['url']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'url': url};
}

class ReviewModel {
  final int id;
  final String? comment;
  final int rating;
  final int userId;

  ReviewModel({
    required this.id,
    this.comment,
    required this.rating,
    required this.userId,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      comment: json['comment']?.toString(),
      rating: json['rating'] ?? 5,
      userId: json['user_id'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'comment': comment,
    'rating': rating,
    'user_id': userId,
  };
}