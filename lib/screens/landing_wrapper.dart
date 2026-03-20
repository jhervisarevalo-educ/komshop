import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class LandingWrapper extends StatefulWidget {
  const LandingWrapper({super.key});

  @override
  _LandingWrapperState createState() => _LandingWrapperState();
}

class _LandingWrapperState extends State<LandingWrapper> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      userProvider.loadUser().then((_) {
        if (!mounted) return; 

        final user = userProvider.user;
        if (user != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return; 
            if (user.userType == 'admin' || user.userType == 'superadmin') {
              Navigator.pushReplacementNamed(context, '/admin');
            } else {
              Navigator.pushReplacementNamed(context, '/home');
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}