import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<ProductModel> _products = [];
  List<ProductModel> get products => _products;

  ProductProvider() {
    fetchProducts();
  }

  void fetchProducts() {
    _firestoreService.getProductsStream().listen((productList) {
      _products = productList;
      notifyListeners();
    });
  }

  List<ProductModel> search(String query) {
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  List<ProductModel> filterByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<ProductModel> filterByPrice(double min, double max) {
    return _products.where((p) => p.price >= min && p.price <= max).toList();
  }
}