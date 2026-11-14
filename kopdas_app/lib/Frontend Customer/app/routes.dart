import 'package:flutter/material.dart';

class Routes {
  Routes._();
  static const welcome = '/';
  static const register = '/register';
  static const login = '/login';
  static const home = '/home';
  static const explore = '/explore';
  static const manual = '/manual';
  static const cartList = '/carts';
  static const noCart = '/no-cart';
  static const menu = '/menu';
  static const customize = '/customize';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const validate = '/validate';
  static const changes = '/changes';
  static const request = '/request';
  static const waiting = '/waiting';
  static const rejected = '/rejected';
  static const adjust = '/adjust';
  static const reserve = '/reserve';
  static const bill = '/bill';
  static const expired = '/expired';
  static const paid = '/paid';
  static const making = '/making';
  static const ready = '/ready';
  static const pickupCode = '/pickup-code';
  static const arrive = '/arrive';
  static const verify = '/verify';
  static const handover = '/handover';
  static const done = '/done';
  static const review = '/review';
  static const end = '/end';
}

extension NavX on BuildContext {
  /// Buka layar di atas layar sekarang (tombol kembali tersedia).
  Future<Object?> push(String route) => Navigator.of(this).pushNamed(route);

  /// Ganti layar sekarang (untuk alur maju yang tidak boleh kembali).
  Future<Object?> replace(String route) =>
      Navigator.of(this).pushReplacementNamed(route);

  /// Kembali ke layar bernama [route] yang sudah ada di tumpukan.
  void backTo(String route) =>
      Navigator.of(this).popUntil(ModalRoute.withName(route));

  /// Hapus tumpukan sampai Home, lalu buka [route].
  void fromHome(String route) => Navigator.of(this)
      .pushNamedAndRemoveUntil(route, ModalRoute.withName(Routes.home));

  /// Hapus seluruh tumpukan lalu buka [route].
  void resetTo(String route) =>
      Navigator.of(this).pushNamedAndRemoveUntil(route, (_) => false);
}
