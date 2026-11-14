import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/constants.dart';

/// Tingkat keramaian dengan gradasi warna:
/// biru (sepi) → hijau (sedang) → kuning (ramai) → merah (sangat ramai).
enum CrowdLevel {
  veryQuiet('Sangat Sepi', Color(0xFF1D4ED8)),
  quiet('Sepi', Color(0xFF3B82F6)),
  moderate('Sedang', Color(0xFF22C55E)),
  busy('Ramai', Color(0xFFF59E0B)),
  veryBusy('Sangat Ramai', Color(0xFFEF4444));

  const CrowdLevel(this.label, this.color);
  final String label;
  final Color color;

  /// Klasifikasi dari kepadatan ternormalisasi 0..1 (mis. footfall/POI yang
  /// diskalakan terhadap rentang historis). Struktur siap pakai begitu sumber
  /// data keramaian yang dapat dipertanggungjawabkan tersedia.
  static CrowdLevel fromIntensity(double value) {
    final x = value.clamp(0.0, 1.0);
    if (x < 0.2) return CrowdLevel.veryQuiet;
    if (x < 0.4) return CrowdLevel.quiet;
    if (x < 0.6) return CrowdLevel.moderate;
    if (x < 0.8) return CrowdLevel.busy;
    return CrowdLevel.veryBusy;
  }
}

/// Satu titik data keramaian berkoordinat dengan intensitas 0..1 dan waktu
/// observasi. Saat ini belum ada sumber data nyata, sehingga daftar titik
/// kosong sampai API kepadatan terhubung. Tidak ada nilai yang dikarang.
class CrowdPoint {
  final LatLng point;
  final double intensity;
  final DateTime observedAt;

  const CrowdPoint({
    required this.point,
    required this.intensity,
    required this.observedAt,
  });
}

/// Overlay heatmap keramaian: lingkaran translucent bergradasi warna pada
/// koordinat data nyata. Bila [points] kosong, tidak menggambar apa pun.
class CrowdDensityOverlay extends StatelessWidget {
  final List<CrowdPoint> points;
  final double radiusMeters;

  const CrowdDensityOverlay({
    super.key,
    required this.points,
    this.radiusMeters = 140,
  });

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    return CircleLayer(
      circles: [
        for (final p in points)
          CircleMarker(
            point: p.point,
            radius: radiusMeters,
            useRadiusInMeter: true,
            color: CrowdLevel.fromIntensity(p.intensity)
                .color
                .withValues(alpha: 0.35),
            borderStrokeWidth: 1,
            borderColor: CrowdLevel.fromIntensity(p.intensity)
                .color
                .withValues(alpha: 0.6),
          ),
      ],
    );
  }
}

/// Legenda gradasi keramaian (kunci warna). Dipakai bersama status ketersediaan
/// data agar pengguna memahami arti warna tanpa mengklaim angka aktual.
class CrowdDensityLegend extends StatelessWidget {
  const CrowdDensityLegend({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final level in CrowdLevel.values)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: level.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: level.color.withValues(alpha: 0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: level.color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  level.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.textDark,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}