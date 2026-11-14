import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/formatters.dart';
import '../../models/transaction.dart';
import '../../services/auth_service.dart';
import '../../services/seller_api.dart';
import '../../widgets/app_states.dart';
import '../../widgets/search_field.dart';
import '../../widgets/status_badge.dart';

enum _DateFilter { all, today, week }

class SellerHistoryScreen extends StatefulWidget {
  const SellerHistoryScreen({super.key});

  @override
  State<SellerHistoryScreen> createState() => _SellerHistoryScreenState();
}

class _SellerHistoryScreenState extends State<SellerHistoryScreen> {
  final _api = SellerApi(sessionController.api);

  bool _loading = true;
  String? _error;
  List<TransactionModel> _transactions = [];
  String _search = '';
  _DateFilter _dateFilter = _DateFilter.all;

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
      final result =
          await _api.myTransactions(sessionController.userId!, limit: 50);
      if (!mounted) return;
      setState(() {
        _transactions = result;
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

  List<TransactionModel> get _filtered {
    final now = DateTime.now().toUtc();
    return _transactions.where((t) {
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        final matchId = t.id.toLowerCase().contains(q);
        final matchProduct =
            t.items.any((i) => i.productName.toLowerCase().contains(q));
        if (!matchId && !matchProduct) return false;
      }
      final dt = parseBackendDate(t.createdAt);
      if (_dateFilter != _DateFilter.all && dt != null) {
        if (_dateFilter == _DateFilter.today && !isTodayWib(dt)) return false;
        if (_dateFilter == _DateFilter.week &&
            now.difference(dt).inDays >= 7) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const LoadingView(message: 'Memuat riwayat...');
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
              hint: 'Cari no. transaksi / produk...',
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _dateChip('Semua', _DateFilter.all),
                _dateChip('Hari ini', _DateFilter.today),
                _dateChip('7 hari', _DateFilter.week),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${filtered.length} transaksi',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const Spacer(),
                Text(
                  'Filter di perangkat • maks. 50 terbaru',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? EmptyView(
                    icon: Icons.receipt_long_outlined,
                    title: 'Belum ada transaksi',
                    message: _transactions.isEmpty
                        ? 'Riwayat penjualan untuk akun ini belum ada.'
                        : 'Tidak ada transaksi yang cocok dengan filter.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (_, i) => _buildCard(filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _dateChip(String label, _DateFilter value) {
    final selected = _dateFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => setState(() => _dateFilter = value),
        backgroundColor: Colors.white,
        selectedColor: AppConstants.primaryColor,
        side: BorderSide(
          color: selected ? AppConstants.primaryColor : const Color(0xFFE5E7EB),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 12,
          color: selected ? Colors.white : const Color(0xFF374151),
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildCard(TransactionModel t) {
    final dt = parseBackendDate(t.createdAt);
    final itemCount = t.items.fold<int>(0, (s, i) => s + i.quantity);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _showDetail(t),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.id,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: AppConstants.textDark,
                      ),
                    ),
                  ),
                  Text(
                    formatRupiah(t.totalAmount),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      color: AppConstants.primaryDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                dt == null ? '-' : formatWib(dt),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  StatusBadge(
                    label: t.paymentMethod,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 6),
                  StatusBadge.payment(t.paymentStatus),
                  const Spacer(),
                  Text(
                    '$itemCount item',
                    style: const TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(TransactionModel t) {
    final dt = parseBackendDate(t.createdAt);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.id,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppConstants.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dt == null ? '-' : formatWib(dt),
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StatusBadge(label: t.paymentMethod,
                    color: AppConstants.primaryColor),
                const SizedBox(width: 6),
                StatusBadge.payment(t.paymentStatus),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            for (final item in t.items)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.productName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(
                            '${item.quantity} × ${formatRupiah(item.unitPrice)}',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black54),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      formatRupiah(item.subtotal),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            const Divider(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  formatRupiah(t.totalAmount),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppConstants.primaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}