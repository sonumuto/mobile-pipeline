import 'package:flutter/foundation.dart';

/// A single dish that a restaurant sells.
@immutable
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.emoji,
  });

  final String id;
  final String name;
  final String description;
  final double price; // in local currency units
  final String emoji; // stand-in for a food image

  @override
  bool operator ==(Object other) => other is MenuItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

/// A restaurant with a menu.
@immutable
class Restaurant {
  const Restaurant({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.emoji,
    required this.rating,
    required this.deliveryMinutes,
    required this.deliveryFee,
    required this.menu,
  });

  final String id;
  final String name;
  final String cuisine;
  final String emoji; // stand-in for a logo/cover image
  final double rating;
  final int deliveryMinutes;
  final double deliveryFee;
  final List<MenuItem> menu;
}
