import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';

class ManageProductsScreen extends StatelessWidget {
  final FirestoreService _firestoreService = FirestoreService();

  ManageProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Manage Products', style: GoogleFonts.poppins()),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: StreamBuilder<List<ProductModel>>(
        stream: _firestoreService.getProductsStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data!;
          if (products.isEmpty) {
            return Center(
              child: Text('No products found.', style: GoogleFonts.poppins(fontSize: 16)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          product.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[300],
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.name,
                                style: GoogleFonts.poppins(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              '${product.category} • \$${product.price.toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Stock: ${product.stockQuantity}',
                              style: GoogleFonts.poppins(color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showProductDialog(context, product: product),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteProduct(context, product.id!),
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showProductDialog(context),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {ProductModel? product}) {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController = TextEditingController(text: product?.price.toString() ?? '');
    final categoryController = TextEditingController(text: product?.category ?? '');
    final descriptionController = TextEditingController(text: product?.description ?? '');
    final imageUrlController = TextEditingController(text: product?.imageUrl ?? '');
    final stockController = TextEditingController(text: product?.stockQuantity.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? 'Add Product' : 'Edit Product',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField('Name', nameController),
              _buildTextField('Price', priceController, keyboardType: TextInputType.number),
              _buildTextField('Category', categoryController),
              _buildTextField('Description', descriptionController),
              _buildTextField('Image URL', imageUrlController),
              _buildTextField('Stock Quantity', stockController, keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final price = double.tryParse(priceController.text.trim()) ?? 0;
              final category = categoryController.text.trim();
              final description = descriptionController.text.trim();
              final imageUrl = imageUrlController.text.trim();
              final stockQuantity = int.tryParse(stockController.text.trim()) ?? 0;

              if (name.isEmpty || price <= 0 || imageUrl.isEmpty || stockQuantity < 0) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('Please fill all required fields')));
                return;
              }

              final newProduct = ProductModel(
                id: product?.id,
                name: name,
                price: price,
                category: category,
                description: description,
                imageUrl: imageUrl,
                stockQuantity: stockQuantity,
              );

              if (product == null) {
                _firestoreService.addProduct(newProduct);
              } else {
                _firestoreService.updateProduct(newProduct);
              }

              Navigator.pop(context);
            },
            child: Text(product == null ? 'Add' : 'Update'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _deleteProduct(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Product', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this product?', style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: GoogleFonts.poppins())),
          TextButton(
            onPressed: () {
              _firestoreService.deleteProduct(productId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}