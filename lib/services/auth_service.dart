import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserModel?> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final user = UserModel(
      uid: cred.user!.uid,
      name: name,
      email: email,
      userType: 'user',
    );
    await FirestoreService().createUser(user);
    return user;
  }

  Future<UserModel?> login(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final user = await FirestoreService().getUserById(cred.user!.uid);
    return user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;

  String? currentUserId() => _auth.currentUser?.uid;

  Future<String?> currentUserRole() async {
    if (_auth.currentUser == null) return null;
    final userDoc = await FirestoreService().getUserById(_auth.currentUser!.uid);
    return userDoc?.userType;
  }
}