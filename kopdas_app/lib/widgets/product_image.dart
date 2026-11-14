import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Gambar produk dengan fallback aset bawaan, decoding hemat memori (cacheWidth),
/// dan resolusi URL relatif terhadap origin backend (mis. /static/products/x.jpg).
class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final int? cacheWidth;
  final BoxFit fit;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.cacheWidth,
    this.fit = BoxFit.cover,
  });

  static const String fallbackAsset = 'assets/images/product_placeholder.jpg';

  static String? resolveUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    final base = Uri.parse(AppConstants.apiBaseUrl);
    return base.replace(path: url, query: null, fragment: null).toString();
  }

  @override
  Widget build(BuildContext context) {
    final url = resolveUrl(imageUrl);
    if (url == null) return _fallback();
    return Image.network(
      url,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          color: const Color(0xFFF3E6CC),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppConstants.accentColor,
            ),
          ),
        );
      },
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      fallbackAsset,
      fit: fit,
      cacheWidth: cacheWidth,
      gaplessPlayback: true,
    );
  }
}
