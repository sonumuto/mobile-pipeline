import 'package:flutter/foundation.dart';
import '../models/models.dart';

/// One line in the cart: a menu item plus how many of it.
class CartLine {
  CartLine({required this.item, this.quantity = 1});

  final MenuItem item;
  int quantity;

  double get lineTotal => item.price * quantity;
}

/// App-wide cart. Provided near the top of the widget tree with `provider`.
///
/// The cart is restricted to a single restaurant at a time (like most delivery
/// apps): adding an item from a different restaurant clears the previous order.
class CartModel extends ChangeNotifier {
  final Map<String, CartLine> _lines = {};
  String? _restaurantId;
  String? _restaurantName;
  double _deliveryFee = 0;

  List<CartLine> get lines => _lines.values.toList(growable: false);

  String? get restaurantName => _restaurantName;

  bool get isEmpty => _lines.isEmpty;

  int get totalCount =>
      _lines.values.fold(0, (sum, line) => sum + line.quantity);

  double get subtotal =>
      _lines.values.fold(0.0, (sum, line) => sum + line.lineTotal);

  double get deliveryFee => isEmpty ? 0 : _deliveryFee;

  double get total => subtotal + deliveryFee;

  int quantityOf(String menuItemId) => _lines[menuItemId]?.quantity ?? 0;

  /// Adds one of [item]. If [item] belongs to a different restaurant than the
  /// current cart, the cart is reset first.
  void add(MenuItem item, Restaurant restaurant) {
    if (_restaurantId != null && _restaurantId != restaurant.id) {
      _lines.clear();
    }
    _restaurantId = restaurant.id;
    _restaurantName = restaurant.name;
    _deliveryFee = restaurant.deliveryFee;

    final existing = _lines[item.id];
    if (existing == null) {
      _lines[item.id] = CartLine(item: item);
    } else {
      existing.quantity += 1;
    }
    notifyListeners();
  }

  /// Increments an item already in the cart. No-op if it isn't present.
  /// Used by the cart screen where the restaurant context is implicit.
  void increment(MenuItem item) {
    final existing = _lines[item.id];
    if (existing == null) return;
    existing.quantity += 1;
    notifyListeners();
  }

  /// Removes one of [item]; drops the line entirely when it hits zero.
  void remove(MenuItem item) {
    final existing = _lines[item.id];
    if (existing == null) return;
    existing.quantity -= 1;
    if (existing.quantity <= 0) {
      _lines.remove(item.id);
    }
    if (_lines.isEmpty) {
      _restaurantId = null;
      _restaurantName = null;
    }
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    _restaurantId = null;
    _restaurantName = null;
    notifyListeners();
  }
}
