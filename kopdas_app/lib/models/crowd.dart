import 'package:flutter/material.dart';

enum CrowdLevel { sepi, sedang, ramai, sangatRamai }

extension CrowdLevelMeta on CrowdLevel {
  static CrowdLevel fromCode(int code) {
    switch (code) {
      case 1:
        return CrowdLevel.sepi;
      case 2:
        return CrowdLevel.sedang;
      case 3:
        return CrowdLevel.ramai;
      default:
        return CrowdLevel.sangatRamai;
    }
  }

  String get label {
    switch (this) {
      case CrowdLevel.sepi:
        return 'Sepi';
      case CrowdLevel.sedang:
        return 'Sedang';
      case CrowdLevel.ramai:
        return 'Ramai';
      case CrowdLevel.sangatRamai:
        return 'Sangat Ramai';
    }
  }

  Color get color {
    switch (this) {
      case CrowdLevel.sepi:
        return const Color(0xFF16A34A);
      case CrowdLevel.sedang:
        return const Color(0xFFEAB308);
      case CrowdLevel.ramai:
        return const Color(0xFFEF4444);
      case CrowdLevel.sangatRamai:
        return const Color(0xFF7F1D1D);
    }
  }

  Color get backgroundColor {
    switch (this) {
      case CrowdLevel.sepi:
        return const Color(0xFFDCFCE7);
      case CrowdLevel.sedang:
        return const Color(0xFFFEF9C3);
      case CrowdLevel.ramai:
        return const Color(0xFFFEE2E2);
      case CrowdLevel.sangatRamai:
        return const Color(0xFF7F1D1D);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case CrowdLevel.sepi:
        return const Color(0xFF14532D);
      case CrowdLevel.sedang:
        return const Color(0xFF854D0E);
      case CrowdLevel.ramai:
        return const Color(0xFFB91C1C);
      case CrowdLevel.sangatRamai:
        return Colors.white;
    }
  }

  IconData get icon {
    switch (this) {
      case CrowdLevel.sepi:
        return Icons.person_outline;
      case CrowdLevel.sedang:
        return Icons.people_outline;
      case CrowdLevel.ramai:
        return Icons.groups_outlined;
      case CrowdLevel.sangatRamai:
        return Icons.groups;
    }
  }

  String get description {
    switch (this) {
      case CrowdLevel.sepi:
        return 'Area relatif sepi, calon pembeli terbatas.';
      case CrowdLevel.sedang:
        return 'Keramaian sedang, peluang pembeli cukup stabil.';
      case CrowdLevel.ramai:
        return 'Area ramai, banyak calon pembeli di sekitar.';
      case CrowdLevel.sangatRamai:
        return 'Area sangat ramai, potensi pembeli tinggi.';
    }
  }
}

class CrowdGridPoint {
  final double lat;
  final double lng;
  final double intensity;

  const CrowdGridPoint({
    required this.lat,
    required this.lng,
    required this.intensity,
  });

  factory CrowdGridPoint.fromJson(Map<String, dynamic> json) {
    return CrowdGridPoint(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
      intensity: (json['intensity'] as num).toDouble(),
    );
  }
}

class CrowdPointInfo {
  final CrowdLevel level;
  final double intensity;
  final int? estimatedPeople;
  final int potentialScore;
  final String potentialLabel;
  final List<String> factors;
  final DateTime observedAt;

  const CrowdPointInfo({
    required this.level,
    required this.intensity,
    required this.estimatedPeople,
    required this.potentialScore,
    required this.potentialLabel,
    required this.factors,
    required this.observedAt,
  });

  factory CrowdPointInfo.fromJson(Map<String, dynamic> json) {
    return CrowdPointInfo(
      level: CrowdLevelMeta.fromCode((json['level_code'] as num).toInt()),
      intensity: (json['intensity'] as num).toDouble(),
      estimatedPeople: json['estimated_people'] != null
          ? (json['estimated_people'] as num).toInt()
          : null,
      potentialScore: (json['potential_score'] as num).toInt(),
      potentialLabel: json['potential_label'] as String? ?? '',
      factors: (json['factors'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      observedAt: DateTime.parse(json['observed_at'] as String).toLocal(),
    );
  }

  String get potentialDisplay {
    switch (potentialLabel) {
      case 'SANGAT_POTENSIAL':
        return 'Sangat Potensial';
      case 'POTENSIAL':
        return 'Potensial';
      case 'CUKUP_POTENSIAL':
        return 'Cukup Potensial';
      default:
        return 'Kurang Potensial';
    }
  }
}

class CrowdReport {
  final String dataLabel;
  final String source;
  final String disclaimer;
  final DateTime generatedAt;
  final int hourUsed;
  final int radiusM;
  final List<CrowdGridPoint> grid;
  final CrowdPointInfo point;

  const CrowdReport({
    required this.dataLabel,
    required this.source,
    required this.disclaimer,
    required this.generatedAt,
    required this.hourUsed,
    required this.radiusM,
    required this.grid,
    required this.point,
  });

  bool get isSimulation => dataLabel != 'REAL';

  factory CrowdReport.fromJson(Map<String, dynamic> json) {
    return CrowdReport(
      dataLabel: json['data_label'] as String? ?? 'SIMULASI',
      source: json['source'] as String? ?? '',
      disclaimer: json['disclaimer'] as String? ?? '',
      generatedAt: DateTime.parse(json['generated_at'] as String).toLocal(),
      hourUsed: (json['hour_used'] as num).toInt(),
      radiusM: (json['radius_m'] as num).toInt(),
      grid: (json['grid'] as List<dynamic>)
          .map((e) => CrowdGridPoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      point: CrowdPointInfo.fromJson(json['point'] as Map<String, dynamic>),
    );
  }
}
