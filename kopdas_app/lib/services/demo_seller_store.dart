import '../models/category.dart';
import '../models/inventory.dart';
import '../models/location.dart';
import '../models/product.dart';
import '../models/transaction.dart';

/// Development Demo Mode (SIMULASI). Sumber data lokal, TIDAK menyentuh backend.
/// Semua mutasi (transaksi POS, status order, stok) hanya hidup di state ini.
class DemoOrderItem {
  final String productName;
  final int quantity;
  final int unitPrice;

  DemoOrderItem(this.productName, this.quantity, this.unitPrice);

  int get subtotal => quantity * unitPrice;
}

class DemoOrder {
  final String id;
  final String orderNumber;
  final String createdAt;
  final List<DemoOrderItem> items;
  final int totalAmount;
  String orderStatus;
  final String paymentMethod;
  final String paymentStatus;

  DemoOrder({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.items,
    required this.totalAmount,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
  });
}

String _agoIso(Duration d) =>
    DateTime.now().toUtc().subtract(d).toIso8601String();

class DemoSellerStore {
  static const String sellerId = 'demo-seller';
  static const String sellerName = 'Seller';
  static const String outletHours =
      'Senin–Jumat 07.00–22.00 WIB · Sabtu–Minggu 08.00–23.00 WIB';
  static const String outletContact =
      '+62 812-3456-7890 · outlet@kopicerdas.id';
  static const String outletStatus = 'BUKA · Menerima pesanan';

  final List<CategoryModel> categories = [
    CategoryModel(id: 'cat-kopi', name: 'Kopi', status: 'ACTIVE'),
    CategoryModel(id: 'cat-nonkopi', name: 'Non-Kopi', status: 'ACTIVE'),
    CategoryModel(id: 'cat-makanan', name: 'Makanan', status: 'ACTIVE'),
  ];

  final List<ProductModel> products = [
    ProductModel(id: 'p-espresso', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'Espresso', price: 18000, costPrice: 8000, status: 'ACTIVE', description: 'Single shot espresso robusta-arabica.'),
    ProductModel(id: 'p-americano', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'Americano', price: 22000, costPrice: 9000, status: 'ACTIVE', description: 'Espresso dengan air panas.'),
    ProductModel(id: 'p-latte', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'Caffè Latte', price: 28000, costPrice: 12000, status: 'ACTIVE', description: 'Espresso, steamed milk, microfoam.'),
    ProductModel(id: 'p-cappuccino', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'Cappuccino', price: 28000, costPrice: 12000, status: 'ACTIVE', description: 'Espresso, milk, foam seimbang.'),
    ProductModel(id: 'p-kopsus', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'Kopi Susu Gula Aren', price: 25000, costPrice: 10000, status: 'ACTIVE', description: 'Kopi susu dengan gula aren asli.'),
    ProductModel(id: 'p-v60', categoryId: 'cat-kopi', categoryName: 'Kopi', name: 'V60 Single Origin', price: 30000, costPrice: 13000, status: 'ACTIVE', description: 'Manual brew V60, single origin.'),
    ProductModel(id: 'p-matcha', categoryId: 'cat-nonkopi', categoryName: 'Non-Kopi', name: 'Matcha Latte', price: 30000, costPrice: 13000, status: 'ACTIVE', description: 'Matcha premium dengan susu.'),
    ProductModel(id: 'p-chocolate', categoryId: 'cat-nonkopi', categoryName: 'Non-Kopi', name: 'Chocolate', price: 26000, costPrice: 11000, status: 'ACTIVE', description: 'Cokelat Belgia hangat/dingin.'),
    ProductModel(id: 'p-tea', categoryId: 'cat-nonkopi', categoryName: 'Non-Kopi', name: 'Lemon Tea', price: 18000, costPrice: 7000, status: 'ACTIVE', description: 'Teh hitam dengan lemon segar.'),
    ProductModel(id: 'p-croissant', categoryId: 'cat-makanan', categoryName: 'Makanan', name: 'Butter Croissant', price: 22000, costPrice: 9000, status: 'ACTIVE', description: 'Croissant butter renyah.'),
    ProductModel(id: 'p-brownies', categoryId: 'cat-makanan', categoryName: 'Makanan', name: 'Fudgy Brownies', price: 25000, costPrice: 10000, status: 'ACTIVE', description: 'Brownies cokelat fudgy.'),
  ];

  final List<InventoryModel> _stock = [
    _inv('p-espresso', 40, 0),
    _inv('p-americano', 35, 0),
    _inv('p-latte', 10, 2),
    _inv('p-cappuccino', 25, 0),
    _inv('p-kopsus', 6, 0),
    _inv('p-v60', 20, 0),
    _inv('p-matcha', 15, 0),
    _inv('p-chocolate', 30, 0),
    _inv('p-tea', 50, 0),
    _inv('p-croissant', 4, 0),
    _inv('p-brownies', 12, 0),
  ];

  final List<LocationModel> locations = [
    LocationModel(id: 'loc-demo-1', sellerId: sellerId, name: 'Kopi Cerdas — Outlet', latitude: -6.200000, longitude: 106.816666, address: 'Jl. Contoh No. 123, Kebayoran Baru, Jakarta Selatan', sourceType: 'OUTLET', isActive: true, dataLabel: 'SIMULASI'),
    LocationModel(id: 'loc-demo-2', sellerId: sellerId, name: 'Kopi Cerdas — Booth', latitude: -6.175110, longitude: 106.865036, address: 'Lobby Gedung, Jl. Contoh No. 45, Jakarta', sourceType: 'BOOTH', isActive: true, dataLabel: 'SIMULASI'),
  ];

  late final List<TransactionModel> transactions = _seedTransactions();
  late final List<DemoOrder> orders = _seedOrders();

  List<InventoryModel> get stock => List.unmodifiable(_stock);
  int get productCount => products.length;

  /// Pesanan yang masih perlu diproses (belum selesai/dibatalkan).
  List<DemoOrder> get ordersToProcess => orders
      .where((o) =>
          o.orderStatus != 'COMPLETED' && o.orderStatus != 'CANCELLED')
      .toList();

  ProductModel? productById(String id) {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  /// Transaksi POS demo: hitung total lokal, kurangi stok, simpan ke state.
  /// TIDAK mengirim apa pun ke backend.
  TransactionModel createTransaction({
    required String locationId,
    required String paymentMethod,
    required List<Map<String, dynamic>> items,
  }) {
    final lineItems = <TransactionItemModel>[];
    var total = 0;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    for (var i = 0; i < items.length; i++) {
      final pid = items[i]['product_id'] as String;
      final qty = items[i]['quantity'] as int;
      final p = productById(pid);
      if (p == null) continue;
      final sub = p.price * qty;
      total += sub;
      lineItems.add(TransactionItemModel(
        id: 'demo-item-$stamp-$i',
        productId: p.id,
        productName: p.name,
        quantity: qty,
        unitPrice: p.price,
        subtotal: sub,
      ));
      _decrementStock(pid, qty);
    }
    final trx = TransactionModel(
      id: 'TRX-$stamp',
      sellerId: sellerId,
      locationId: locationId,
      totalAmount: total,
      paymentMethod: paymentMethod,
      paymentStatus: 'PAID',
      createdAt: DateTime.now().toUtc().toIso8601String(),
      items: lineItems,
    );
    transactions.insert(0, trx);
    return trx;
  }

  /// Ubah status order demo (state lokal saja).
  void updateOrderStatus(String orderId, String newStatus) {
    final i = orders.indexWhere((o) => o.id == orderId);
    if (i >= 0) orders[i].orderStatus = newStatus;
  }

  void _decrementStock(String productId, int qty) {
    final i = _stock.indexWhere((s) => s.productId == productId);
    if (i < 0) return;
    final s = _stock[i];
    final newQty = (s.quantity - qty).clamp(0, s.quantity);
    final newAvail = (s.availableQuantity - qty).clamp(0, s.availableQuantity);
    _stock[i] = InventoryModel(
      id: s.id,
      productId: s.productId,
      productName: s.productName,
      scopeType: s.scopeType,
      scopeId: s.scopeId,
      quantity: newQty,
      reservedQuantity: s.reservedQuantity,
      availableQuantity: newAvail,
      updatedAt: DateTime.now().toUtc().toIso8601String(),
    );
  }

  static InventoryModel _inv(String productId, int qty, int reserved) {
    final name = _productName(productId);
    return InventoryModel(
      id: 'inv-demo-$productId',
      productId: productId,
      productName: name,
      scopeType: 'SELLER',
      scopeId: sellerId,
      quantity: qty,
      reservedQuantity: reserved,
      availableQuantity: (qty - reserved).clamp(0, qty),
      updatedAt: _agoIso(const Duration(hours: 1)),
    );
  }

  static String _productName(String id) {
    const names = {
      'p-espresso': 'Espresso',
      'p-americano': 'Americano',
      'p-latte': 'Caffè Latte',
      'p-cappuccino': 'Cappuccino',
      'p-kopsus': 'Kopi Susu Gula Aren',
      'p-v60': 'V60 Single Origin',
      'p-matcha': 'Matcha Latte',
      'p-chocolate': 'Chocolate',
      'p-tea': 'Lemon Tea',
      'p-croissant': 'Butter Croissant',
      'p-brownies': 'Fudgy Brownies',
    };
    return names[id] ?? id;
  }

  TransactionItemModel _item(String pid, int qty, int n) {
    final p = productById(pid)!;
    return TransactionItemModel(
      id: 'demo-seed-item-$pid-$n',
      productId: p.id,
      productName: p.name,
      quantity: qty,
      unitPrice: p.price,
      subtotal: p.price * qty,
    );
  }

  TransactionModel _trx(
    String id,
    Duration ago,
    String method,
    List<TransactionItemModel> items,
  ) {
    return TransactionModel(
      id: id,
      sellerId: sellerId,
      locationId: 'loc-demo-1',
      totalAmount: items.fold<int>(0, (s, i) => s + i.subtotal),
      paymentMethod: method,
      paymentStatus: 'PAID',
      createdAt: _agoIso(ago),
      items: items,
    );
  }

  List<TransactionModel> _seedTransactions() => [
        _trx('TRX-1001', const Duration(minutes: 30), 'CASH',
            [_item('p-kopsus', 2, 1), _item('p-croissant', 1, 2)]),
        _trx('TRX-1002', const Duration(minutes: 90), 'QRIS_STATIC',
            [_item('p-latte', 1, 3), _item('p-brownies', 1, 4)]),
        _trx('TRX-1003', const Duration(hours: 3), 'CASH',
            [_item('p-americano', 2, 5)]),
        _trx('TRX-1004', const Duration(days: 1), 'QRIS_STATIC',
            [_item('p-cappuccino', 1, 6), _item('p-matcha', 1, 7)]),
        _trx('TRX-1005', const Duration(days: 1, hours: 2), 'CASH',
            [_item('p-v60', 1, 8)]),
        _trx('TRX-1006', const Duration(days: 2), 'CASH',
            [_item('p-kopsus', 3, 9)]),
        _trx('TRX-1007', const Duration(days: 3), 'QRIS_STATIC',
            [_item('p-espresso', 1, 10), _item('p-tea', 2, 11)]),
        _trx('TRX-1008', const Duration(days: 4), 'CASH',
            [_item('p-chocolate', 2, 12), _item('p-croissant', 2, 13)]),
      ];

  DemoOrder _order(
    String id,
    String number,
    Duration ago,
    String status,
    String method,
    String payStatus,
    List<DemoOrderItem> items,
  ) {
    return DemoOrder(
      id: id,
      orderNumber: number,
      createdAt: _agoIso(ago),
      items: items,
      totalAmount: items.fold<int>(0, (s, i) => s + i.subtotal),
      orderStatus: status,
      paymentMethod: method,
      paymentStatus: payStatus,
    );
  }

  List<DemoOrder> _seedOrders() => [
        _order('ord-demo-1', 'ORD-001', const Duration(minutes: 20),
            'CONFIRMED', 'QRIS_STATIC', 'PAID',
            [DemoOrderItem('Kopi Susu Gula Aren', 2, 25000), DemoOrderItem('Caffè Latte', 1, 28000)]),
        _order('ord-demo-2', 'ORD-002', const Duration(minutes: 40),
            'PREPARING', 'CASH', 'PAID',
            [DemoOrderItem('Americano', 1, 22000), DemoOrderItem('Butter Croissant', 2, 22000)]),
        _order('ord-demo-3', 'ORD-003', const Duration(hours: 1),
            'READY_FOR_PICKUP', 'QRIS_STATIC', 'PAID',
            [DemoOrderItem('Cappuccino', 2, 28000)]),
        _order('ord-demo-4', 'ORD-004', const Duration(hours: 2),
            'COMPLETED', 'CASH', 'PAID',
            [DemoOrderItem('Matcha Latte', 1, 30000), DemoOrderItem('Fudgy Brownies', 1, 25000)]),
        _order('ord-demo-5', 'ORD-005', const Duration(minutes: 10),
            'PENDING_PAYMENT', 'QRIS_STATIC', 'PENDING',
            [DemoOrderItem('V60 Single Origin', 1, 30000), DemoOrderItem('Lemon Tea', 1, 18000)]),
      ];
}

/// Singleton state demo (dipakai bersama oleh semua screen Seller demo).
final DemoSellerStore demoSellerStore = DemoSellerStore();