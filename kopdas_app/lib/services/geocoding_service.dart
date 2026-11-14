import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class GeoResult {
  final String name;
  final String displayName;
  final double lat;
  final double lng;

  const GeoResult({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lng,
  });
}

class GeocodingException implements Exception {
  final String message;
  GeocodingException(this.message);

  @override
  String toString() => message;
}

/// Pencarian alamat & reverse geocoding memakai Nominatim (OpenStreetMap).
/// Kebijakan layanan: maksimal 1 request/detik — dijamin oleh [_throttle].
class GeocodingService {
  static const _base = 'nominatim.openstreetmap.org';
  static const _timeout = Duration(seconds: 12);
  static const _minInterval = Duration(milliseconds: 1100);

  final http.Client _client = http.Client();
  DateTime _lastRequest = DateTime.fromMillisecondsSinceEpoch(0);

  Future<void> _throttle() async {
    final elapsed = DateTime.now().difference(_lastRequest);
    if (elapsed < _minInterval) {
      await Future<void>.delayed(_minInterval - elapsed);
    }
    _lastRequest = DateTime.now();
  }

  Future<dynamic> _get(Uri uri) async {
    await _throttle();
    http.Response res;
    try {
      res = await _client.get(uri, headers: {
        'Accept': 'application/json',
      }).timeout(_timeout);
    } on TimeoutException {
      throw GeocodingException('Layanan pencarian alamat tidak merespons. Coba lagi.');
    } catch (_) {
      throw GeocodingException('Tidak dapat terhubung ke layanan pencarian alamat.');
    }
    if (res.statusCode != 200) {
      throw GeocodingException('Layanan pencarian alamat sedang bermasalah (HTTP ${res.statusCode}).');
    }
    return jsonDecode(res.body);
  }

  Future<List<GeoResult>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return const [];
    final uri = Uri.https(_base, '/search', {
      'q': q,
      'format': 'jsonv2',
      'limit': '5',
      'accept-language': 'id',
    });
    final data = await _get(uri) as List<dynamic>;
    return data.map((e) {
      final m = e as Map<String, dynamic>;
      final display = m['display_name'] as String? ?? '';
      final name = m['name'] as String? ?? '';
      return GeoResult(
        name: name.isNotEmpty ? name : display.split(',').first,
        displayName: display,
        lat: double.parse(m['lat'] as String),
        lng: double.parse(m['lon'] as String),
      );
    }).toList();
  }

  /// Alamat lengkap untuk koordinat; null bila tidak ditemukan / layanan gagal.
  Future<String?> reverse(double lat, double lng) async {
    final uri = Uri.https(_base, '/reverse', {
      'lat': lat.toStringAsFixed(6),
      'lon': lng.toStringAsFixed(6),
      'format': 'jsonv2',
      'accept-language': 'id',
      'zoom': '18',
    });
    try {
      final data = await _get(uri);
      if (data is Map<String, dynamic>) {
        final display = data['display_name'] as String?;
        if (display != null && display.isNotEmpty) return display;
      }
      return null;
    } on GeocodingException {
      return null;
    }
  }
}
