import '../models/category.dart';
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

  // Backend GET /locations mengembalikan semua lokasi; filter milik seller di klien.
  Future<List<LocationModel>> myLocations(String sellerId) async {
    final data = await _api.get('/locations') as List<dynamic>;
    return data
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .where((l) => l.sellerId == sellerId)
        .toList();
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