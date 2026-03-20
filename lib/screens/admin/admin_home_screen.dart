import 'package:flutter/material.dart';
import 'package:komshop/screens/admin/manage_orders_screen.dart';
import 'package:komshop/screens/admin/manage_products_screen.dart';
import 'package:komshop/screens/admin/manage_users_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  int totalProducts = 0;
  int totalOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;

  final FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _loadDashboardCounts();
  }

  Future<void> _loadDashboardCounts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _firestoreService.getTotalProducts();
      final orders = await _firestoreService.getTotalOrders();
      final pending = await _firestoreService.getPendingOrders();
      final completed = await _firestoreService.getCompletedOrders();

      setState(() {
        totalProducts = products;
        totalOrders = orders;
        pendingOrders = pending;
        completedOrders = completed;
      });
    } catch (e) {
      print('Error loading dashboard counts: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _confirmLogout() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Logout', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to logout?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Logout', style: GoogleFonts.poppins(color: Colors.red)),
            onPressed: () async {
              await userProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _buildDashboardTab(),
      ManageProductsScreen(),
      ManageUsersScreen(),
      ManageOrdersScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Admin Dashboard', style: GoogleFonts.poppins(fontSize: 18, color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        actions: [
          IconButton(
            color: const Color.fromARGB(255, 255, 17, 0),
            icon: const Icon(Icons.logout),
            onPressed: _confirmLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey,
        onTap: (index) async {
          setState(() => _currentIndex = index);

          if (index == 0) {
            await _loadDashboardCounts();
          }
        },
                
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.inventory_2), label: 'Products'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Users'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Orders'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatCard('Products', totalProducts, Colors.blue),
          const SizedBox(height: 16),
          _buildStatCard('Orders', totalOrders, Colors.orange),
          const SizedBox(height: 16),
          _buildStatCard('Pending', pendingOrders, Colors.red),
          const SizedBox(height: 16),
          _buildStatCard('Completed', completedOrders, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, int count, Color color) {
    return Container(
      width: double.infinity, 
      height: 150,
      child: Card(
        color: color.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                count.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 27),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 25,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}