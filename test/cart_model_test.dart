import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/data/mock_data.dart';
import 'package:food_delivery_app/state/cart_model.dart';

void main() {
  group('CartModel', () {
    test('adds items and computes totals', () {
      final cart = CartModel();
      final r = kRestaurants.first;
      cart.add(r.menu[0], r);
      cart.add(r.menu[0], r); // same item twice
      cart.add(r.menu[1], r);

      expect(cart.totalCount, 3);
      expect(cart.quantityOf(r.menu[0].id), 2);
      expect(cart.subtotal,
          closeTo(r.menu[0].price * 2 + r.menu[1].price, 0.001));
      expect(cart.total, closeTo(cart.subtotal + r.deliveryFee, 0.001));
    });

    test('switching restaurant clears the cart', () {
      final cart = CartModel();
      final a = kRestaurants[0];
      final b = kRestaurants[1];
      cart.add(a.menu[0], a);
      cart.add(b.menu[0], b);

      expect(cart.restaurantName, b.name);
      expect(cart.totalCount, 1);
    });

    test('removing the last item empties the cart', () {
      final cart = CartModel();
      final r = kRestaurants.first;
      cart.add(r.menu[0], r);
      cart.remove(r.menu[0]);

      expect(cart.isEmpty, true);
      expect(cart.deliveryFee, 0);
      expect(cart.restaurantName, isNull);
    });
  });
}
