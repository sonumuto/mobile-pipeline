import 'package:flutter_test/flutter_test.dart';
import 'package:food_delivery_app/data/mock_data.dart';
import 'package:food_delivery_app/models/models.dart';
import 'package:food_delivery_app/state/cart_model.dart';

// Fixtures with known prices/fees, so totals can be asserted exactly rather
// than recomputed from kRestaurants.
const _burger = MenuItem(
  id: 'b1',
  name: 'Burger',
  description: 'Beef patty',
  price: 10.0,
  emoji: '🍔',
);
const _fries = MenuItem(
  id: 'f1',
  name: 'Fries',
  description: 'Salted',
  price: 4.5,
  emoji: '🍟',
);
const _sushi = MenuItem(
  id: 's1',
  name: 'Sushi',
  description: 'Salmon nigiri',
  price: 20.0,
  emoji: '🍣',
);

const _grill = Restaurant(
  id: 'r1',
  name: 'Grill House',
  cuisine: 'Burgers',
  emoji: '🍔',
  rating: 4.5,
  deliveryMinutes: 30,
  deliveryFee: 5.0,
  menu: [_burger, _fries],
);
const _sakura = Restaurant(
  id: 'r2',
  name: 'Sakura',
  cuisine: 'Japanese',
  emoji: '🍣',
  rating: 4.8,
  deliveryMinutes: 40,
  deliveryFee: 7.5,
  menu: [_sushi],
);

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

  group('CartLine', () {
    test('lineTotal multiplies price by quantity', () {
      expect(CartLine(item: _burger, quantity: 3).lineTotal, closeTo(30.0, 0.001));
    });

    test('defaults to a quantity of one', () {
      expect(CartLine(item: _burger).quantity, 1);
    });
  });

  group('CartModel.increment', () {
    test('raises the quantity of an item already in the cart', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.increment(_burger);

      expect(cart.quantityOf(_burger.id), 2);
      expect(cart.subtotal, closeTo(20.0, 0.001));
    });

    test('is a no-op for an item that is not in the cart', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.increment(_fries);

      expect(cart.quantityOf(_fries.id), 0);
      expect(cart.totalCount, 1);
    });
  });

  group('CartModel.remove', () {
    test('decrements without dropping the line when quantity exceeds one', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.add(_burger, _grill);
      cart.remove(_burger);

      expect(cart.quantityOf(_burger.id), 1);
      expect(cart.lines, hasLength(1));
      expect(cart.isEmpty, false);
    });

    test('drops only the emptied line, leaving others intact', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.add(_fries, _grill);
      cart.remove(_burger);

      expect(cart.quantityOf(_burger.id), 0);
      expect(cart.quantityOf(_fries.id), 1);
      expect(cart.restaurantName, _grill.name);
    });

    test('is a no-op for an item that is not in the cart', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.remove(_fries);

      expect(cart.totalCount, 1);
    });
  });

  group('CartModel.clear', () {
    test('empties the cart and forgets the restaurant', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.add(_fries, _grill);
      cart.clear();

      expect(cart.isEmpty, true);
      expect(cart.totalCount, 0);
      expect(cart.subtotal, 0);
      expect(cart.total, 0);
      expect(cart.deliveryFee, 0);
      expect(cart.restaurantName, isNull);
    });

    test('leaves the cart usable for a different restaurant afterwards', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      cart.clear();
      cart.add(_sushi, _sakura);

      expect(cart.restaurantName, _sakura.name);
      expect(cart.totalCount, 1);
      expect(cart.deliveryFee, closeTo(7.5, 0.001));
    });
  });

  group('CartModel.deliveryFee', () {
    test('is zero while the cart is empty', () {
      expect(CartModel().deliveryFee, 0);
    });

    test('follows the restaurant the cart switched to', () {
      final cart = CartModel();
      cart.add(_burger, _grill);
      expect(cart.deliveryFee, closeTo(5.0, 0.001));

      cart.add(_sushi, _sakura);
      expect(cart.deliveryFee, closeTo(7.5, 0.001));
      expect(cart.total, closeTo(27.5, 0.001));
    });
  });

  group('CartModel.quantityOf', () {
    test('returns zero for an unknown item id', () {
      expect(CartModel().quantityOf('nope'), 0);
    });
  });

  group('CartModel notifications', () {
    test('add, increment, remove and clear each notify listeners', () {
      final cart = CartModel();
      var notifications = 0;
      cart.addListener(() => notifications++);

      cart.add(_burger, _grill);
      expect(notifications, 1);

      cart.increment(_burger);
      expect(notifications, 2);

      cart.remove(_burger);
      expect(notifications, 3);

      cart.clear();
      expect(notifications, 4);
    });

    test('no-op increment and remove do not notify listeners', () {
      final cart = CartModel();
      var notifications = 0;
      cart.addListener(() => notifications++);

      cart.increment(_fries);
      cart.remove(_fries);

      expect(notifications, 0);
    });
  });
}
