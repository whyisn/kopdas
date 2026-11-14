import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Lokasi jualan yang dipilih Seller, disimpan lokal di perangkat.
///
/// Backend belum menyediakan endpoint tulis lokasi (GET /locations saja),
/// sehingga penyimpanan memakai shared_preferences agar titik yang dipilih
/// tetap persisten ketika Seller membuka kembali halaman. Lihat laporan
/// kebutuhan API untuk kontrak tulis lokasi yang diperlukan.
class SavedLocation {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime updatedAt;

  const SavedLocation({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'updated_at': updatedAt.toUtc().toIso8601String(),
      };

  factory SavedLocation.fromJson(Map<String, dynamic> json) => SavedLocation(
        name: (json['name'] as String?) ?? '',
        address: (json['address'] as String?) ?? '',
        latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
        longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
        updatedAt: DateTime.tryParse('${json['updated_at']}')?.toUtc() ??
            DateTime.now().toUtc(),
      );
}

class LocationStorage {
  static const _key = 'seller_location_v1';

  Future<SavedLocation?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final data = jsonDecode(raw);
      if (data is Map<String, dynamic>) return SavedLocation.fromJson(data);
    } catch (_) {
      // Data rusak: abaikan, mulai dari titik awal.
    }
    return null;
  }

  Future<void> save(SavedLocation location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(location.toJson()));
  }
}