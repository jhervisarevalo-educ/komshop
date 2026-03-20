class CartItemModel {
  final String productId; 
  final String name;
  final double price;
  int quantity;
  final String imageUrl; 

  CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'],
      name: map['name'],
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'],
      imageUrl: map['imageUrl'],
    );
  }

  double get total => price * quantity;
}