import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/order_model.dart';

class CartScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final items = cartProvider.items.values.toList();
    final currentUser = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: items.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                margin: const EdgeInsets.only(right: 12),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.remove_circle_outline),
                                          onPressed: () {
                                            cartProvider.decreaseQuantity(item.productId);
                                          },
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: GoogleFonts.poppins(fontSize: 14),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () {
                                            cartProvider.increaseQuantity(item.productId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    '₱${(item.price * item.quantity).toStringAsFixed(2)}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () {
                                      cartProvider.removeFromCart(item.productId);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '₱${cartProvider.totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E3A8A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3A8A),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: currentUser == null || items.isEmpty
                            ? null
                            : () async {
                                bool stockIssue = false;
                                String message = '';

                                for (var item in items) {
                                  final doc = await _firestoreService
                                      .getProductById(item.productId); 
                                  if (doc == null) {
                                    stockIssue = true;
                                    message = 'Product "${item.name}" not found.';
                                    break;
                                  }

                                  if (item.quantity > doc.stockQuantity) {
                                    stockIssue = true;
                                    message =
                                        'Not enough stock for "${item.name}". Available: ${doc.stockQuantity}';
                                    break;
                                  }
                                }

                                if (stockIssue) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(message),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                final order = OrderModel(
                                  orderId: '',
                                  userId: currentUser.uid!,
                                  cartItems: items,
                                  totalPrice: cartProvider.totalPrice,
                                  status: 'pending',
                                  createdAt: DateTime.now(),
                                );

                                try {
                                  await _firestoreService.createOrder(order);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Order confirmed!',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: const Color(0xFF1E3A8A),
                                    ),
                                  );
                                  cartProvider.clearCart();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Failed to confirm order: $e',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                          child: Text(
                            'Confirm Order',
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
              ],
            ),
    );
  }
}