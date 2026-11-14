import 'api_client.dart';
import 'auth_service.dart';

class OwnerApi {
  final ApiClient _api;

  OwnerApi([ApiClient? api]) : _api = api ?? sessionController.api;

  Future<Map<String, dynamic>> getSalesAnalytics({int days = 7}) async {
    try {
      final res = await _api.get('/analytics/sales', query: {'days': '$days'});
      return res is Map<String, dynamic> ? res : {};
    } catch (_) {
      return {};
    }
  }

  Future<List<dynamic>> getLocations() async {
    try {
      final res = await _api.get('/locations');
      return res is List ? res : [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getUsers() async {
    try {
      final res = await _api.get('/users');
      return res is List ? res : [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getInventory() async {
    try {
      final res = await _api.get('/inventory');
      return res is List ? res : [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getTransactions({int limit = 50}) async {
    try {
      final res = await _api.get('/transactions', query: {'limit': '$limit'});
      return res is List ? res : [];
    } catch (_) {
      return [];
    }
  }

  Future<List<dynamic>> getOrders({int limit = 50}) async {
    try {
      final res = await _api.get('/orders', query: {'limit': '$limit'});
      return res is List ? res : [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getAiRecommendations({String weather = 'NORMAL'}) async {
    try {
      final res = await _api.post('/ai/optimize', body: {'weather_condition': weather, 'data_label': 'REAL'});
      return res is Map<String, dynamic> ? res : {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getAiMetrics() async {
    try {
      final res = await _api.get('/ai/metrics');
      return res is Map<String, dynamic> ? res : {};
    } catch (_) {
      return {};
    }
  }
}

final OwnerApi ownerApi = OwnerApi();
