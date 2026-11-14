import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/category.dart';
import '../../models/inventory.dart';
import '../../models/product.dart';
import '../../services/seller_repository.dart';
import '../../widgets/app_states.dart';
import '../../widgets/search_field.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

const int _lowStockThreshold = 10;

class _StockItem {
  final InventoryModel inventory;
  final ProductModel? product;

  _StockItem(this.inventory, this.product);

  String get name => product?.name ?? inventory.productName ?? inventory.productId;
  String get categoryName => product?.categoryName ?? '-';
  int get price => product?.price ?? 0;
  int get available => inventory.availableQuantity;
  bool get isLow => available <= _lowStockThreshold;
}

class SellerStockScreen extends StatefulWidget {
  const SellerStockScreen({super.key});

  @override
  State<SellerStockScreen> createState() => _SellerStockScreenState();
}

class _SellerStockScreenState extends State<SellerStockScreen> {
  final _repo = sellerRepository();

  bool _loading = true;
  String? _error;
  List<_StockItem> _items = [];
  List<CategoryModel> _categories = [];

  String _search = '';
  String? _categoryFilter;
  bool _lowOnly = false;

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
      final results = await Future.wait([
        _repo.myStock(),
        _repo.products(),
        _repo.categories(),
      ]);
      if (!mounted) return;
      final stock = results[0] as List<InventoryModel>;
      final products = results[1] as List<ProductModel>;
      final categories = results[2] as List<CategoryModel>;
      final productMap = {for (final p in products) p.id: p};
      setState(() {
        _items = [
          for (final s in stock) _StockItem(s, productMap[s.productId]),
        ];
        _categories = categories;
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

  List<_StockItem> get _filtered {
    return _items.where((item) {
      if (_search.isNotEmpty &&
          !item.name.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      if (_categoryFilter != null &&
          item.product?.categoryId != _categoryFilter) {
        return false;
      }
      if (_lowOnly && !item.isLow) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat stok...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    final filtered = _filtered;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppConstants.primaryColor,
      child: Column(
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
                _filterChip('Semua', _categoryFilter == null && !_lowOnly, () {
                  setState(() {
                    _categoryFilter = null;
                    _lowOnly = false;
                  });
                }),
                _filterChip('Menipis', _lowOnly, () {
                  setState(() => _lowOnly = !_lowOnly);
                }),
                for (final c in _categories)
                  _filterChip(c.name, _categoryFilter == c.id, () {
                    setState(() {
                      _categoryFilter = _categoryFilter == c.id ? null : c.id;
                      _lowOnly = false;
                    });
                  }),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? EmptyView(
                    icon: Icons.inventory_2_outlined,
                    title: 'Tidak ada produk',
                    message: _items.isEmpty
                        ? 'Data stok belum tersedia.'
                        : 'Tidak ada produk yang cocok dengan pencarian/filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildStockCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool selected, VoidCallback onTap) {
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

  Widget _buildStockCard(_StockItem item) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _showDetail(item),
      child: SectionCard(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _buildThumb(item),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppConstants.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.categoryName} • ${formatRupiah(item.price)}',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      StatusBadge(
                        label: item.available > 0 ? 'TERSEDIA' : 'HABIS',
                        color: item.available > 0
                            ? AppConstants.statusSuccess
                            : AppConstants.statusWarning,
                      ),
                      if (item.isLow) ...[
                        const SizedBox(width: 6),
                        const StatusBadge(
                          label: 'MENIPIS',
                          color: AppConstants.statusPending,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.available}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.primaryDark,
                  ),
                ),
                const Text(
                  'cup',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumb(_StockItem item) {
    final url = item.product?.imageUrl;
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: AppConstants.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url == null || url.isEmpty)
          ? const Icon(Icons.coffee_outlined,
              color: AppConstants.primaryColor, size: 26)
          : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const Icon(Icons.coffee_outlined,
                  color: AppConstants.primaryColor, size: 26),
            ),
    );
  }

  void _showDetail(_StockItem item) {
    final inv = item.inventory;
    final updated = parseBackendDate(inv.updatedAt);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppConstants.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              item.categoryName,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            _detailRow('Harga jual', formatRupiah(item.price)),
            _detailRow('Stok fisik', '${inv.quantity} cup'),
            _detailRow('Direservasi', '${inv.reservedQuantity} cup'),
            _detailRow('Tersedia', '${inv.availableQuantity} cup'),
            _detailRow(
              'Pembaruan terakhir',
              updated == null ? '-' : formatWib(updated),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppConstants.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline,
                      size: 18, color: Colors.brown.shade300),
                  const SizedBox(width: 8),
                  Expanded(
                    child: const Text(
                      'Stok bersifat read-only. Perubahan stok terjadi '
                      'otomatis melalui transaksi penjualan.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black54, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppConstants.textDark,
            ),
          ),
        ],
      ),
    );
  }
}