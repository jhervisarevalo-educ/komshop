import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/user_model.dart';
import '../../services/firestore_service.dart';

class ManageUsersScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Users', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<List<UserModel>>(
        stream: _firestoreService.getUsersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final users = snapshot.data!;
          if (users.isEmpty) return const Center(child: Text('No users found.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(user.name, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(user.email, style: GoogleFonts.poppins(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text('Role: ${user.userType}', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditDialog(context, user),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.name);
    final roleController = TextEditingController(text: user.userType);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit User', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: TextEditingController(text: user.email),
                decoration: const InputDecoration(labelText: 'Email'),
                readOnly: true,
              ),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Role'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () async {
              final updatedUser = UserModel(
                uid: user.uid,
                name: nameController.text.trim(),
                email: user.email,
                userType: roleController.text.trim(),
                contactNo: user.contactNo,
                address: user.address,
              );

              await _firestoreService.updateUser(updatedUser);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User updated successfully')),
              );
            },
            child: Text('Update', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}