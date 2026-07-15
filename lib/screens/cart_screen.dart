import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/cart_model.dart';
import '../theme.dart';

/// The cart / checkout screen. Lists lines, shows a price breakdown, and
/// "places" the order (mock — just shows a confirmation dialog).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                if (cart.restaurantName != null)
                  Container(
                    width: double.infinity,
                    color: AppColors.surface,
                    padding: const EdgeInsets.all(16),
                    child: Text('Order from ${cart.restaurantName}',
                        style:
                            const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final line in cart.lines)
                        _CartRow(line: line),
                    ],
                  ),
                ),
                _Summary(cart: cart),
              ],
            ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartModel>();
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Text(line.item.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(line.item.name,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text('\$${line.item.price.toStringAsFixed(2)} each',
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.primary,
            onPressed: () => cart.remove(line.item),
          ),
          Text('${line.quantity}',
              style: const TextStyle(fontWeight: FontWeight.w800)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
            onPressed: () => cart.increment(line.item),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.cart});
  final CartModel cart;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('Subtotal', cart.subtotal),
            const SizedBox(height: 6),
            _row('Delivery fee', cart.deliveryFee),
            const Divider(height: 24),
            _row('Total', cart.total, bold: true),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _placeOrder(context),
              child: Text('Place order • \$${cart.total.toStringAsFixed(2)}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, double value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 17 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
      color: bold ? AppColors.text : AppColors.textMuted,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('\$${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }

  void _placeOrder(BuildContext context) {
    final cart = context.read<CartModel>();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Order placed! 🎉'),
        content: Text(
          'Your order from ${cart.restaurantName} is on the way.\n\n'
          'Total: \$${cart.total.toStringAsFixed(2)}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              cart.clear();
              Navigator.of(dialogContext).pop(); // close dialog
              Navigator.of(context).popUntil((r) => r.isFirst); // to home
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🛒', style: TextStyle(fontSize: 48)),
          SizedBox(height: 12),
          Text('Your cart is empty',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16)),
        ],
      ),
    );
  }
}
