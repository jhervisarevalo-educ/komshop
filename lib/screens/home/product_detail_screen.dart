import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    const primaryColor = Color(0xFF1E3A8A);

    final bool isOutOfStock = product.stockQuantity <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          product.name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 260,
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    '₱${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isOutOfStock
                        ? 'Out of Stock'
                        : 'Stock: ${product.stockQuantity}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: isOutOfStock ? Colors.red : const Color.fromARGB(255, 74, 74, 74),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    product.description,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color.fromARGB(255, 90, 90, 90),
                    ),
                  ),

                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isOutOfStock ? Colors.grey : primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isOutOfStock
                ? null
                : () {
                    cartProvider.addToCart(product);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Added to cart',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: primaryColor,
                      ),
                    );
                  },
            child: Text(
              isOutOfStock ? 'Out of Stock' : 'Add to Cart',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}