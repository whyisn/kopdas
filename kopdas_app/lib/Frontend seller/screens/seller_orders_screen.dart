import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../services/demo_seller_store.dart';
import '../../widgets/app_dialogs.dart';
import '../../widgets/section_card.dart';
import '../../widgets/status_badge.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
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

  @override
  Widget build(BuildContext context) {
    if (!AppConstants.demoMode) return const _ProductionOrdersPlaceholder();

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
          _buildOrderCard(o),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildOrderCard(DemoOrder o) {
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

  IconData _methodIcon(String method) =>
      method == 'CASH' ? Icons.payments_outlined : Icons.qr_code_2;
}

/// PRODUCTION: backend belum menyediakan endpoint Orders untuk Seller.
/// Empty state profesional; tidak menampilkan data pesanan yang tidak nyata.
/// Kebutuhan API (GET /orders?seller_id, PATCH /orders/{id}/status, items[])
/// didokumentasikan pada laporan akhir.
class _ProductionOrdersPlaceholder extends StatelessWidget {
  const _ProductionOrdersPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 56, color: Colors.brown.shade200),
              const SizedBox(height: 16),
              const Text(
                'Pesanan belum tersedia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppConstants.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Informasi pesanan belum dapat dimuat. '
                'Data pesanan akan muncul setelah tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}