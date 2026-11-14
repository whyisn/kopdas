import 'package:flutter/material.dart';

class CoffeeCart {
  final String id, name, spot, hours, tag;
  final String sellerId;
  final int baseDistance, reviews, waitMinutes;
  final double rating;
  final bool online;

  /// Posisi pin pada kanvas peta 340x200.
  final Offset pos;

  const CoffeeCart({
    required this.id,
    required this.name,
    required this.spot,
    required this.hours,
    this.sellerId = 'usr-seller-01',
    required this.baseDistance,
    required this.rating,
    required this.reviews,
    required this.tag,
    required this.waitMinutes,
    required this.online,
    required this.pos,
  });
}

class Area {
  final String name, district;

  /// Area demo yang tidak punya gerobak.
  final bool empty;
  const Area(this.name, this.district, {this.empty = false});
}
