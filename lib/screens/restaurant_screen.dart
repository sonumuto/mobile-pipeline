import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';
import '../state/cart_model.dart';
import '../theme.dart';
import 'cart_screen.dart';

/// Shows a restaurant's header info and its menu. Each menu row can be
/// added to / removed from the cart. A bottom bar appears when the cart
/// has items.
class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key, required this.restaurant});

  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(restaurant.name)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          _Header(restaurant: restaurant),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text('Menu',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          ),
          for (final item in restaurant.menu)
            _MenuRow(item: item, restaurant: restaurant),
        ],
      ),
      bottomNavigationBar: const _ViewCartBar(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(restaurant.emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(restaurant.name,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(restaurant.cuisine,
                    style: const TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.star),
                    const SizedBox(width: 4),
                    Text(restaurant.rating.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(width: 14),
                    const Icon(Icons.access_time,
                        size: 16, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text('${restaurant.deliveryMinutes} min',
                        style: const TextStyle(color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item, required this.restaurant});
  final MenuItem item;
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final qty = context.select<CartModel, int>((c) => c.quantityOf(item.id));
    return Container(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 1),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(item.emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(item.description,
                    style: const TextStyle(
                        color: AppColors.textMuted, fontSize: 13)),
                const SizedBox(height: 8),
                Text('\$${item.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QtyControl(item: item, restaurant: restaurant, quantity: qty),
        ],
      ),
    );
  }
}

/// Either an "Add" button (when quantity is zero) or a −/count/+ stepper.
class _QtyControl extends StatelessWidget {
  const _QtyControl({
    required this.item,
    required this.restaurant,
    required this.quantity,
  });

  final MenuItem item;
  final Restaurant restaurant;
  final int quantity;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartModel>();
    if (quantity == 0) {
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        onPressed: () => cart.add(item, restaurant),
        child: const Text('Add'),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _RoundIcon(icon: Icons.remove, onTap: () => cart.remove(item)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text('$quantity',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800)),
          ),
          _RoundIcon(
              icon: Icons.add, onTap: () => cart.add(item, restaurant)),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

/// Sticky bar that jumps to the cart; hidden when the cart is empty.
class _ViewCartBar extends StatelessWidget {
  const _ViewCartBar();

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartModel>();
    if (cart.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CartScreen()),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${cart.totalCount} item(s)'),
              const Text('View cart'),
              Text('\$${cart.subtotal.toStringAsFixed(2)}'),
            ],
          ),
        ),
      ),
    );
  }
}
