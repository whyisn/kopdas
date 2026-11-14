import 'package:flutter/foundation.dart';

import 'api_client.dart';

class SessionController extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  String? token;
  String? userId;
  String? role;
  String? name;

  ApiClient get api => _api;
  bool get isLoggedIn => token != null && userId != null;
  bool get isSeller => role == 'SELLER';

  String get homeRoute {
    switch (role) {
      case 'OWNER':
        return '/owner';
      case 'CUSTOMER':
        return '/customer';
      case 'SELLER':
        return '/seller';
      default:
        return '/login';
    }
  }

  Future<void> login(String username, String password) async {
    final data = await _api.post(
      '/auth/login',
      body: {'username': username, 'password': password},
    ) as Map<String, dynamic>;

    token = data['access_token'] as String;
    userId = data['user_id'] as String;
    role = data['role'] as String;
    name = data['name'] as String?;
    _api.token = token;
    notifyListeners();
  }

  Future<void> register(String username, String displayName, String password) async {
    final data = await _api.post(
      '/auth/register',
      body: {
        'username': username,
        'name': displayName,
        'password': password,
        'role': 'CUSTOMER',
      },
    ) as Map<String, dynamic>;

    token = data['access_token'] as String;
    userId = data['user_id'] as String;
    role = data['role'] as String;
    name = data['name'] as String?;
    _api.token = token;
    notifyListeners();
  }

  void logout() {
    token = null;
    userId = null;
    role = null;
    name = null;
    _api.token = null;
    notifyListeners();
  }
}

final SessionController sessionController = SessionController();

/// Seller id untuk API; throw ApiException(401) bila belum login.
String requireSellerId() {
  final id = sessionController.userId;
  if (id == null) {
    throw ApiException(
      401,
      'Sesi login diperlukan untuk memuat data ini. '
      'Silakan login terlebih dahulu.',
    );
  }
  return id;
}