import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'register_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your password';
    if (value.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Login here",
                      style: GoogleFonts.poppins(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Welcome back, glad to \nsee you again!",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),

                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF1E3A8A),
                            width: 3,
                          ),
                        ),
                      ),
                      validator: validateEmail,
                    ),
                    SizedBox(height: 20),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Password",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Color(0xFF1E3A8A),
                            width: 3,
                          ),
                        ),
                      ),
                      validator: validatePassword,
                    ),
                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/reset');
                        },
                        child: Text(
                          "Forgot your password?",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: _loading
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: Color(0xFF1E3A8A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                "Login",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;

                                setState(() => _loading = true);

                                try {
                                  await userProvider.login(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );

                                  await userProvider.loadUser();

                                  final user = userProvider.user;
                                  if (user == null) {
                                    if (!mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('User data not found.')),
                                    );
                                    return;
                                  }

                                  final type = user.userType;

                                  if (!mounted) return;
                                  if (type == 'admin' || type == 'superadmin') {
                                    Navigator.pushReplacementNamed(context, '/admin');
                                  } else {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  }
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Login failed. Invalid credentials."),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.all(16),
                                      duration: Duration(seconds: 3),
                                    ),
                                  );
                                } finally {
                                  if (mounted) setState(() => _loading = false);
                                }
                              },
                            ),
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Create an account",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}