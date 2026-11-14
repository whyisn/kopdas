import '../core/constants.dart';
import '../models/category.dart';
import '../models/inventory.dart';
import '../models/location.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import 'auth_service.dart';
import 'demo_seller_store.dart';
import 'seller_api.dart';

/// Kontrak data Seller. Screen bergantung ke sini, bukan ke sumber konkret,
/// sehingga Demo Mode dan Production Mode terpisah jelas (lihat [sellerRepository]).
abstract class SellerRepository {
  Future<List<CategoryModel>> categories();
  Future<List<ProductModel>> products({String? categoryId});
  Future<List<InventoryModel>> myStock();
  Future<List<TransactionModel>> myTransactions({int limit = 50});
  Future<List<LocationModel>> myLocations();
  Future<TransactionModel> createTransaction({
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? idempotencyKey,
  });
}

/// PRODUCTION: API backend asli, butuh token + seller_id dari sesi login.
class BackendSellerRepository implements SellerRepository {
  final SellerApi _api;

  BackendSellerRepository(this._api);

  @override
  Future<List<CategoryModel>> categories() => _api.categories();

  @override
  Future<List<ProductModel>> products({String? categoryId}) =>
      _api.products(categoryId: categoryId);

  @override
  Future<List<InventoryModel>> myStock() => _api.myStock(requireSellerId());

  @override
  Future<List<TransactionModel>> myTransactions({int limit = 50}) =>
      _api.myTransactions(requireSellerId(), limit: limit);

  @override
  Future<List<LocationModel>> myLocations() =>
      _api.myLocations(requireSellerId());

  @override
  Future<TransactionModel> createTransaction({
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? idempotencyKey,
  }) =>
      _api.createTransaction(
        sellerId: requireSellerId(),
        locationId: locationId,
        paymentMethod: paymentMethod,
        items: items,
        idempotencyKey: idempotencyKey,
      );
}

/// DEMO: data simulasi lokal, tanpa token, tanpa tulis ke backend.
class DemoSellerRepository implements SellerRepository {
  final DemoSellerStore _store;

  DemoSellerRepository(this._store);

  @override
  Future<List<CategoryModel>> categories() async => _store.categories;

  @override
  Future<List<ProductModel>> products({String? categoryId}) async =>
      categoryId == null
          ? _store.products
          : _store.products.where((p) => p.categoryId == categoryId).toList();

  @override
  Future<List<InventoryModel>> myStock() async => _store.stock;

  @override
  Future<List<TransactionModel>> myTransactions({int limit = 50}) async =>
      _store.transactions.take(limit).toList();

  @override
  Future<List<LocationModel>> myLocations() async => _store.locations;

  @override
  Future<TransactionModel> createTransaction({
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
    String? idempotencyKey,
  }) async =>
      _store.createTransaction(
        locationId: locationId,
        paymentMethod: paymentMethod,
        items: items,
      );
}

/// Pilih sumber data berdasar mode. Satu toggle: [AppConstants.demoMode].
SellerRepository sellerRepository() => AppConstants.demoMode
    ? DemoSellerRepository(demoSellerStore)
    : BackendSellerRepository(SellerApi(sessionController.api));