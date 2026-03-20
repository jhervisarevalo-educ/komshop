class ProductModel {
  final String? id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String imageUrl;
  final int stockQuantity;

  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.stockQuantity,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map, String docId) {
    return ProductModel(
      id: docId,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'] ?? '',
      stockQuantity: map['stockQuantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'category': category,
      'price': price,
      'imageUrl': imageUrl,
      'stockQuantity': stockQuantity,
    };
  }
}