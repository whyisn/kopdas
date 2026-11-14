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
import '../../widgets/product_detail_sheet.dart';
import '../../widgets/product_image.dart';
import '../../widgets/search_field.dart';
import '../../widgets/status_badge.dart';

class _CartLine {
  final ProductModel product;
  final List<String> optionIds;
  final String? variantLabel;
  final int unitPrice;
  int qty;

  _CartLine(this.product, List<String> optionIds, this.qty)
      : optionIds = List.unmodifiable(optionIds),
        variantLabel = product.variantLabelFor(optionIds),
        unitPrice = product.unitPriceFor(optionIds);
}

String _cartKey(String productId, List<String> optionIds) {
  final sorted = optionIds.toList()..sort();
  return '$productId::${sorted.join(',')}';
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
      _cart.values.fold(0, (s, l) => s + l.unitPrice * l.qty);

  int _inCartForProduct(String productId) => _cart.values
      .where((l) => l.product.id == productId)
      .fold(0, (s, l) => s + l.qty);

  void _updateCart(VoidCallback fn, [StateSetter? modalSetState]) {
    setState(fn);
    modalSetState?.call(() {});
  }

  bool _addToCart(
    ProductModel p, {
    List<String>? optionIds,
    int qty = 1,
    StateSetter? modalSetState,
  }) {
    final ids = optionIds ?? p.defaultOptionIds;
    final available = _availableByProduct[p.id] ?? 0;
    final current = _inCartForProduct(p.id);
    if (current + qty > available) {
      showAppSnackBar(context, 'Stok ${p.name} tidak mencukupi.', isError: true);
      return false;
    }
    final key = _cartKey(p.id, ids);
    _updateCart(() {
      final existing = _cart[key];
      if (existing != null) {
        existing.qty += qty;
      } else {
        _cart[key] = _CartLine(p, ids, qty);
      }
    }, modalSetState);
    return true;
  }

  void _changeQty(String key, int delta, [StateSetter? modalSetState]) {
    final line = _cart[key];
    if (line == null) return;
    final available = _availableByProduct[line.product.id] ?? 0;
    final newQty = line.qty + delta;
    if (newQty > 0 && _inCartForProduct(line.product.id) + delta > available) {
      showAppSnackBar(context, 'Stok tidak mencukupi.', isError: true);
      return;
    }
    _updateCart(() {
      if (newQty <= 0) {
        _cart.remove(key);
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
            {
              'product_id': l.product.id,
              'quantity': l.qty,
              if (l.optionIds.isNotEmpty) 'option_ids': l.optionIds,
            },
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
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.quantity}× ${item.productName}',
                              style: const TextStyle(fontSize: 13)),
                          if (item.variantLabel != null)
                            Text(item.variantLabel!,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45)),
                        ],
                      ),
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
            hint: 'Cari minuman...',
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
                    maxCrossAxisExtent: 230,
                    childAspectRatio: 0.74,
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
        backgroundColor: Colors.white,
        selectedColor: const Color(0xFF1E3932),
        showCheckmark: false,
        side: BorderSide(
          color: selected ? const Color(0xFF1E3932) : const Color(0xFFE5E7EB),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : const Color(0xFF4B5563),
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel p) {
    final available = _availableByProduct[p.id] ?? 0;
    final inCart = _inCartForProduct(p.id);
    final canAdd = available > inCart;
    final out = available <= 0;
    return Card(
      elevation: 0,
      color: AppConstants.surfaceColor,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.brown.shade100),
      ),
      child: InkWell(
        onTap: () => _openProductDetail(p),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'pos-product-${p.id}',
                    child: ProductImage(imageUrl: p.imageUrl, cacheWidth: 480),
                  ),
                  if (out)
                    Container(color: Colors.white.withValues(alpha: 0.55)),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppConstants.primaryDark.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        p.categoryName ?? 'Menu',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(top: 8, right: 8, child: _imageStockBadge(available)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      height: 1.25,
                      color: AppConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(p.price),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Stok: $available',
                        style: TextStyle(
                          fontSize: 11,
                          color: available > 0
                              ? Colors.black54
                              : AppConstants.statusWarning,
                        ),
                      ),
                      const Spacer(),
                      _addButton(p, canAdd, inCart),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageStockBadge(int available) {
    final Color color;
    final String label;
    if (available <= 0) {
      color = AppConstants.statusDanger;
      label = 'Habis';
    } else if (available <= 5) {
      color = AppConstants.statusPending;
      label = 'Menipis';
    } else {
      color = AppConstants.statusSuccess;
      label = 'Tersedia';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addButton(ProductModel p, bool canAdd, int inCart) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Material(
              color: canAdd ? AppConstants.primaryColor : Colors.brown.shade100,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: canAdd ? () => _addToCart(p) : null,
                child: Icon(
                  Icons.add,
                  size: 20,
                  color: canAdd ? Colors.white : Colors.black38,
                ),
              ),
            ),
          ),
          if (inCart > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  '$inCart',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.primaryDark,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _openProductDetail(ProductModel p) {
    final available = _availableByProduct[p.id] ?? 0;
    final inCart = _inCartForProduct(p.id);

    void onAdd(List<String> optionIds, int qty) {
      final ok = _addToCart(p, optionIds: optionIds, qty: qty);
      if (ok) {
        final label = p.variantLabelFor(optionIds);
        showAppSnackBar(
          context,
          '${p.name}${label == null ? '' : ' ($label)'} ×$qty masuk keranjang.',
        );
      }
    }

    final isWide = MediaQuery.sizeOf(context).width >= 900;
    if (isWide) {
      showDialog(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540, maxHeight: 760),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Material(
                color: AppConstants.surfaceColor,
                child: ProductDetailSheet(
                  product: p,
                  available: available,
                  inCart: inCart,
                  isDialog: true,
                  onAdd: onAdd,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => DraggableScrollableSheet(
          initialChildSize: 0.88,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollController) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: AppConstants.surfaceColor,
              child: ProductDetailSheet(
                product: p,
                available: available,
                inCart: inCart,
                scrollController: scrollController,
                onAdd: onAdd,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildMobileCartBar() {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: const Color(0xFF1E3932),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openCartSheet,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart, color: Colors.white, size: 20),
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
      builder: (ctx) => FractionallySizedBox(
        heightFactor: 0.85,
        child: StatefulBuilder(
          builder: (ctx2, setModalState) => Container(
            decoration: const BoxDecoration(
              color: AppConstants.surfaceColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: _buildCartPanel(setModalState),
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
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
    final key = _cartKey(l.product.id, l.optionIds);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor.withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.brown.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 48,
              height: 48,
              child: ProductImage(imageUrl: l.product.imageUrl, cacheWidth: 120),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppConstants.textDark,
                  ),
                ),
                if (l.variantLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    l.variantLabel!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                  ),
                ],
                const SizedBox(height: 3),
                Text(
                  '${formatRupiah(l.unitPrice)} / cup',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(l.unitPrice * l.qty),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _miniStepper(
                    Icons.remove,
                    _submitting ? null : () => _changeQty(key, -1, modalSetState),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 7),
                    child: Text(
                      '${l.qty}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  _miniStepper(
                    Icons.add,
                    _submitting ? null : () => _changeQty(key, 1, modalSetState),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStepper(IconData icon, VoidCallback? onTap) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.brown.shade200),
        ),
        child: Icon(
          icon,
          size: 15,
          color: onTap == null ? Colors.black26 : AppConstants.primaryColor,
        ),
      ),
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
                ? const Color(0xFF1E3932).withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? const Color(0xFF1E3932)
                  : const Color(0xFFE5E7EB),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected
                      ? const Color(0xFF1E3932)
                      : const Color(0xFF6B7280)),
              const SizedBox(height: 4),
              Text(
                method == 'CASH' ? 'Tunai' : 'QRIS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? const Color(0xFF1E3932) : const Color(0xFF4B5563),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
