import 'package:flutter/material.dart';

class Product {
  final String id, category, name, description;
  final int price;
  final Color color;
  final bool isDrink;
  const Product({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.color,
    this.isDrink = false,
  });
}

/// Opsi dengan harga tambahan (ukuran, add-on).
class Option {
  final String name;
  final int extra;
  const Option(this.name, [this.extra = 0]);
}
