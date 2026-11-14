import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  bool get isUnauthorized => statusCode == 401;
  bool get isNetworkError => statusCode == 0;

  @override
  String toString() => message;
}

class ApiClient {
  final http.Client _client = http.Client();
  String? token;

  static const Duration _timeout = Duration(seconds: 15);

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = Uri.parse(AppConstants.apiBaseUrl);
    String cleanPath = path;
    final Map<String, String> qp = {};
    if (query != null) qp.addAll(query);

    if (path.contains('?')) {
      final idx = path.indexOf('?');
      cleanPath = path.substring(0, idx);
      final queryStr = path.substring(idx + 1);
      qp.addAll(Uri.splitQueryString(queryStr));
    }

    return base.replace(
      path: '${base.path}$cleanPath',
      queryParameters: qp.isEmpty ? null : qp,
    );
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  Future<dynamic> get(String path, {Map<String, String>? query}) {
    return _send(() => _client.get(_uri(path, query), headers: _headers));
  }

  Future<dynamic> post(String path, {Object? body, Map<String, String>? query}) {
    return _send(
      () => _client.post(
        _uri(path, query),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> patch(String path, {Object? body, Map<String, String>? query}) {
    return _send(
      () => _client.patch(
        _uri(path, query),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> put(String path, {Object? body, Map<String, String>? query}) {
    return _send(
      () => _client.put(
        _uri(path, query),
        headers: _headers,
        body: body == null ? null : jsonEncode(body),
      ),
    );
  }

  Future<dynamic> _send(Future<http.Response> Function() run) async {
    http.Response res;
    try {
      res = await run().timeout(_timeout);
    } on TimeoutException {
      throw ApiException(0, 'Server tidak merespons (timeout). Coba lagi.');
    } catch (_) {
      throw ApiException(
        0,
        'Tidak dapat terhubung ke server. Pastikan backend berjalan.',
      );
    }

    dynamic data;
    if (res.body.isNotEmpty) {
      try {
        data = jsonDecode(res.body);
      } catch (_) {
        data = null;
      }
    }

    if (res.statusCode >= 200 && res.statusCode < 300) return data;
    throw ApiException(res.statusCode, _extractMessage(data, res.statusCode));
  }

  String _extractMessage(dynamic data, int statusCode) {
    if (data is Map && data['detail'] != null) {
      final detail = data['detail'];
      if (detail is String) return detail;
      if (detail is List) {
        return detail
            .map((e) => e is Map ? (e['msg'] ?? e.toString()) : e.toString())
            .join('; ');
      }
    }
    return 'Terjadi kesalahan pada server (HTTP $statusCode).';
  }
}