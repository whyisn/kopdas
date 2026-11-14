import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/order.dart';
import '../../services/auth_service.dart';
import '../../services/demo_seller_store.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/app_states.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  // Production (API) state.
  final _api = SellerApi(sessionController.api);

  bool _loading = true;
  String? _error;
  List<OrderModel> _orders = [];
  String _selectedFilter = 'Semua';
  String? _updatingOrderId;

  final List<String> _filters = [
    'Semua',
    'Perlu Diproses',
    'Siap Diambil',
    'Selesai',
  ];

  // Demo (local) state.
  static const Map<String, String> _nextStatus = {
    'PENDING_PAYMENT': 'CONFIRMED',
    'CONFIRMED': 'PREPARING',
    'PREPARING': 'READY_FOR_PICKUP',
    'READY_FOR_PICKUP': 'COMPLETED',
  };

  static const Map<String, String> _nextLabel = {
    'PENDING_PAYMENT': 'Konfirmasi Pesanan',
    'CONFIRMED': 'Mulai Siapkan',
    'PREPARING': 'Siap Diambil',
    'READY_FOR_PICKUP': 'Selesaikan',
  };

  @override
  void initState() {
    super.initState();
    // Demo mode must never call the backend API.
    if (!AppConstants.demoMode) _loadOrders();
  }

  // ===== Production mode: SellerApi + OrderModel =====

  Future<void> _loadOrders() async {
    final sellerId = sessionController.userId;
    if (sellerId == null) {
      setState(() {
        _loading = false;
        _error = 'Sesi seller tidak valid. Silakan login kembali.';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final res = await _api.myOrders(sellerId);
      if (mounted) {
        setState(() {
          _orders = res;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Gagal memuat daftar pesanan: $e';
        });
      }
    }
  }

  Future<void> _updateStatus(String orderId, String nextStatus) async {
    setState(() => _updatingOrderId = orderId);
    try {
      final updated = await _api.updateOrderStatus(orderId, nextStatus);
      if (mounted) {
        setState(() {
          final idx = _orders.indexWhere((o) => o.id == orderId);
          if (idx != -1) {
            _orders[idx] = updated;
          }
          _updatingOrderId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan ${updated.orderNumber} diubah ke $nextStatus'),
            backgroundColor: AppConstants.statusSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _updatingOrderId = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui status: $e'),
            backgroundColor: AppConstants.statusDanger,
          ),
        );
      }
    }
  }

  List<OrderModel> get _filteredOrders {
    switch (_selectedFilter) {
      case 'Perlu Diproses':
        return _orders
            .where((o) =>
                o.orderStatus == 'CONFIRMED' || o.orderStatus == 'PREPARING')
            .toList();
      case 'Siap Diambil':
        return _orders
            .where((o) => o.orderStatus == 'READY_FOR_PICKUP')
            .toList();
      case 'Selesai':
        return _orders
            .where((o) => o.orderStatus == 'COMPLETED')
            .toList();
      default:
        return _orders;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'CONFIRMED':
        return Colors.blue.shade700;
      case 'PREPARING':
        return Colors.orange.shade800;
      case 'READY_FOR_PICKUP':
        return Colors.purple.shade700;
      case 'COMPLETED':
        return AppConstants.statusSuccess;
      case 'PENDING_PAYMENT':
        return Colors.amber.shade800;
      case 'CANCELLED':
      case 'EXPIRED':
        return AppConstants.statusDanger;
      default:
        return Colors.grey.shade700;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING_PAYMENT':
        return 'Menunggu Bayar';
      case 'CONFIRMED':
        return 'Diterima';
      case 'PREPARING':
        return 'Sedang Dibuat';
      case 'READY_FOR_PICKUP':
        return 'Siap Diambil';
      case 'COMPLETED':
        return 'Selesai';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'EXPIRED':
        return 'Kedaluwarsa';
      default:
        return status;
    }
  }

  // ===== Demo mode: demoSellerStore + DemoOrder =====

  void _advance(DemoOrder o) {
    final next = _nextStatus[o.orderStatus];
    if (next == null) return;
    setState(() => demoSellerStore.updateOrderStatus(o.id, next));
    showAppSnackBar(context, '${o.orderNumber} → $next');
  }

  Future<void> _cancel(DemoOrder o) async {
    final ok = await showConfirmDialog(
      context,
      title: 'Batalkan pesanan?',
      message: '${o.orderNumber} akan dibatalkan. '
          'Tindakan ini tidak dapat diurungkan.',
      confirmLabel: 'Batalkan',
      isDanger: true,
    );
    if (!ok || !mounted) return;
    setState(() => demoSellerStore.updateOrderStatus(o.id, 'CANCELLED'));
    showAppSnackBar(context, '${o.orderNumber} dibatalkan');
  }

  IconData _methodIcon(String method) =>
      method == 'CASH' ? Icons.payments_outlined : Icons.qr_code_2;

  @override
  Widget build(BuildContext context) {
    if (AppConstants.demoMode) return _buildDemoView();
    return _buildApiView();
  }

  Widget _buildDemoView() {
    final orders = demoSellerStore.orders;
    final toProcess = demoSellerStore.ordersToProcess.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
                color: AppConstants.accentColor.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.receipt_long_outlined,
                  size: 18, color: AppConstants.primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$toProcess pesanan perlu diproses · ${orders.length} total.',
                  style: const TextStyle(
                      fontSize: 12, color: AppConstants.textDark, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        for (final o in orders) ...[
          _buildDemoOrderCard(o),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildDemoOrderCard(DemoOrder o) {
    final created = parseBackendDate(o.createdAt);
    final next = _nextStatus[o.orderStatus];
    final canCancel =
        o.orderStatus != 'COMPLETED' && o.orderStatus != 'CANCELLED';

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.orderNumber,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      created == null ? '-' : formatWib(created),
                      style:
                          const TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge.order(o.orderStatus),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          for (final item in o.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.productName} ×${item.quantity}',
                      style: const TextStyle(
                          fontSize: 13, color: AppConstants.textDark),
                    ),
                  ),
                  Text(
                    formatRupiah(item.subtotal),
                    style: const TextStyle(
                        fontSize: 13, color: Colors.black54),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppConstants.textDark),
              ),
              const Spacer(),
              Text(
                formatRupiah(o.totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(_methodIcon(o.paymentMethod),
                  size: 16, color: Colors.brown.shade300),
              const SizedBox(width: 6),
              Text(
                o.paymentMethod,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const Spacer(),
              StatusBadge.payment(o.paymentStatus),
            ],
          ),
          if (next != null || canCancel) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                if (next != null)
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: () => _advance(o),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: Text(_nextLabel[o.orderStatus] ?? 'Lanjut'),
                      style: FilledButton.styleFrom(
                        backgroundColor:
                            AppConstants.accentColor.withValues(alpha: 0.3),
                        foregroundColor: AppConstants.primaryDark,
                      ),
                    ),
                  ),
                if (next != null && canCancel) const SizedBox(width: 8),
                if (canCancel)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancel(o),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Batalkan'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppConstants.statusWarning,
                        side: BorderSide(
                            color:
                                AppConstants.statusWarning.withValues(alpha: 0.5)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildApiView() {
    if (_loading && _orders.isEmpty) {
      return const LoadingView(message: 'Memuat pesanan masuk...');
    }

    if (_error != null && _orders.isEmpty) {
      return ErrorView(message: _error!, onRetry: _loadOrders);
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppConstants.primaryColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((f) {
                final isSelected = _selectedFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: isSelected,
                    onSelected: (val) {
                      if (val) setState(() => _selectedFilter = f);
                    },
                    selectedColor: AppConstants.primaryColor.withValues(alpha: 0.15),
                    checkmarkColor: AppConstants.primaryColor,
                    labelStyle: TextStyle(
                      color: isSelected ? AppConstants.primaryColor : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredOrders.isEmpty)
            SectionCard(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined, size: 54, color: Colors.brown.shade200),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFilter == 'Semua'
                          ? 'Belum ada pesanan masuk.'
                          : 'Tidak ada pesanan dalam kategori "$_selectedFilter".',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppConstants.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Pesanan dari pelanggan (aplikasi customer) akan muncul otomatis di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._filteredOrders.map(_buildApiOrderCard),
        ],
      ),
    );
  }

  Widget _buildApiOrderCard(OrderModel order) {
    final isUpdating = _updatingOrderId == order.id;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        order.orderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppConstants.textDark,
                        ),
                      ),
                      const SizedBox(width: 8),
                      StatusBadge(
                        label: order.dataLabel,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatWib(order.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _statusColor(order.orderStatus).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _statusColor(order.orderStatus).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _statusLabel(order.orderStatus),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _statusColor(order.orderStatus),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: Colors.black12),
          Row(
            children: [
              const Icon(Icons.person_pin, size: 16, color: Colors.black54),
              const SizedBox(width: 6),
              Text(
                'Pemesan: ${order.customerName}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppConstants.backgroundColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (order.items.isEmpty)
                  const Text(
                    'Tidak ada rincian item',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  )
                else
                  ...order.items.map((it) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${it.productName} × ${it.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              formatRupiah(it.subtotal),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                const Divider(height: 12, color: Colors.black12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      formatRupiah(order.totalAmount),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppConstants.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (isUpdating)
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else ...[
            if (order.orderStatus == 'CONFIRMED')
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _updateStatus(order.id, 'PREPARING'),
                  icon: const Icon(Icons.coffee_maker, size: 18),
                  label: const Text('Mulai Buat Kopi (PREPARING)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (order.orderStatus == 'PREPARING')
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _updateStatus(order.id, 'READY_FOR_PICKUP'),
                  icon: const Icon(Icons.notifications_active, size: 18),
                  label: const Text('Siap Diambil (READY FOR PICKUP)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.purple.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (order.orderStatus == 'READY_FOR_PICKUP')
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _updateStatus(order.id, 'COMPLETED'),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Serahkan ke Pelanggan (COMPLETED)'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppConstants.statusSuccess,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              )
            else if (order.orderStatus == 'PENDING_PAYMENT')
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: Colors.amber.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'Menunggu pembayaran QRIS dari pelanggan',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              )
            else if (order.orderStatus == 'COMPLETED')
              Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: AppConstants.statusSuccess),
                  const SizedBox(width: 6),
                  const Text(
                    'Pesanan telah diserahkan dan selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.statusSuccess,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }
}