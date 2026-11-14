import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Satu hasil pencarian tempat dari Nominatim (OpenStreetMap).
class GeoPlace {
  final String displayName;
  final double latitude;
  final double longitude;

  const GeoPlace({
    required this.displayName,
    required this.latitude,
    required this.longitude,
  });
}

/// Geocoding ringan memakai Nominatim (OpenStreetMap) via HTTP, tanpa API key.
/// Kebijakan pemakaian Nominatim: maks. 1 permintaan/detik dan sertakan
/// User-Agent. Pemanggil wajib melakukan debounce (lihat layar lokasi).
class GeocodingService {
  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const _base = 'nominatim.openstreetmap.org';
  static const _timeout = Duration(seconds: 12);
  static const _headers = {
    'User-Agent': 'KopiCerdas/1.0 (seller location picker)',
  };

  /// Cari tempat berdasar kata kunci. List kosong bila tidak ada hasil / gagal.
  Future<List<GeoPlace>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final uri = Uri.https(_base, '/search', {
      'q': q,
      'format': 'jsonv2',
      'limit': '6',
      'accept-language': 'id',
    });
    try {
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body);
      if (data is! List) return const [];
      final places = <GeoPlace>[];
      for (final e in data) {
        if (e is! Map<String, dynamic>) continue;
        final name = e['display_name'] as String?;
        final lat = double.tryParse('${e['lat']}');
        final lon = double.tryParse('${e['lon']}');
        if (name == null || name.isEmpty || lat == null || lon == null) continue;
        places.add(GeoPlace(displayName: name, latitude: lat, longitude: lon));
      }
      return places;
    } catch (_) {
      return const [];
    }
  }

  /// Reverse geocode: koordinat menjadi alamat. Null bila gagal/tidak ditemukan.
  Future<String?> reverse(double lat, double lng) async {
    final uri = Uri.https(_base, '/reverse', {
      'lat': '$lat',
      'lon': '$lng',
      'format': 'jsonv2',
      'zoom': '18',
      'accept-language': 'id',
    });
    try {
      final res = await _client.get(uri, headers: _headers).timeout(_timeout);
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body);
      if (data is Map<String, dynamic>) {
        final name = data['display_name'] as String?;
        if (name != null && name.isNotEmpty) return name;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() => _client.close();
}