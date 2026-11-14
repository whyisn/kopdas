import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/product.dart';

/// Gambar produk dengan prioritas: (1) URL backend, (2) placeholder sesuai
/// kategori. Aset lokal belum dibundel di proyek ini, sehingga placeholder
/// kategori dipakai bila URL kosong/gagal dimuat. Ikon placeholder dipilih
/// per kategori agar tidak menampilkan gambar yang tidak sesuai produk
/// (mis. ikon kopi untuk makanan).
class ProductImage extends StatelessWidget {
  final ProductModel product;
  final double iconSize;
  final BorderRadius borderRadius;

  const ProductImage({
    super.key,
    required this.product,
    this.iconSize = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
  });

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    if (url != null && url.isNotEmpty) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Image.network(
          url,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    final style = _styleFor(product);
    return ClipRRect(
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [style.base, style.light],
          ),
        ),
        child: Center(
          child: Icon(style.icon, size: iconSize, color: Colors.white),
        ),
      ),
    );
  }
}

class _CategoryStyle {
  final IconData icon;
  final Color base;
  final Color light;
  const _CategoryStyle(this.icon, this.base, this.light);
}

_CategoryStyle _styleFor(ProductModel p) {
  final cat = (p.categoryName ?? '').toLowerCase();
  final name = p.name.toLowerCase();

  if (cat.contains('makanan') ||
      name.contains('croissant') ||
      name.contains('brownies') ||
      name.contains('cake') ||
      name.contains('roti')) {
    return const _CategoryStyle(
      Icons.bakery_dining_outlined,
      Color(0xFFE76F51),
      Color(0xFFF4A261),
    );
  }

  if (name.contains('matcha')) {
    return const _CategoryStyle(
      Icons.eco_outlined,
      Color(0xFF2A9D8F),
      Color(0xFF6FBF9F),
    );
  }

  if (cat.contains('non-kopi') ||
      cat.contains('nonkopi') ||
      name.contains('tea') ||
      name.contains('teh') ||
      name.contains('chocolate') ||
      name.contains('cokelat') ||
      name.contains('lemon')) {
    return const _CategoryStyle(
      Icons.emoji_food_beverage_outlined,
      Color(0xFF3D6B99),
      Color(0xFF6FA8C7),
    );
  }

  return const _CategoryStyle(
    Icons.local_cafe_outlined,
    AppConstants.primaryColor,
    AppConstants.accentColor,
  );
}