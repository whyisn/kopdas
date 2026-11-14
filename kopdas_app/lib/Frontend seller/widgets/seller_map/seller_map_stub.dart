import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../../../models/location.dart';
import 'seller_map_controller.dart';

/// Fallback non-web: peta interaktif memerlukan versi web (iframe Leaflet).
/// Halaman tetap berfungsi — koordinat & daftar lokasi tersimpan masih tampil,
/// dan penyimpanan lokasi tetap dapat dilakukan.
class SellerMapView extends StatelessWidget {
  final SellerMapController controller;
  final double initialLat;
  final double initialLng;
  final int initialZoom;
  final double? pinLat;
  final double? pinLng;
  final List<LocationModel> initialSaved;

  const SellerMapView({
    super.key,
    required this.controller,
    required this.initialLat,
    required this.initialLng,
    this.initialZoom = 15,
    this.pinLat,
    this.pinLng,
    this.initialSaved = const [],
  });

  @override
  Widget build(BuildContext context) {
    final lat = pinLat ?? initialLat;
    final lng = pinLng ?? initialLng;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6F4E37), Color(0xFF4A3525)],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.map_outlined,
                    size: 38, color: AppConstants.backgroundColor),
              ),
              const SizedBox(height: 18),
              const Text(
                'Peta interaktif tersedia di versi web',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Buka aplikasi melalui browser untuk menggeser pin, mencari alamat, '
                'dan melihat heatmap keramaian. Penyimpanan lokasi tetap dapat '
                'dilakukan dari panel di samping.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 12.5,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                  style: const TextStyle(
                    color: AppConstants.backgroundColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
