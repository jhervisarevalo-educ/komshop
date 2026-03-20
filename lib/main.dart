import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:komshop/screens/auth/reset_password_screen.dart';
import 'package:provider/provider.dart';
import 'providers/user_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/landing_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/admin/admin_home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'KomShop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LandingWrapper(), 
        routes: {
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/home': (_) => HomeScreen(),
          '/admin': (_) => AdminHomeScreen(),
          '/reset': (_) => ResetPasswordScreen(),
        },
      ),
    );
  }
}

class LandingWrapper extends StatefulWidget {
  const LandingWrapper({super.key});

  @override
  State<LandingWrapper> createState() => _LandingWrapperState();
}

class _LandingWrapperState extends State<LandingWrapper> {
  bool _checkingUser = true;

  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.loadUser();

    if (!mounted) return;

    final user = userProvider.user;
    if (user != null) {
      if (user.userType == 'admin' || user.userType == 'superadmin') {
        Navigator.pushReplacementNamed(context, '/admin');
      } else {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      setState(() => _checkingUser = false); 
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return const LandingScreen(); 
  }
}