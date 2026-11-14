import '../models/category.dart';
import '../models/crowd.dart';
import '../models/inventory.dart';
import '../models/location.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import 'api_client.dart';

class SellerApi {
  final ApiClient _api;

  SellerApi(this._api);

  Future<List<CategoryModel>> categories() async {
    final data = await _api.get('/categories') as List<dynamic>;
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> products({String? categoryId}) async {
    final data = await _api.get(
      '/products',
      query: categoryId == null ? null : {'category_id': categoryId},
    ) as List<dynamic>;
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<InventoryModel>> myStock(String sellerId) async {
    final data = await _api.get(
      '/inventory',
      query: {'scope_type': 'SELLER', 'scope_id': sellerId},
    ) as List<dynamic>;
    return data
        .map((e) => InventoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<TransactionModel>> myTransactions(
    String sellerId, {
    int limit = 50,
  }) async {
    final data = await _api.get(
      '/transactions',
      query: {'seller_id': sellerId, 'limit': '$limit'},
    ) as List<dynamic>;
    return data
        .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Lokasi milik seller yang login; backend memfilter berdasarkan token (bukan query param).
  Future<List<LocationModel>> myLocations(String sellerId) async {
    final data = await _api.get('/locations/mine') as List<dynamic>;
    return data
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<LocationModel> saveMyLocation({
    required String name,
    required double latitude,
    required double longitude,
    String? address,
  }) async {
    final data = await _api.post(
      '/locations/mine',
      body: {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    ) as Map<String, dynamic>;
    return LocationModel.fromJson(data);
  }

  Future<LocationModel> updateMyLocation(
    String locationId, {
    String? name,
    double? latitude,
    double? longitude,
    String? address,
    bool? isActive,
  }) async {
    final data = await _api.patch(
      '/locations/mine/$locationId',
      body: {
        'name': ?name,
        'latitude': ?latitude,
        'longitude': ?longitude,
        'address': ?address,
        'is_active': ?isActive,
      },
    ) as Map<String, dynamic>;
    return LocationModel.fromJson(data);
  }

  Future<CrowdReport> crowdDensity({
    required double latitude,
    required double longitude,
    int radiusM = 700,
    int? hour,
  }) async {
    final data = await _api.get(
      '/locations/crowd',
      query: {
        'lat': latitude.toStringAsFixed(6),
        'lng': longitude.toStringAsFixed(6),
        'radius_m': '$radiusM',
        if (hour != null) 'hour': '$hour',
      },
    ) as Map<String, dynamic>;
    return CrowdReport.fromJson(data);
  }

  Future<List<OrderModel>> myOrders(
    String sellerId, {
    String? orderStatus,
    int limit = 50,
  }) async {
    final query = <String, String>{
      'seller_id': sellerId,
      'limit': '$limit',
    };
    if (orderStatus != null && orderStatus.isNotEmpty) {
      query['order_status'] = orderStatus;
    }
    final data = await _api.get('/orders', query: query) as List<dynamic>;
    return data
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> updateOrderStatus(String orderId, String newStatus) async {
    final data = await _api.patch(
      '/orders/$orderId/status',
      body: {'status': newStatus},
    ) as Map<String, dynamic>;
    return OrderModel.fromJson(data);
  }

  Future<TransactionModel> createTransaction({
    required String sellerId,
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? idempotencyKey,
  }) async {
    final data = await _api.post(
      '/transactions',
      body: {
        'seller_id': sellerId,
        'location_id': locationId,
        'payment_method': paymentMethod,
        'items': items,
        'idempotency_key': ?idempotencyKey,
      },
    ) as Map<String, dynamic>;
    return TransactionModel.fromJson(data);
  }
}