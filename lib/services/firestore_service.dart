import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.data()!, doc.id);
  }

  Future<List<UserModel>> getAllUsers() async {
    final snapshot = await _db.collection('users').get();
    return snapshot.docs
        .map((doc) => UserModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<UserModel>> getUsersStream() {
    return _db.collection('users').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> addProduct(ProductModel product) async {
    await _db.collection('products').add(product.toMap());
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String productId) async {
    await _db.collection('products').doc(productId).delete();
  }

  Stream<List<ProductModel>> getProductsStream() {
    return _db.collection('products').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<ProductModel>> getAllProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> createOrder(OrderModel order) async {
    await _db.collection('orders').add(order.toMap());
  }

  Stream<List<OrderModel>> getOrdersStreamForUser(String userId) {
    return _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Stream<List<OrderModel>> getAllOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<OrderModel>> getAllOrders() async {
    final snapshot = await _db.collection('orders').get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<OrderModel>> getOrdersByUser(String userId) async {
    final snapshot = await _db
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    await _db.collection('orders').doc(orderId).update({'status': status});
  }

  Future<void> deleteOrder(String orderId) async {
    await _db.collection('orders').doc(orderId).delete();
  }

  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _db.collection('products').doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromMap(doc.data()!, doc.id);
  }

  Future<void> updateProductStock(String productId, int newStock) async {
    await _db.collection('products').doc(productId).update({
      'stockQuantity': newStock,
    });
  }

  Future<int> getTotalProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs.length;
  }

  Future<int> getTotalOrders() async {
    final snapshot = await _db.collection('orders').get();
    return snapshot.docs.length;
  }

  Future<int> getPendingOrders() async {
    final snapshot = await _db
        .collection('orders')
        .where('status', isEqualTo: 'pending')
        .get();
    return snapshot.docs.length;
  }

  Future<int> getCompletedOrders() async {
    final snapshot = await _db
        .collection('orders')
        .where('status', isEqualTo: 'completed')
        .get();
    return snapshot.docs.length;
  }
}