import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/order.dart';
import '../../services/auth_service.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_states.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
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

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

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

  @override
  Widget build(BuildContext context) {
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
          // Filter Chips
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
                    backgroundColor: Colors.white,
                    selectedColor: const Color(0xFF1E3932),
                    checkmarkColor: Colors.white,
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF1E3932) : const Color(0xFFE5E7EB),
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : const Color(0xFF4B5563),
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
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
                    Icon(Icons.inbox_outlined, size: 54, color: const Color(0xFF9CA3AF)),
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
            ..._filteredOrders.map(_buildOrderCard),
        ],
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    final isUpdating = _updatingOrderId == order.id;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Order Number & Status
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

          // Customer info & Items
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

          // Lifecycle Action Buttons
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
