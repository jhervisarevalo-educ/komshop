import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';
import '../../services/auth_service.dart';

class OrderHistoryScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthService _authService = AuthService();

  OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order History')),
        body: Center(
          child: Text(
            'You must be logged in to view orders',
            style: GoogleFonts.poppins(fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Order History', 
          style: GoogleFonts.poppins(
            fontSize: 18, 
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firestoreService.getOrdersStreamForUser(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}', 
                style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
              ),
            );
          }

          final orders = snapshot.data;
          if (orders == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (orders.isEmpty) {
            return Center(
              child: Text(
                'No orders yet',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Order #${order.orderId.substring(0, 6)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: order.status == 'completed'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.status.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: order.status == 'completed'
                                    ? Colors.green[800]
                                    : Colors.orange[800],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Placed on: ${order.createdAt.toLocal().toString().split(' ')[0]}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 8),

                      Column(
                        children: order.cartItems.take(2).map((item) {
                          return Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.grey[200],
                                  image: DecorationImage(
                                    image: NetworkImage(item.imageUrl),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  '${item.name} x${item.quantity}',
                                  style: GoogleFonts.poppins(fontSize: 14),
                                ),
                              ),
                              Text(
                                '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),

                      if (order.cartItems.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '+${order.cartItems.length - 2} more items',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Total: ',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₱${order.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}