import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  UserModel? get user => _user;

  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> loadUser() async {
    final current = _authService.currentUser;
    if (current != null) {
      _user = await _firestoreService.getUserById(current.uid);
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _user = await _authService.register(name, email, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    String? contactNo,
    String? address,
  }) async {
    if (_user == null) return;

    final updatedUser = UserModel(
      uid: _user!.uid,
      name: name,
      email: _user!.email,
      userType: _user!.userType,
      contactNo: contactNo,
      address: address,
    );

    await _firestoreService.updateUser(updatedUser);
    _user = updatedUser;
    notifyListeners();
  }

  void setUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }
}