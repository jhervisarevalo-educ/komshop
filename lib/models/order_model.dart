import 'package:cloud_firestore/cloud_firestore.dart';
import 'cart_item_model.dart';

class OrderModel {
  final String orderId;
  final String userId;
  final List<CartItemModel> cartItems;
  final double totalPrice;
  final String status; 
  final DateTime createdAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.cartItems,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromMap(Map<String, dynamic> map, String docId) {
    List<CartItemModel> items = [];
    if (map['cartItems'] != null) {
      items = List<Map<String, dynamic>>.from(map['cartItems'])
          .map((e) => CartItemModel(
                productId: e['productId'],
                name: e['name'],
                price: (e['price'] ?? 0).toDouble(),
                quantity: e['quantity'] ?? 1,
                imageUrl: e['imageUrl'] ?? '', 
              ))
          .toList();
    }

    return OrderModel(
      orderId: docId,
      userId: map['userId'] ?? '',
      cartItems: items,
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cartItems': cartItems
          .map((e) => {
                'productId': e.productId,
                'name': e.name,
                'price': e.price,
                'quantity': e.quantity,
                'imageUrl': e.imageUrl, 
              })
          .toList(),
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt,
    };
  }
}