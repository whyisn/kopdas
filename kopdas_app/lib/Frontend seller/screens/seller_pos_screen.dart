import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/inventory.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../../models/transaction.dart';
import '../../services/auth_service.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_states.dart';
import '../../widgets/search_field.dart';
import '../../widgets/status_badge.dart';

class _CartLine {
  final ProductModel product;
  int qty;
  _CartLine(this.product, this.qty);
}

class SellerPosScreen extends StatefulWidget {
  const SellerPosScreen({super.key});

  @override
  State<SellerPosScreen> createState() => _SellerPosScreenState();
}

class _SellerPosScreenState extends State<SellerPosScreen> {
  final _api = SellerApi(sessionController.api);

  bool _loading = true;
  String? _error;
  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  Map<String, int> _availableByProduct = {};
  LocationModel? _location;

  final Map<String, _CartLine> _cart = {};
  String _search = '';
  String? _categoryFilter;
  String _paymentMethod = 'CASH';
  bool _submitting = false;
  String? _idempotencyKey;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final sellerId = sessionController.userId!;
      final results = await Future.wait([
        _api.products(),
        _api.categories(),
        _api.myStock(sellerId),
        _api.myLocations(sellerId),
      ]);
      if (!mounted) return;
      final products = results[0] as List<ProductModel>;
      final stock = results[2] as List<InventoryModel>;
      final locations = results[3] as List<LocationModel>;
      setState(() {
        _products = products;
        _categories = results[1] as List<CategoryModel>;
        _availableByProduct = {
          for (final s in stock) s.productId: s.availableQuantity,
        };
        _location = locations.isNotEmpty ? locations.first : null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<ProductModel> get _filteredProducts {
    return _products.where((p) {
      if (_search.isNotEmpty &&
          !p.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_categoryFilter != null && p.categoryId != _categoryFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  int get _cartCount => _cart.values.fold(0, (s, l) => s + l.qty);
  int get _estimateTotal =>
      _cart.values.fold(0, (s, l) => s + l.product.price * l.qty);

  void _updateCart(VoidCallback fn, [StateSetter? modalSetState]) {
    setState(fn);
    modalSetState?.call(() {});
  }

  void _addToCart(ProductModel p, [StateSetter? modalSetState]) {
    final available = _availableByProduct[p.id] ?? 0;
    final current = _cart[p.id]?.qty ?? 0;
    if (current >= available) {
      showAppSnackBar(context, 'Stok ${p.name} tidak mencukupi.', isError: true);
      return;
    }
    _updateCart(() {
      if (_cart.containsKey(p.id)) {
        _cart[p.id]!.qty++;
      } else {
        _cart[p.id] = _CartLine(p, 1);
      }
    }, modalSetState);
  }

  void _changeQty(String productId, int delta, [StateSetter? modalSetState]) {
    final line = _cart[productId];
    if (line == null) return;
    final available = _availableByProduct[productId] ?? 0;
    final newQty = line.qty + delta;
    if (newQty > available) {
      showAppSnackBar(context, 'Stok tidak mencukupi.', isError: true);
      return;
    }
    _updateCart(() {
      if (newQty <= 0) {
        _cart.remove(productId);
      } else {
        line.qty = newQty;
      }
    }, modalSetState);
  }

  Future<void> _checkout([StateSetter? modalSetState]) async {
    if (_cart.isEmpty) return;
    if (_location == null) {
      showAppSnackBar(
        context,
        'Lokasi jualan belum tersedia. Transaksi tidak dapat diproses.',
        isError: true,
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      context,
      title: 'Konfirmasi transaksi',
      message: _paymentMethod == 'CASH'
          ? 'Catat penjualan tunai sebesar ${formatRupiah(_estimateTotal)} '
              '($_cartCount item)? Total final dihitung backend.'
          : 'Pastikan pembayaran QRIS sebesar ${formatRupiah(_estimateTotal)} '
              'telah diterima. Total final dihitung backend.',
      confirmLabel: 'Proses',
    );
    if (!confirmed) return;

    _idempotencyKey ??=
        'pos-${sessionController.userId}-${DateTime.now().microsecondsSinceEpoch}';

    setState(() => _submitting = true);
    modalSetState?.call(() {});
    try {
      final trx = await _api.createTransaction(
        sellerId: sessionController.userId!,
        locationId: _location!.id,
        paymentMethod: _paymentMethod,
        items: [
          for (final l in _cart.values)
            {'product_id': l.product.id, 'quantity': l.qty},
        ],
        idempotencyKey: _idempotencyKey,
      );
      if (!mounted) return;
      _cart.clear();
      _idempotencyKey = null;
      setState(() => _submitting = false);
      modalSetState?.call(() {});
      if (modalSetState != null && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      await _showSuccess(trx);
      await _load();
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      modalSetState?.call(() {});
      showAppSnackBar(context, e.toString(), isError: true);
    }
  }

  Future<void> _showSuccess(TransactionModel trx) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.check_circle,
            color: AppConstants.statusSuccess, size: 48),
        title: const Text('Transaksi berhasil',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No: ${trx.id}',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
            const SizedBox(height: 12),
            for (final item in trx.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text('${item.quantity}× ${item.productName}',
                          style: const TextStyle(fontSize: 13)),
                    ),
                    Text(formatRupiah(item.subtotal),
                        style: const TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total (backend)',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  formatRupiah(trx.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppConstants.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                StatusBadge.payment(trx.paymentStatus),
                const SizedBox(width: 6),
                StatusBadge(
                  label: trx.paymentMethod,
                  color: AppConstants.primaryColor,
                ),
              ],
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat produk...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final productsArea = _buildProductsArea();

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: productsArea),
          SizedBox(
            width: 360,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildCartPanel(null),
            ),
          ),
        ],
      );
    }

    return Stack(
      children: [
        productsArea,
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: _buildMobileCartBar(),
        ),
      ],
    );
  }

  Widget _buildProductsArea() {
    final products = _filteredProducts;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SearchField(
            hint: 'Cari produk...',
            onChanged: (v) => setState(() => _search = v),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _catChip('Semua', _categoryFilter == null, () {
                setState(() => _categoryFilter = null);
              }),
              for (final c in _categories)
                _catChip(c.name, _categoryFilter == c.id, () {
                  setState(() =>
                      _categoryFilter = _categoryFilter == c.id ? null : c.id);
                }),
            ],
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? const EmptyView(
                  icon: Icons.coffee_outlined,
                  title: 'Tidak ada produk',
                  message: 'Tidak ada produk yang cocok.',
                )
              : GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                  gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    childAspectRatio: 0.82,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: products.length,
                  itemBuilder: (_, i) => _buildProductCard(products[i]),
                ),
        ),
      ],
    );
  }

  Widget _catChip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: AppConstants.accentColor.withValues(alpha: 0.35),
        checkmarkColor: AppConstants.primaryDark,
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected ? AppConstants.primaryDark : Colors.black87,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final available = _availableByProduct[p.id] ?? 0;
    final inCart = _cart[p.id]?.qty ?? 0;
    final canAdd = available > inCart;
    return Card(
      elevation: 0,
      color: AppConstants.surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.shade100),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: canAdd ? () => _addToCart(p) : null,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: (p.imageUrl == null || p.imageUrl!.isEmpty)
                      ? const Icon(Icons.coffee_outlined,
                          size: 40, color: AppConstants.primaryColor)
                      : Image.network(p.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Icon(
                              Icons.coffee_outlined,
                              size: 40,
                              color: AppConstants.primaryColor)),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                p.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                formatRupiah(p.price),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppConstants.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Stok: $available',
                    style: TextStyle(
                      fontSize: 11,
                      color: available > 0 ? Colors.black54 : AppConstants.statusWarning,
                    ),
                  ),
                  const Spacer(),
                  if (inCart > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$inCart',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCartBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(14),
      color: AppConstants.primaryDark,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _openCartSheet,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                '$_cartCount item',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                formatRupiah(_estimateTotal),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => StatefulBuilder(
          builder: (ctx2, setModalState) => Container(
            decoration: const BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _buildCartPanel(setModalState, scrollController),
          ),
        ),
      ),
    );
  }

  Widget _buildCartPanel(StateSetter? modalSetState,
      [ScrollController? scrollController]) {
    final lines = _cart.values.toList();
    return Container(
      decoration: BoxDecoration(
        color: AppConstants.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.shopping_cart_outlined,
                    color: AppConstants.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Keranjang',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textDark,
                  ),
                ),
                const Spacer(),
                if (lines.isNotEmpty)
                  TextButton(
                    onPressed: _submitting
                        ? null
                        : () => _updateCart(() => _cart.clear(), modalSetState),
                    child: const Text('Kosongkan'),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: lines.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Keranjang kosong.\nPilih produk untuk memulai.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black45, height: 1.5),
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: lines.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final l = lines[i];
                      return _buildCartLine(l, modalSetState);
                    },
                  ),
          ),
          const Divider(height: 1),
          _buildCheckoutSection(modalSetState),
        ],
      ),
    );
  }

  Widget _buildCartLine(_CartLine l, StateSetter? modalSetState) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.product.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13),
              ),
              Text(
                formatRupiah(l.product.price * l.qty),
                style: const TextStyle(
                    fontSize: 12, color: AppConstants.primaryColor),
              ),
            ],
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline, size: 20),
          onPressed: _submitting
              ? null
              : () => _changeQty(l.product.id, -1, modalSetState),
        ),
        Text('${l.qty}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline, size: 20),
          onPressed: _submitting
              ? null
              : () => _changeQty(l.product.id, 1, modalSetState),
        ),
      ],
    );
  }

  Widget _buildCheckoutSection(StateSetter? modalSetState) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimasi total',
                  style: TextStyle(color: Colors.black54, fontSize: 13)),
              Text(
                formatRupiah(_estimateTotal),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: AppConstants.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          const Text(
            'Total final dihitung & divalidasi backend.',
            style: TextStyle(fontSize: 11, color: Colors.black38),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _paymentChip('CASH', Icons.payments_outlined, modalSetState),
              const SizedBox(width: 8),
              _paymentChip('QRIS_STATIC', Icons.qr_code_2, modalSetState),
            ],
          ),
          if (_paymentMethod == 'QRIS_STATIC') ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppConstants.statusPending.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 16, color: AppConstants.statusPending),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gambar QRIS merchant belum tersedia dari backend. '
                      'Pastikan pembayaran diterima sebelum konfirmasi.',
                      style: TextStyle(
                          fontSize: 11, color: Colors.black54, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: (_cart.isEmpty || _submitting)
                  ? null
                  : () => _checkout(modalSetState),
              style: FilledButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Konfirmasi transaksi',
                      style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentChip(String method, IconData icon, StateSetter? modalSetState) {
    final selected = _paymentMethod == method;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: _submitting
            ? null
            : () => _updateCart(() => _paymentMethod = method, modalSetState),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected
                ? AppConstants.primaryColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppConstants.primaryColor
                  : Colors.brown.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected
                      ? AppConstants.primaryColor
                      : Colors.black54),
              const SizedBox(height: 4),
              Text(
                method == 'CASH' ? 'Tunai' : 'QRIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? AppConstants.primaryDark : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}