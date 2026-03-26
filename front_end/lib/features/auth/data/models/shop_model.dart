class ShopModel {
  final int id;
  final String name;
  final String description;
  final String? imageUrl; 
  final int ownerId;

  ShopModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.ownerId,
  });

  
 factory ShopModel.fromJson(Map<String, dynamic> json) {
  return ShopModel(
    id: json['id'],
    name: json['name'],
    
    description: json['description'] ?? "", 
    imageUrl: json['image_url'],
    ownerId: json['owner_id'],
  );
}
}