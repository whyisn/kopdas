import 'package:flutter/material.dart';
import 'models/coffee_cart.dart';
import 'models/product.dart';

class MockData {
  MockData._();

  static const categories = ['Semua', 'Coffee', 'Non-Coffee', 'Tea'];

  static const menu = <Product>[
    Product(
      id: 'prd-01',
      category: 'Coffee',
      name: 'Kopi Susu Aren',
      description: 'Espresso, susu segar, dan gula aren organik Padang',
      price: 12000,
      color: Color(0xFF8A5A33),
      isDrink: true,
    ),
    Product(
      id: 'prd-02',
      category: 'Coffee',
      name: 'Americano',
      description: 'Double shot espresso dengan air dingin segar',
      price: 12000,
      color: Color(0xFF3B2A20),
      isDrink: true,
    ),
    Product(
      id: 'prd-03',
      category: 'Non-Coffee',
      name: 'Coklat',
      description: 'Coklat premium kental kaya rasa dengan steamed milk',
      price: 12000,
      color: Color(0xFF4A2C20),
      isDrink: true,
    ),
    Product(
      id: 'prd-04',
      category: 'Non-Coffee',
      name: 'Red Velvet',
      description: 'Red velvet lembut berpadu dengan foam susu gurih',
      price: 12000,
      color: Color(0xFF9E2A2B),
      isDrink: true,
    ),
    Product(
      id: 'prd-05',
      category: 'Tea',
      name: 'Thai Tea',
      description: 'Teh rempah Thailand otentik dengan susu manis',
      price: 8000,
      color: Color(0xFFB9763A),
      isDrink: true,
    ),
    Product(
      id: 'prd-06',
      category: 'Tea',
      name: 'Lemon Tea',
      description: 'Teh segar berpadu perasan sari lemon segar',
      price: 8000,
      color: Color(0xFFD9A62F),
      isDrink: true,
    ),
  ];

  static const favoriteIds = ['prd-01', 'prd-02', 'prd-05', 'prd-04'];

  static const sizes = <Option>[];
  static const temps = <String>[];
  static const sugars = <String>[];
  static const addons = <Option>[];

  static const pickupTimes = ['Secepatnya', '10 menit lagi', '20 menit lagi', '30 menit lagi'];
  static const reviewTags = ['Cepat', 'Enak', 'Ramah', 'Porsi pas', 'Harga cocok'];
  static const ratingLabels = ['', 'Kurang', 'Biasa saja', 'Lumayan', 'Enak', 'Luar biasa'];

  /// Daftar gerobak Kopi Cerdas operasional Padang
  static const carts = <CoffeeCart>[
    CoffeeCart(
      id: 'loc-01',
      sellerId: 'usr-seller-01',
      name: 'Gerobak UNP Air Tawar',
      spot: 'Jl. Prof. Dr. Hamka (Depan Gerbang Kampus UNP)',
      hours: '06.30–21.00 WIB',
      baseDistance: 150,
      rating: 4.9,
      reviews: 428,
      tag: 'Kopi Susu Aren Favorit Mahasiswa',
      waitMinutes: 4,
      online: true,
      pos: Offset(228, 66),
    ),
    CoffeeCart(
      id: 'loc-02',
      sellerId: 'usr-seller-02',
      name: 'Gerobak Khatib Sulaiman',
      spot: 'Jl. Khatib Sulaiman (Sentra Perkantoran Padang)',
      hours: '07.00–18.00 WIB',
      baseDistance: 380,
      rating: 4.8,
      reviews: 312,
      tag: 'Americano & Kopi Cepat Jam Kantor',
      waitMinutes: 5,
      online: true,
      pos: Offset(104, 62),
    ),
    CoffeeCart(
      id: 'loc-03',
      sellerId: 'usr-seller-03',
      name: 'Gerobak Pasar Raya Padang',
      spot: 'Jl. Sandang Pangan (Pintu Barat Pasar Raya)',
      hours: '06.00–17.00 WIB',
      baseDistance: 750,
      rating: 4.7,
      reviews: 195,
      tag: 'Teh Tarik & Kopi Susu Mantap',
      waitMinutes: 8,
      online: true,
      pos: Offset(262, 156),
    ),
    CoffeeCart(
      id: 'loc-04',
      sellerId: 'usr-seller-04',
      name: 'Gerobak Pantai Taplau',
      spot: 'Kawasan Wisata Pantai Padang (Sore - Malam)',
      hours: '14.00–22.00 WIB',
      baseDistance: 1100,
      rating: 4.9,
      reviews: 580,
      tag: 'Kopi Sunset & Lemon Tea Dingin',
      waitMinutes: 6,
      online: true,
      pos: Offset(170, 34),
    ),
  ];

  static const areas = <Area>[
    Area('Padang Utara', 'Air Tawar, Lolong Belanti'),
    Area('Padang Barat', 'Kampung Jao, Purus, Pantai'),
    Area('Padang Timur', 'Sawahan, Simpang Haru'),
    Area('Kuranji', 'Belimbing (Belum ada gerobak)', empty: true),
  ];

  static const rejectReasons = [
    'Susu segar sedang habis di gerobak, stok baru sedang diantar dari gudang pusat.',
    'Antrean gerobak sedang penuh, mohon pesan kembali 10 menit lagi.',
    'Gerobak sedang berpindah titik mangkal sementara.',
  ];
}
