import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _loading = false;

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w]{2,4}$').hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _authService.sendPasswordResetEmail(
        _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Password reset email sent!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
      );

      Navigator.pop(context); 
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to send reset email',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Reset Password",
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Enter your email and we’ll send\nyou a reset link",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),

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
                          borderSide: const BorderSide(
                            color: Color(0xFF1E3A8A),
                            width: 3,
                          ),
                        ),
                      ),
                      validator: validateEmail,
                    ),

                    const SizedBox(height: 30),

                    SizedBox(
                      width: double.infinity,
                      child: _loading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: const Color(0xFF1E3A8A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _resetPassword,
                              child: Text(
                                "Send Reset Link",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        "Back to Login",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E3A8A),
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