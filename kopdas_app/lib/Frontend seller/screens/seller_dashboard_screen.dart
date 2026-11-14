import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/inventory.dart';
import '../../models/location.dart';
import '../../models/product.dart';
import '../../models/transaction.dart';
import '../../services/auth_service.dart';
import '../../services/demo_seller_store.dart';
import '../../services/seller_repository.dart';
import '../../widgets/app_states.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

const int _lowStockThreshold = 10;

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final _repo = sellerRepository();

  bool _loading = true;
  String? _error;
  List<LocationModel> _locations = [];
  List<InventoryModel> _stock = [];
  List<TransactionModel> _transactions = [];
  List<ProductModel> _products = [];

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
        _repo.myLocations(),
        _repo.myStock(),
        _repo.myTransactions(limit: 50),
        _repo.products(),
      ]);
      if (!mounted) return;
      setState(() {
        _locations = results[0] as List<LocationModel>;
        _stock = results[1] as List<InventoryModel>;
        _transactions = results[2] as List<TransactionModel>;
        _products = results[3] as List<ProductModel>;
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

  List<TransactionModel> get _todayTransactions {
    return _transactions.where((t) {
      final dt = parseBackendDate(t.createdAt);
      return dt != null && isTodayWib(dt);
    }).toList();
  }

  List<InventoryModel> get _lowStock {
    final items = _stock
        .where((s) => s.availableQuantity <= _lowStockThreshold)
        .toList();
    items.sort((a, b) => a.availableQuantity.compareTo(b.availableQuantity));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat dashboard...');
    if (_error != null) return ErrorView(message: _error!, onRetry: _load);

    final outlet = _locations.isNotEmpty ? _locations.first : null;
    final today = _todayTransactions;
    final todayRevenue = today.fold<int>(0, (sum, t) => sum + t.totalAmount);
    final lowStock = _lowStock;
    final recent = _transactions.take(5).toList();

    return RefreshIndicator(
      onRefresh: _load,
      color: AppConstants.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildGreeting(outlet),
          const SizedBox(height: 16),
          _buildTodaySummary(
              todayRevenue, today.length, _products.length, lowStock.length),
          const SizedBox(height: 16),
          _buildLowStock(lowStock),
          const SizedBox(height: 16),
          _buildOrders(),
          const SizedBox(height: 16),
          _buildRecent(recent),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGreeting(LocationModel? outlet) {
    final name = AppConstants.demoMode
        ? DemoSellerStore.sellerName
        : (sessionController.name ?? 'Seller');
    return SectionCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront,
                color: AppConstants.primaryColor, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, $name',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppConstants.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  outlet?.name ?? 'Lokasi belum tersedia',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (outlet != null)
                StatusBadge(
                  label: outlet.isActive ? 'AKTIF' : 'NONAKTIF',
                  color: outlet.isActive
                      ? AppConstants.statusSuccess
                      : Colors.blueGrey,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySummary(
      int revenue, int trxCount, int productCount, int lowCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Ringkasan hari ini (WIB)',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ),
        Row(
          children: [
            _StatTile(
              label: 'Penjualan',
              value: formatRupiah(revenue),
              icon: Icons.payments_outlined,
              color: AppConstants.statusSuccess,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Transaksi',
              value: '$trxCount',
              icon: Icons.receipt_long_outlined,
              color: AppConstants.primaryColor,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _StatTile(
              label: 'Produk',
              value: '$productCount',
              icon: Icons.coffee_outlined,
              color: AppConstants.accentColor,
            ),
            const SizedBox(width: 12),
            _StatTile(
              label: 'Stok menipis',
              value: '$lowCount',
              icon: Icons.warning_amber_outlined,
              color: AppConstants.statusPending,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLowStock(List<InventoryModel> lowStock) {
    return SectionCard(
      title: 'Stok menipis',
      trailing: Text(
        '≤ $_lowStockThreshold cup',
        style: TextStyle(fontSize: 11, color: Colors.brown.shade300),
      ),
      child: lowStock.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tidak ada produk dengan stok menipis.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : Column(
              children: [
                for (final s in lowStock.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined,
                            size: 18, color: AppConstants.statusPending),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            s.productName ?? s.productId,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        Text(
                          '${s.availableQuantity} cup',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppConstants.statusWarning,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildOrders() {
    if (!AppConstants.demoMode) {
      return SectionCard(
        title: 'Pesanan baru',
        child: Row(
          children: [
            Icon(Icons.info_outline, size: 20, color: Colors.brown.shade300),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Data pesanan belum tersedia.',
                style:
                    TextStyle(color: Colors.black54, fontSize: 13, height: 1.4),
              ),
            ),
          ],
        ),
      );
    }

    final active = demoSellerStore.ordersToProcess;
    return SectionCard(
      title: 'Pesanan perlu diproses',
      trailing: Text(
        '${active.length} pesanan',
        style: TextStyle(fontSize: 11, color: Colors.brown.shade300),
      ),
      child: active.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Tidak ada pesanan yang perlu diproses.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : Column(
              children: [
                for (final o in active.take(4))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                o.orderNumber,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${o.items.fold<int>(0, (s, i) => s + i.quantity)} item • ${formatRupiah(o.totalAmount)}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.order(o.orderStatus),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildRecent(List<TransactionModel> recent) {
    return SectionCard(
      title: 'Transaksi terbaru',
      child: recent.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'Belum ada transaksi.',
                style: TextStyle(color: Colors.black54),
              ),
            )
          : Column(
              children: [
                for (final t in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.id,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatDate(t.createdAt),
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatRupiah(t.totalAmount),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppConstants.textDark,
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge.payment(t.paymentStatus),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  String _formatDate(String iso) {
    final dt = parseBackendDate(iso);
    return dt == null ? '-' : formatWib(dt);
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConstants.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.brown.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 10),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textDark,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}