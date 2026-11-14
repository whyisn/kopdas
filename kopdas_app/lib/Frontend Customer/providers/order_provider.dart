import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../../services/api_client.dart';
import '../../../services/auth_service.dart';
import '../core/utils/format.dart';
import '../data/mock_data.dart';
import '../data/models/cart_item.dart';
import '../data/models/coffee_cart.dart';
import '../data/models/product.dart';

enum PayMethod { qris, wallet, va }

class OrderProvider extends ChangeNotifier {
  static const serviceFee = 1000;
  static const payWindow = Duration(seconds: 120);
  final _rand = Random();

  // Lokasi & gerobak
  String locName = '';
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

  // Pesanan & pembayaran
  String backendOrderId = '';
  String qrisAssetUrl = '';
  String orderCode = '';
  String rejectReason = '';
  PayMethod payMethod = PayMethod.qris;
  bool paymentReceived = false;
  DateTime deadline = DateTime.now();

  // Serah terima & review
  List<bool> received = [];
  int rating = 0;
  final Set<String> tags = {};
  String review = '';

  // ---------- turunan ----------
  Product productOf(String id) => MockData.menu.firstWhere((m) => m.id == id);
  CoffeeCart get cart => MockData.carts.firstWhere((c) => c.id == cartId);
  List<CoffeeCart> get availableCarts => locEmpty
      ? []
      : MockData.carts.where((c) => c.online && closed[c.id] != true).toList();
  int distance(CoffeeCart c) => (c.baseDistance * distFactor).round();
  int get subtotal => items.fold(0, (a, i) => a + i.unit * i.qty);
  int get total => subtotal + serviceFee;
  int get count => items.fold(0, (a, i) => a + i.qty);
  List<Product> get filteredMenu => category == 'Semua'
      ? MockData.menu
      : MockData.menu.where((m) => m.category == category).toList();
  int get remainingSeconds =>
      max(0, (deadline.difference(DateTime.now()).inMilliseconds / 1000).ceil());

  int draftUnit(DraftItem d) {
    final p = productOf(d.pid);
    var u = p.price;
    if (p.isDrink) {
      u += MockData.sizes.firstWhere((s) => s.name == d.size).extra;
      for (final a in d.addons) {
        u += MockData.addons.firstWhere((x) => x.name == a).extra;
      }
    }
    return u;
  }

  // ---------- lokasi ----------
  void setGps() {
    locName = 'Lokasi kamu saat ini';
    distFactor = 1;
    locEmpty = false;
    notifyListeners();
  }

  void setArea(Area a) {
    locName = '${a.name}, Jakarta';
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
    draft!.qty = (draft!.qty + d).clamp(1, 20);
    notifyListeners();
  }

  void addDraftToCart() {
    final d = draft!;
    final p = productOf(d.pid);
    final it = CartItem(
      pid: p.id,
      name: p.name,
      size: p.isDrink ? d.size : '',
      temp: p.isDrink ? d.temp : '',
      sugar: p.isDrink ? d.sugar : '',
      addons: p.isDrink ? ([...d.addons]..sort()) : [],
      note: d.note.trim(),
      qty: d.qty,
      unit: draftUnit(d),
    );
    CartItem? existing;
    for (final i in items) {
      if (i.key == it.key) existing = i;
    }
    existing != null ? existing.qty += it.qty : items.add(it);
    notifyListeners();
  }

  void changeQty(int i, int d) {
    items[i].qty = (items[i].qty + d).clamp(1, 20);
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
    final f = items.first;
    f.unit += 2000;
    changes.add('Harga ${f.name} naik ${rp(2000)} per item.');
    if (items.length > 1) {
      final r = items.removeLast();
      changes.add('${r.name} sedang habis dan dihapus dari pesananmu.');
    }
    simulateChange = false;
    notifyListeners();
    return false;
  }

  // ---------- konfirmasi & pembayaran ----------
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
      final exp = res['expires_at'] as String?;
      if (exp != null) {
        deadline = DateTime.tryParse(exp)?.toLocal() ?? DateTime.now().add(payWindow);
      } else {
        deadline = DateTime.now().add(payWindow);
      }
      paymentReceived = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      closed[cartId!] = true;
      rejectReason = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      // Fallback offline / network error
      orderCode = 'KC-${1000 + _rand.nextInt(9000)}';
      deadline = DateTime.now().add(payWindow);
      paymentReceived = false;
      notifyListeners();
      return true;
    }
  }

  Future<bool> triggerRealPayment() async {
    if (backendOrderId.isNotEmpty) {
      try {
        await sessionController.api.post(
          '/webhooks/qris',
          body: {
            'event': 'PAYMENT_CONFIRMED',
            'order_id': backendOrderId,
            'gross_amount': total,
          },
        );
      } catch (_) {
        // Abaikan jika simulasi webhook dev
      }
    }
    paymentReceived = true;
    notifyListeners();
    return true;
  }

  void acceptOrder() {
    orderCode = 'KC-${1000 + _rand.nextInt(9000)}';
    notifyListeners();
  }

  void rejectOrder() {
    closed[cartId!] = true;
    rejectReason = MockData.rejectReasons[_rand.nextInt(MockData.rejectReasons.length)];
    notifyListeners();
  }

  void startPayment() {
    if (deadline.isBefore(DateTime.now())) {
      deadline = DateTime.now().add(payWindow);
    }
    paymentReceived = false;
    notifyListeners();
  }

  void setPayMethod(PayMethod m) { payMethod = m; notifyListeners(); }
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
    notifyListeners();
  }
}
