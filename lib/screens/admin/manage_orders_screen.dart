import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/order_model.dart';
import '../../services/firestore_service.dart';

class ManageOrdersScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Orders', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<List<OrderModel>>(
        stream: _firestoreService.getAllOrdersStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('No orders found.'));

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Text(
                    'Order #${order.orderId}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Total: \$${order.totalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(fontSize: 14)),
                      const SizedBox(height: 2),
                      Text('Status: ${order.status}',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: order.status == 'completed' ? Colors.green : Colors.orange)),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (order.status != 'completed')
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          tooltip: 'Mark as Completed',
                          onPressed: () => _updateOrderStatus(context, order),
                        ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Delete Order',
                        onPressed: () => _deleteOrder(context, order),
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

  void _updateOrderStatus(BuildContext context, OrderModel order) async {
  try {
    await _firestoreService.updateOrderStatus(order.orderId, 'completed');

    for (final item in order.cartItems) {
      final productId = item.productId;
      final quantityOrdered = item.quantity;

      final product = await _firestoreService.getProductById(productId);
      if (product != null) {
        final newStock = (product.stockQuantity - quantityOrdered).clamp(0, 999999);
        await _firestoreService.updateProductStock(productId, newStock);
      }
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Order marked completed and stock updated'),
        backgroundColor: Color(0xFF1E3A8A),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update order: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  void _deleteOrder(BuildContext context, OrderModel order) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Order', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this order?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(
            child: Text('Cancel', style: GoogleFonts.poppins()),
            onPressed: () => Navigator.pop(context, false),
          ),
          TextButton(
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red),),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        if (order.orderId != null) {
          await _firestoreService.deleteOrder(order.orderId!);
        }

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order deleted successfully'),
            backgroundColor: Color(0xFF1E3A8A),
          ),
        );
      } catch (e) {
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}