import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kopdas_app/services/api_client.dart';
import 'package:kopdas_app/services/auth_service.dart';
import '../core/utils/format.dart';
import '../data/mock_data.dart';
import '../data/models/cart_item.dart';
import '../data/models/coffee_cart.dart';
import '../data/models/product.dart';

enum PayMethod { qris, wallet, va }

class OrderProvider extends ChangeNotifier {
  static const serviceFee = 0;
  static const payWindow = Duration(seconds: 180);
  final _rand = Random();

  // Data dinamis dari backend database SQLite
  List<CoffeeCart> _dynamicCarts = [];
  List<Product> _dynamicProducts = [];
  List<String> _dynamicCategories = [];
  Map<String, int> stockByProduct = {};
  bool isLoadingBackend = false;

  // Lokasi & gerobak
  String locName = 'Lokasi kamu saat ini (Padang)';
  double distFactor = 1;
  bool locEmpty = false;
  String? cartId;
  final Map<String, bool> closed = {};

  // Menu & keranjang
  String category = 'Semua';
  DraftItem? draft;
  final List<CartItem> items = [];
  String pickup = 'Secepatnya';

  // Validasi
  bool simulateChange = false;
  List<String> changes = [];

  // Pesanan & pembayaran database + Midtrans
  String backendOrderId = '';
  String qrisAssetUrl = '';
  String orderCode = '';
  String rejectReason = '';
  PayMethod payMethod = PayMethod.qris;
  bool paymentReceived = false;
  DateTime deadline = DateTime.now();

  // Midtrans Payment Gateway credentials & state
  String midtransClientKey = 'Mid-client-xVYN5mUwjQwAH_-o';
  String midtransNotificationUrl = 'http://127.0.0.1:8000/api/v1/payments/midtrans/notification';
  String? midtransSnapToken;
  String? midtransSnapRedirectUrl;
  String? midtransQrString;
  String? midtransQrUrl;
  String orderStatus = 'PENDING_PAYMENT';

  // Serah terima & review
  List<bool> received = [];
  int rating = 0;
  final Set<String> tags = {};
  String review = '';

  // ---------- Sinkronisasi Database Backend ----------
  List<CoffeeCart> get allCarts =>
      _dynamicCarts.isNotEmpty ? _dynamicCarts : MockData.carts;

  List<Product> get allMenu =>
      _dynamicProducts.isNotEmpty ? _dynamicProducts : MockData.menu;

  List<String> get allCategories =>
      _dynamicCategories.isNotEmpty ? _dynamicCategories : MockData.categories;

  Future<void> fetchBackendData() async {
    isLoadingBackend = true;
    notifyListeners();

    try {
      // 1. Ambil data produk asli dari database
      final prodRes = await sessionController.api.get('/products') as List<dynamic>;
      final catRes = await sessionController.api.get('/categories') as List<dynamic>;
      final locRes = await sessionController.api.get('/locations') as List<dynamic>;

      // Map categories
      final catMap = <String, String>{};
      final catList = <String>['Semua'];
      for (final c in catRes) {
        final id = c['id'] as String;
        final name = c['name'] as String;
        catMap[id] = name;
        if (!catList.contains(name)) catList.add(name);
      }
      _dynamicCategories = catList;

      // Map products
      final prodList = <Product>[];
      for (final p in prodRes) {
        final id = p['id'] as String;
        final catId = p['category_id'] as String? ?? '';
        final catName = catMap[catId] ?? 'Coffee';
        final name = p['name'] as String;
        final price = (p['price'] as num?)?.toInt() ?? 10000;
        final desc = p['description'] as String? ?? 'Minuman racikan segar KopiCerdas Padang';

        Color color = const Color(0xFF6F4E37);
        if (id.contains('01')) color = const Color(0xFF8A5A33);
        if (id.contains('02')) color = const Color(0xFF3B2A20);
        if (id.contains('03')) color = const Color(0xFF4A2C20);
        if (id.contains('04')) color = const Color(0xFF9E2A2B);
        if (id.contains('05')) color = const Color(0xFFB9763A);
        if (id.contains('06')) color = const Color(0xFFD9A62F);

        prodList.add(Product(
          id: id,
          category: catName,
          name: name,
          description: desc,
          price: price,
          color: color,
          isDrink: true,
        ));
      }
      if (prodList.isNotEmpty) _dynamicProducts = prodList;

      // Map locations / carts dari database
      final cartList = <CoffeeCart>[];
      int idx = 0;
      for (final l in locRes) {
        final id = l['id'] as String;
        final name = l['name'] as String;
        final address = l['address'] as String? ?? 'Padang';
        final isActive = l['is_active'] as bool? ?? true;

        final offsets = [
          const Offset(228, 66),
          const Offset(172, 118),
          const Offset(92, 142),
          const Offset(118, 62),
        ];
        final pos = idx < offsets.length ? offsets[idx] : const Offset(150, 100);
        final sellerId = l['seller_id'] as String? ?? 'usr-seller-0${(idx % 4) + 1}';

        cartList.add(CoffeeCart(
          id: id,
          sellerId: sellerId,
          name: name,
          spot: address,
          hours: '06.30–21.00 WIB',
          baseDistance: 150 + (idx * 200),
          rating: 4.8 + (idx % 2 * 0.1),
          reviews: 200 + (idx * 110),
          tag: 'Gerobak Kopi Lapangan Padang',
          waitMinutes: 4 + (idx * 2),
          online: isActive,
          pos: pos,
        ));
        idx++;
      }
      if (cartList.isNotEmpty) {
        _dynamicCarts = cartList;
        // Ambil stok awal gerobak pertama
        fetchStockForCart(cartList.first.sellerId);
      }

    } catch (e) {
      debugPrint('Note: Menggunakan dataset Padang fallback ($e)');
    } finally {
      isLoadingBackend = false;
      notifyListeners();
    }
  }

  /// Ambil stok riil seller gerobak dari backend SQLite
  Future<void> fetchStockForCart(String sellerId) async {
    try {
      final res = await sessionController.api.get('/inventory?scope_type=SELLER&scope_id=$sellerId') as List<dynamic>;
      final map = <String, int>{};
      for (final item in res) {
        final pid = item['product_id'] as String;
        final avail = (item['available_quantity'] as num?)?.toInt() ?? 0;
        map[pid] = avail;
      }
      stockByProduct = map;
      notifyListeners();
    } catch (e) {
      debugPrint('fetchStock note: $e');
    }
  }

  int stockOf(String pid) => stockByProduct[pid] ?? 50;

  // ---------- turunan ----------
  Product productOf(String id) {
    try {
      return allMenu.firstWhere((m) => m.id == id);
    } catch (_) {
      return allMenu.first;
    }
  }

  CoffeeCart get cart {
    try {
      return allCarts.firstWhere((c) => c.id == cartId);
    } catch (_) {
      return allCarts.first;
    }
  }

  List<CoffeeCart> get availableCarts => locEmpty
      ? []
      : allCarts.where((c) => c.online && closed[c.id] != true).toList();

  int distance(CoffeeCart c) => (c.baseDistance * distFactor).round();
  int get subtotal => items.fold(0, (a, i) => a + i.unit * i.qty);
  int get total => subtotal + serviceFee;
  int get count => items.fold(0, (a, i) => a + i.qty);

  List<Product> get filteredMenu => category == 'Semua'
      ? allMenu
      : allMenu.where((m) => m.category == category).toList();

  int get remainingSeconds =>
      max(0, (deadline.difference(DateTime.now()).inMilliseconds / 1000).ceil());

  int draftUnit(DraftItem d) {
    // Harga murni produk database tanpa ukuran/addon fiktif
    final p = productOf(d.pid);
    return p.price;
  }

  // ---------- lokasi ----------
  void setGps() {
    locName = 'Lokasi kamu saat ini (Padang)';
    distFactor = 1;
    locEmpty = false;
    notifyListeners();
  }

  void setArea(Area a) {
    locName = '${a.name}, Padang';
    locEmpty = a.empty;
    var h = 0;
    for (final ch in a.name.codeUnits) {
      h = (h * 7 + ch) % 9;
    }
    distFactor = .8 + h / 10;
    notifyListeners();
  }

  void selectCart(String id) {
    cartId = id;
    try {
      final c = allCarts.firstWhere((x) => x.id == id);
      fetchStockForCart(c.sellerId);
    } catch (_) {}
    notifyListeners();
  }

  // ---------- menu & kustomisasi ----------
  void setCategory(String c) {
    category = c;
    notifyListeners();
  }

  void startDraft(String pid) {
    draft = DraftItem(pid);
    notifyListeners();
  }

  void setSize(String v) { draft!.size = v; notifyListeners(); }
  void setTemp(String v) { draft!.temp = v; notifyListeners(); }
  void setSugar(String v) { draft!.sugar = v; notifyListeners(); }

  void toggleAddon(String v) {
    final a = draft!.addons;
    a.contains(v) ? a.remove(v) : a.add(v);
    notifyListeners();
  }

  void draftQty(int d) {
    if (draft == null) return;
    final maxStock = max(1, stockOf(draft!.pid));
    draft!.qty = (draft!.qty + d).clamp(1, maxStock);
    notifyListeners();
  }

  void addDraftToCart() {
    final d = draft!;
    final p = productOf(d.pid);
    final it = CartItem(
      pid: p.id,
      name: p.name,
      temp: d.temp,
      sugar: d.sugar,
      note: d.note.trim(),
      qty: d.qty,
      unit: p.price,
    );
    CartItem? existing;
    for (final i in items) {
      if (i.key == it.key) existing = i;
    }
    if (existing != null) {
      final maxStock = stockOf(p.id);
      existing.qty = (existing.qty + it.qty).clamp(1, maxStock);
    } else {
      items.add(it);
    }
    notifyListeners();
  }

  void changeQty(int i, int d) {
    final maxStock = max(1, stockOf(items[i].pid));
    items[i].qty = (items[i].qty + d).clamp(1, maxStock);
    notifyListeners();
  }

  void removeAt(int i) {
    items.removeAt(i);
    notifyListeners();
  }

  void setPickup(String v) { pickup = v; notifyListeners(); }
  void toggleSim() { simulateChange = !simulateChange; notifyListeners(); }

  /// Validasi gerobak, harga, stok. true = tidak ada perubahan.
  bool applyValidation() {
    changes = [];
    if (!simulateChange) return true;
    if (items.isNotEmpty) {
      final f = items.first;
      f.unit += 2000;
      changes.add('Harga ${f.name} naik ${rp(2000)} per item.');
    }
    if (items.length > 1) {
      final r = items.removeLast();
      changes.add('${r.name} sedang habis dan dihapus dari pesananmu.');
    }
    simulateChange = false;
    notifyListeners();
    return false;
  }

  // ---------- konfirmasi & pembayaran Midtrans ----------
  Future<bool> createRealOrder() async {
    final currentCart = cart;
    final orderPayload = {
      'customer_id': sessionController.userId ?? 'usr-cust-01',
      'seller_id': currentCart.sellerId,
      'location_id': currentCart.id,
      'items': items.map((i) => {
        'product_id': i.pid,
        'quantity': i.qty,
      }).toList(),
    };

    try {
      final res = await sessionController.api.post(
        '/customer/orders',
        body: orderPayload,
      ) as Map<String, dynamic>;

      backendOrderId = res['id'] as String? ?? '';
      orderCode = res['order_number'] as String? ?? 'KC-PADANG';
      qrisAssetUrl = res['qris_asset_url'] as String? ?? '';
      orderStatus = res['order_status'] as String? ?? 'PENDING_PAYMENT';

      final exp = res['expires_at'] as String?;
      if (exp != null) {
        deadline = DateTime.tryParse(exp)?.toLocal() ?? DateTime.now().add(payWindow);
      } else {
        deadline = DateTime.now().add(payWindow);
      }
      paymentReceived = false;

      // Buat transaksi Midtrans secara otomatis setelah order terdaftar
      await initMidtransCharge('snap');

      notifyListeners();
      return true;
    } on ApiException catch (e) {
      closed[cartId!] = true;
      rejectReason = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      // Fallback offline / network error
      backendOrderId = 'ord-sim-${1000 + _rand.nextInt(9000)}';
      orderCode = 'KC-${1000 + _rand.nextInt(9000)}';
      deadline = DateTime.now().add(payWindow);
      paymentReceived = false;
      notifyListeners();
      return true;
    }
  }

  /// Menerima pesanan secara simulasi / manual
  void acceptOrder() {
    if (orderCode.isEmpty) {
      orderCode = 'KC-${1000 + _rand.nextInt(9000)}';
    }
    if (deadline.isBefore(DateTime.now())) {
      deadline = DateTime.now().add(payWindow);
    }
    notifyListeners();
  }

  /// Menolak pesanan secara simulasi / manual
  void rejectOrder() {
    if (cartId != null) {
      closed[cartId!] = true;
    }
    if (rejectReason.isEmpty) {
      rejectReason = MockData.rejectReasons[_rand.nextInt(MockData.rejectReasons.length)];
    }
    notifyListeners();
  }

  /// Memanggil endpoint backend untuk membuat transaksi Snap / QRIS Midtrans
  Future<void> initMidtransCharge(String paymentType) async {
    if (backendOrderId.isEmpty) return;
    try {
      final chargeRes = await sessionController.api.post(
        '/payments/midtrans/charge',
        body: {
          'order_id': backendOrderId,
          'payment_type': paymentType,
        },
      ) as Map<String, dynamic>;

      midtransSnapToken = chargeRes['snap_token'] as String?;
      midtransSnapRedirectUrl = chargeRes['snap_redirect_url'] as String?;
      midtransQrString = chargeRes['qr_string'] as String?;
      midtransQrUrl = chargeRes['qr_url'] as String?;
      if (chargeRes['client_key'] != null) {
        midtransClientKey = chargeRes['client_key'] as String;
      }
      if (chargeRes['notification_url'] != null) {
        midtransNotificationUrl = chargeRes['notification_url'] as String;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Midtrans charge note: $e');
    }
  }

  /// Cek status pesanan secara berkala dari endpoint backend database
  Future<bool> checkOrderStatus() async {
    if (backendOrderId.isEmpty) return paymentReceived;
    try {
      final res = await sessionController.api.get('/customer/orders/$backendOrderId')
          as Map<String, dynamic>;
      final payStatus = res['payment_status'] as String? ?? '';
      orderStatus = res['order_status'] as String? ?? '';

      if (payStatus == 'PAID' || orderStatus == 'CONFIRMED' || orderStatus == 'PREPARING' || orderStatus == 'READY_FOR_PICKUP' || orderStatus == 'COMPLETED') {
        paymentReceived = true;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Check order error: $e');
    }
    return paymentReceived;
  }

  /// Memicu simulasi notifikasi Midtrans ke link lokal (settlement)
  Future<bool> triggerMidtransLocalSimulation() async {
    if (backendOrderId.isNotEmpty) {
      try {
        await sessionController.api.post(
          '/payments/midtrans/simulate-notification?order_id=$backendOrderId&action=settlement',
          body: {},
        );
        await checkOrderStatus();
      } catch (e) {
        debugPrint('Midtrans sim error: $e');
      }
    }
    paymentReceived = true;
    notifyListeners();
    return true;
  }

  void startPayment() {
    if (deadline.isBefore(DateTime.now())) {
      deadline = DateTime.now().add(payWindow);
    }
    paymentReceived = false;
    notifyListeners();
  }

  void setPayMethod(PayMethod m) {
    payMethod = m;
    notifyListeners();
    if (m == PayMethod.qris) {
      initMidtransCharge('qris');
    } else {
      initMidtransCharge('snap');
    }
  }

  void markPaid() { paymentReceived = true; notifyListeners(); }

  // ---------- serah terima & review ----------
  void initReceived() {
    received = items.map((_) => false).toList();
    notifyListeners();
  }

  void toggleReceived(int i) { received[i] = !received[i]; notifyListeners(); }
  void setRating(int v) { rating = v; notifyListeners(); }
  void toggleTag(String t) {
    tags.contains(t) ? tags.remove(t) : tags.add(t);
    notifyListeners();
  }

  void setReview(String v) => review = v;

  void resetForNewOrder() {
    items.clear();
    closed.clear();
    backendOrderId = '';
    qrisAssetUrl = '';
    rejectReason = '';
    rating = 0;
    tags.clear();
    review = '';
    received = [];
    draft = null;
    category = 'Semua';
    pickup = 'Secepatnya';
    paymentReceived = false;
    midtransSnapToken = null;
    midtransSnapRedirectUrl = null;
    midtransQrString = null;
    midtransQrUrl = null;
    orderStatus = 'PENDING_PAYMENT';
    notifyListeners();
  }
}
