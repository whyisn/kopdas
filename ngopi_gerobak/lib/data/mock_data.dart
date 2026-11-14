import 'package:flutter/material.dart';
import 'models/coffee_cart.dart';
import 'models/product.dart';

class MockData {
  MockData._();

  static const categories = ['Semua', 'Kopi', 'Non-Kopi', 'Camilan'];

  static const menu = <Product>[
    Product(id: 'ksa', category: 'Kopi', name: 'Kopi Susu Aren', description: 'Espresso, susu segar, gula aren', price: 18000, color: Color(0xFF8A5A33), isDrink: true),
    Product(id: 'amer', category: 'Kopi', name: 'Americano', description: 'Double shot, air, es batu', price: 15000, color: Color(0xFF3B2A20), isDrink: true),
    Product(id: 'latte', category: 'Kopi', name: 'Cafe Latte', description: 'Espresso dan susu steam halus', price: 22000, color: Color(0xFFA47B57), isDrink: true),
    Product(id: 'vdrip', category: 'Kopi', name: 'Vietnam Drip', description: 'Seduh tetes dengan susu kental manis', price: 20000, color: Color(0xFF5A3A26), isDrink: true),
    Product(id: 'matcha', category: 'Non-Kopi', name: 'Matcha Latte', description: 'Matcha Uji, susu, sedikit madu', price: 24000, color: Color(0xFF6F9E4F), isDrink: true),
    Product(id: 'coklat', category: 'Non-Kopi', name: 'Cokelat Panas', description: 'Cokelat batang, susu, taburan kakao', price: 20000, color: Color(0xFF4A2C20), isDrink: true),
    Product(id: 'tarik', category: 'Non-Kopi', name: 'Teh Tarik', description: 'Teh kental dan susu, ditarik dua kali', price: 15000, color: Color(0xFFB9763A), isDrink: true),
    Product(id: 'roti', category: 'Camilan', name: 'Roti Bakar Cokelat', description: 'Roti tebal, cokelat, keju parut', price: 15000, color: Color(0xFFD49A4A)),
    Product(id: 'pisgor', category: 'Camilan', name: 'Pisang Goreng', description: 'Renyah, isi 4 potong', price: 12000, color: Color(0xFFD9A62F)),
  ];

  static const favoriteIds = ['ksa', 'matcha', 'tarik', 'roti'];

  static const sizes = <Option>[Option('Reguler'), Option('Besar', 4000)];
  static const temps = ['Dingin', 'Panas'];
  static const sugars = ['Normal', 'Kurang manis', 'Tanpa gula'];
  static const addons = <Option>[
    Option('Tambah shot espresso', 5000),
    Option('Susu oat', 6000),
    Option('Boba aren', 5000),
  ];

  static const pickupTimes = ['Secepatnya', '10 menit lagi', '20 menit lagi', '30 menit lagi'];
  static const reviewTags = ['Cepat', 'Enak', 'Ramah', 'Porsi pas', 'Harga cocok'];
  static const ratingLabels = ['', 'Kurang', 'Biasa saja', 'Lumayan', 'Enak', 'Luar biasa'];

  /// online:false = gerobak offline, tidak tampil di daftar.
  static const carts = <CoffeeCart>[
    CoffeeCart(id: 'c1', name: 'Kopi Pak Darto', spot: 'Depan halte Transjakarta', hours: '07.00–21.00', baseDistance: 120, rating: 4.8, reviews: 312, tag: 'Kopi susu aren', waitMinutes: 5, online: true, pos: Offset(228, 66)),
    CoffeeCart(id: 'c2', name: 'Gerobak Sore', spot: 'Samping taman kota', hours: '14.00–22.00', baseDistance: 350, rating: 4.6, reviews: 148, tag: 'Teh tarik dan roti bakar', waitMinutes: 8, online: true, pos: Offset(104, 62)),
    CoffeeCart(id: 'c3', name: 'Seduh Keliling Mbak Ayu', spot: 'Pojok pasar pagi', hours: '05.00–12.00', baseDistance: 600, rating: 4.9, reviews: 521, tag: 'Vietnam drip', waitMinutes: 12, online: true, pos: Offset(262, 156)),
    CoffeeCart(id: 'c4', name: 'Es Kopi Mang Ujang', spot: 'Depan minimarket', hours: '10.00–20.00', baseDistance: 850, rating: 4.5, reviews: 97, tag: 'Es kopi hitam', waitMinutes: 4, online: false, pos: Offset(84, 148)),
    CoffeeCart(id: 'c5', name: 'Kopi Roda Biru', spot: 'Dekat stasiun', hours: '06.00–22.00', baseDistance: 1200, rating: 4.7, reviews: 203, tag: 'Matcha dan cokelat', waitMinutes: 6, online: true, pos: Offset(170, 34)),
  ];

  static const areas = <Area>[
    Area('Sudirman', 'Jakarta Pusat'),
    Area('Menteng', 'Jakarta Pusat'),
    Area('Kota Tua', 'Jakarta Barat'),
    Area('Senayan', 'Jakarta Selatan'),
    Area('Kemang', 'Jakarta Selatan'),
    Area('Blok M', 'Jakarta Selatan'),
    Area('Kelapa Gading', 'Jakarta Utara'),
    Area('Cakung', 'Jakarta Timur', empty: true),
  ];

  static const rejectReasons = [
    'Susu segar sedang habis, jadi gerobak belum bisa membuat minuman berbahan susu.',
    'Antrean sedang penuh dan gerobak tidak menerima pesanan baru.',
    'Gerobak sedang pindah lapak dan tutup sementara.',
  ];
}
