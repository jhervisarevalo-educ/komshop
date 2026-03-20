import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../providers/cart_provider.dart';
import 'package:provider/provider.dart';

class CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: ListTile(
        leading: Image.network(
          item.imageUrl,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(item.name),
        subtitle: Text('Price: \$${item.price.toStringAsFixed(2)}\n'
            'Total: \$${(item.price * item.quantity).toStringAsFixed(2)}'),
        trailing: SizedBox(
          width: 120,
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () => cartProvider.decreaseQuantity(item.productId),
              ),
              Text(item.quantity.toString()),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => cartProvider.increaseQuantity(item.productId),
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () => cartProvider.removeFromCart(item.productId),
              ),
            ],
          ),
        ),
      ),
    );
  }
}