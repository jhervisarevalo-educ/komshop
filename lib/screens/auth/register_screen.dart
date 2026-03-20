import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'login_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  String? validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your name';
    return null;
  }

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
                      "Create Account",
                      style: GoogleFonts.poppins(
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Sign up to get started!",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 50),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
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
                      validator: validateName,
                    ),
                    SizedBox(height: 20),

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
                                "Register",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  setState(() => _loading = true);
                                  try {
                                    await userProvider.register(
                                      _nameController.text,
                                      _emailController.text,
                                      _passwordController.text,
                                    );

                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => LoginScreen(),
                                        ),
                                      );
                                    });
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Registration failed. ${e.toString()}"),
                                        backgroundColor: Colors.redAccent,
                                        behavior: SnackBarBehavior.floating,
                                        margin: EdgeInsets.all(16),
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  } finally {
                                    setState(() => _loading = false);
                                  }
                                }
                              },
                            ),
                    ),

                    SizedBox(height: 20),

                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Already have an account",
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