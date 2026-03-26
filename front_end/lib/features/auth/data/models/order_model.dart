import 'dart:convert';

class OrderModel {
  final int id;
  final int userId;
  final int shopId;
  final String fullName;
  final String phoneNumber;
  final String city;
  final String addressDetails;
  final String? deliveryNotes;
  final double totalPrice;
  final String status;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.userId,
    required this.shopId,
    required this.fullName,
    required this.phoneNumber,
    required this.city,
    required this.addressDetails,
    this.deliveryNotes,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItemModel> parseItems(dynamic itemsJson) {
      if (itemsJson == null || !(itemsJson is List)) return [];
      return itemsJson
          .map((item) => OrderItemModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? 0,
      userId: json['buyer_id'] ?? json['user_id'] ?? 0,
      shopId: json['shop_id'] ?? 0,
      fullName: json['full_name'] ?? json['fullName'] ?? 'Customer',
      phoneNumber: json['phone_number'] ?? json['phoneNumber'] ?? '',
      city: json['city'] ?? '',
      addressDetails: json['address_details'] ?? json['addressDetails'] ?? '',
      deliveryNotes: json['delivery_notes']?.toString(),
      totalPrice: (json['total_price'] ?? json['totalPrice'] ?? 0).toDouble(),
      status: json['status'] ?? 'Pending',
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
      items: parseItems(json['items'] ?? json['order_items'] ?? json['OrderItems']),
    );
  }

  static DateTime _parseDate(dynamic dateStr) {
    if (dateStr == null) return DateTime.now();
    try {
      return DateTime.parse(dateStr.toString());
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': userId,
      'shop_id': shopId,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'city': city,
      'address_details': addressDetails,
      'delivery_notes': deliveryNotes,
      'total_price': totalPrice,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
    };
  }
}

class OrderItemModel {
  final int productId;
  final int quantity;
  final double priceAtPurchase;
  final String productName;
  final String productImage;

  OrderItemModel({
    required this.productId,
    required this.quantity,
    required this.priceAtPurchase,
    required this.productName,
    required this.productImage,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productId: json['product_id'] ?? json['productId'] ?? 0,
      quantity: json['quantity'] ?? 0,
      priceAtPurchase: (json['price_at_purchase'] ?? json['priceAtPurchase'] ?? 0).toDouble(),
      productName: json['product_name'] ?? json['productName'] ?? 'Product', 
      productImage: json['product_image'] ?? json['productImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'price_at_purchase': priceAtPurchase,
      'product_name': productName,
      'product_image': productImage,
    };
  }
}