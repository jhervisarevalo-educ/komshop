import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, CartItemModel> _items = {};
  Map<String, CartItemModel> get items => _items;

  void addToCart(ProductModel product) {
    if (_items.containsKey(product.id)) {
      _items[product.id]!.quantity += 1; 
    } else {
      _items[product.id!] = CartItemModel(
        productId: product.id!,
        name: product.name,
        price: product.price,
        quantity: 1,
        imageUrl: product.imageUrl, 
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  double get totalPrice {
    double total = 0;
    _items.forEach((key, item) {
      total += item.total; 
    });
    return total;
  }

  void increaseQuantity(String productId) {
    if (_items.containsKey(productId)) {
      _items[productId]!.quantity += 1;
      notifyListeners();
    }
  }

  void decreaseQuantity(String productId) {
    if (_items.containsKey(productId) && _items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
      notifyListeners();
    }
  }
}