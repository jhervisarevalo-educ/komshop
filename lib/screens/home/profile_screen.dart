import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';
import '../../providers/user_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _contactController;
  late TextEditingController _addressController;

  final FirestoreService _firestoreService = FirestoreService();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    _nameController = TextEditingController(text: user?.name ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _contactController = TextEditingController(text: user?.contactNo ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentUser = userProvider.user;
      if (currentUser == null) return;

      final updatedUser = UserModel(
        uid: currentUser.uid,
        name: _nameController.text.trim(),
        email: currentUser.email, 
        userType: currentUser.userType,
        contactNo: _contactController.text.trim().isEmpty
            ? null
            : _contactController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      await _firestoreService.updateUser(updatedUser);
      userProvider.setUser(updatedUser);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: const Color(0xFF1E3A8A),
        ),
      );
    } catch (e) {
      print('Error updating profile: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update profile')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: const Color.fromARGB(255, 255, 0, 0),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'Confirm Logout',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: Text(
                    'Are you sure you want to log out?',
                    style: GoogleFonts.poppins(fontSize: 14),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              );

              // If user confirmed
              if (confirm == true) {
                final userProvider =
                    Provider.of<UserProvider>(context, listen: false);
                await userProvider.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
