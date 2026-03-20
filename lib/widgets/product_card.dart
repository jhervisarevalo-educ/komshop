import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback? onTap;

  ProductCard({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Color(0xFF1E3A8A), // 👈 border color
          width: 0.3,  
        )
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Padding(
              padding: EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        width: double.infinity,
                        height: 120,
                        fit: BoxFit.contain,
                      )
                    : Container(
                        width: double.infinity,
                        height: 120,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
              ),
            ),

            Divider(
              thickness: 1,
              color: const Color.fromARGB(255, 190, 190, 190),
              height: 10, 
            ),

            // Product Details
            Padding(
              padding: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '₱ ${product.price.toStringAsFixed(2)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A)
                      ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}