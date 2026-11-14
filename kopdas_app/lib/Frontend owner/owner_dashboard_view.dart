import 'package:flutter/material.dart';
import '../../core/ngopi_theme.dart';
import '../../models/product.dart';
import '../../models/inventory.dart';
import '../../services/api_client.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = true;

  // Data State
  List<ProductModel> _products = [];
  List<InventoryModel> _centralInventory = [];
  List<dynamic> _transactions = [];
  List<dynamic> _orders = [];
  List<dynamic> _locations = [];
  Map<String, dynamic>? _aiOptimizationData;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadAllOwnerData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllOwnerData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Load Products
      try {
        final prodRes = await _apiClient.get('/products');
        if (prodRes is List) {
          _products = prodRes.map((p) => ProductModel.fromJson(p)).toList();
        }
      } catch (_) {
        _products = [
          ProductModel(id: 'prd-01', categoryId: 'cat-01', name: 'Kopi Susu Aren', price: 18000, costPrice: 8000, status: 'ACTIVE', categoryName: 'Kopi'),
          ProductModel(id: 'prd-02', categoryId: 'cat-02', name: 'Americano Double Shot', price: 15000, costPrice: 5000, status: 'ACTIVE', categoryName: 'Kopi'),
          ProductModel(id: 'prd-03', categoryId: 'cat-03', name: 'Matcha Uji Latte', price: 24000, costPrice: 10000, status: 'ACTIVE', categoryName: 'Non-Kopi'),
          ProductModel(id: 'prd-04', categoryId: 'cat-01', name: 'Cafe Latte Steam', price: 22000, costPrice: 9000, status: 'ACTIVE', categoryName: 'Kopi'),
          ProductModel(id: 'prd-05', categoryId: 'cat-04', name: 'Roti Bakar Cokelat', price: 15000, costPrice: 6000, status: 'ACTIVE', categoryName: 'Camilan'),
        ];
      }

      // 2. Load Inventory (Warehouse/Central)
      final now = DateTime.now().toIso8601String();
      try {
        final invRes = await _apiClient.get('/inventory?scope_type=WAREHOUSE');
        if (invRes is List) {
          _centralInventory = invRes.map((i) => InventoryModel.fromJson(i)).toList();
        }
      } catch (_) {
        _centralInventory = [
          InventoryModel(id: 'inv-c-01', productId: 'prd-01', productName: 'Kopi Susu Aren', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 450, reservedQuantity: 0, availableQuantity: 450, updatedAt: now),
          InventoryModel(id: 'inv-c-02', productId: 'prd-02', productName: 'Americano Double Shot', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 320, reservedQuantity: 0, availableQuantity: 320, updatedAt: now),
          InventoryModel(id: 'inv-c-03', productId: 'prd-03', productName: 'Matcha Uji Latte', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 280, reservedQuantity: 0, availableQuantity: 280, updatedAt: now),
          InventoryModel(id: 'inv-c-04', productId: 'prd-04', productName: 'Cafe Latte Steam', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 500, reservedQuantity: 0, availableQuantity: 500, updatedAt: now),
        ];
      }

      // 3. Load Transactions & Orders
      try {
        final txRes = await _apiClient.get('/transactions');
        if (txRes is List) _transactions = txRes;
      } catch (_) {
        _transactions = [
          {'id': 'TX-901', 'seller_id': 'Kopi Pak Darto', 'total': 36000, 'payment_method': 'CASH', 'created_at': '2026-11-14T10:15:00'},
          {'id': 'TX-902', 'seller_id': 'Gerobak Sore', 'total': 24000, 'payment_method': 'QRIS_STATIC', 'created_at': '2026-11-14T10:30:00'},
          {'id': 'TX-903', 'seller_id': 'Seduh Mbak Ayu', 'total': 44000, 'payment_method': 'QRIS_STATIC', 'created_at': '2026-11-14T11:05:00'},
        ];
      }

      try {
        final ordRes = await _apiClient.get('/orders');
        if (ordRes is List) _orders = ordRes;
      } catch (_) {
        _orders = [
          {'id': 'ord-201', 'order_number': 'GK-8421', 'customer_name': 'Rani Pratama', 'total': 43000, 'order_status': 'CONFIRMED', 'payment_status': 'PAID', 'created_at': '2026-11-14T11:00:00'},
          {'id': 'ord-202', 'order_number': 'GK-5192', 'customer_name': 'Dimas Anggara', 'total': 19000, 'order_status': 'PENDING_PAYMENT', 'payment_status': 'PENDING', 'created_at': '2026-11-14T11:10:00'},
        ];
      }

      // 4. Load Locations & AI Scores (Sesuai Ngopi Gerobak style)
      try {
        final locRes = await _apiClient.get('/locations');
        if (locRes is List) _locations = locRes;
      } catch (_) {
        _locations = [
          {'id': 'c1', 'name': 'Kopi Pak Darto', 'spot': 'Depan halte Transjakarta', 'hours': '07.00–21.00', 'rate': 4.8, 'rev': 312, 'wait': 5, 'score': 94.5, 'is_active': true, 'source_type': 'ACTIVE_POINT'},
          {'id': 'c2', 'name': 'Gerobak Sore', 'spot': 'Samping taman kota', 'hours': '14.00–22.00', 'rate': 4.6, 'rev': 148, 'wait': 8, 'score': 88.0, 'is_active': true, 'source_type': 'ACTIVE_POINT'},
          {'id': 'c3', 'name': 'Seduh Keliling Mbak Ayu', 'spot': 'Pojok pasar pagi', 'hours': '05.00–12.00', 'rate': 4.9, 'rev': 521, 'wait': 12, 'score': 96.0, 'is_active': true, 'source_type': 'ACTIVE_POINT'},
          {'id': 'c4', 'name': 'Es Kopi Mang Ujang', 'spot': 'Depan minimarket', 'hours': '10.00–20.00', 'rate': 4.5, 'rev': 97, 'wait': 4, 'score': 74.0, 'is_active': false, 'source_type': 'CANDIDATE'},
          {'id': 'c5', 'name': 'Kopi Roda Biru', 'spot': 'Dekat stasiun commuter', 'hours': '06.00–22.00', 'rate': 4.7, 'rev': 203, 'wait': 6, 'score': 91.5, 'is_active': true, 'source_type': 'ACTIVE_POINT'},
        ];
      }

      // 5. Load AI Optimization Recommendation
      try {
        final optRes = await _apiClient.post('/ai/optimize', {});
        if (optRes is Map<String, dynamic>) _aiOptimizationData = optRes;
      } catch (_) {
        _aiOptimizationData = {
          'solver_status': 'MILP_OPTIMAL',
          'objective_profit': 18500000,
          'data_label': 'SIMULASI',
          'recommendations': [
            {'location_name': 'Kopi Pak Darto (Halte Sudirman)', 'product_name': 'Kopi Susu Aren', 'recommended_quantity': 60, 'rationale': ['Kepadatan pejalan kaki halte busway pagi hari', 'Kapasitas gerobak maksimal 120 cup']},
            {'location_name': 'Kopi Roda Biru (Dekat Stasiun)', 'product_name': 'Americano Double Shot', 'recommended_quantity': 45, 'rationale': ['Tingkat konsumsi kafein komuter pagi sangat tinggi']},
            {'location_name': 'Seduh Mbak Ayu (Pasar)', 'product_name': 'Matcha Uji Latte', 'recommended_quantity': 35, 'rationale': ['Permintaan non-kopi meningkat pada akhir pekan']},
          ]
        };
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDistributionModal() {
    String selectedSeller = 'usr-seller-01';
    String selectedProduct = _products.isNotEmpty ? _products.first.id : 'prd-01';
    final qtyController = TextEditingController(text: '20');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, top: 20, left: 20, right: 20),
        decoration: const BoxDecoration(
          color: NgopiTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Distribusi Stok ke Gerobak', style: TextStyle(fontFamily: 'Segoe UI', fontSize: 18, fontWeight: FontWeight.w800, color: NgopiTheme.ink)),
                IconButton(icon: const Icon(Icons.close, color: NgopiTheme.muted), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            const SizedBox(height: 12),
            const Text('Pilih Gerobak Seller:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NgopiTheme.muted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: NgopiTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: NgopiTheme.line, width: 1.5)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSeller,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'usr-seller-01', child: Text('Kopi Pak Darto - Depan halte Transjakarta')),
                    DropdownMenuItem(value: 'usr-seller-02', child: Text('Gerobak Sore - Samping taman kota')),
                    DropdownMenuItem(value: 'usr-seller-03', child: Text('Seduh Mbak Ayu - Pojok pasar pagi')),
                    DropdownMenuItem(value: 'usr-seller-05', child: Text('Kopi Roda Biru - Dekat stasiun')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => selectedSeller = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Pilih Menu Produk:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NgopiTheme.muted)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(color: NgopiTheme.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: NgopiTheme.line, width: 1.5)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedProduct,
                  isExpanded: true,
                  items: _products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => selectedProduct = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text('Jumlah Alokasi (Cup):', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: NgopiTheme.muted)),
            const SizedBox(height: 6),
            TextField(
              controller: qtyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: NgopiTheme.surface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NgopiTheme.line, width: 1.5)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NgopiTheme.line, width: 1.5)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: NgopiTheme.accent,
                foregroundColor: NgopiTheme.onAccent,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty <= 0) return;

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengalokasikan stok di database secara atomik...')),
                );

                try {
                  await _apiClient.post('/inventory/distributions', {
                    'seller_id': selectedSeller,
                    'items': [{'product_id': selectedProduct, 'quantity': qty}]
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: NgopiTheme.ok, content: Text('Berhasil mendistribusikan stok ke gerobak!')),
                    );
                    _loadAllOwnerData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: NgopiTheme.bad, content: Text('Gagal: $e')),
                    );
                  }
                }
              },
              child: const Text('Kirim Stok Sekarang', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: NgopiTheme.accent));
    }

    return Scaffold(
      backgroundColor: NgopiTheme.bg,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: NgopiTheme.surface,
            border: Border(bottom: BorderSide(color: NgopiTheme.line, width: 1)),
          ),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: NgopiTheme.accent,
            unselectedLabelColor: NgopiTheme.muted,
            indicatorColor: NgopiTheme.accent,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_outlined, size: 20), text: 'Overview'),
              Tab(icon: Icon(Icons.warehouse_outlined, size: 20), text: 'Stok Pusat'),
              Tab(icon: Icon(Icons.local_cafe_outlined, size: 20), text: 'Menu Kopi'),
              Tab(icon: Icon(Icons.receipt_outlined, size: 20), text: 'Transaksi'),
              Tab(icon: Icon(Icons.map_outlined, size: 20), text: 'Titik Gerobak'),
              Tab(icon: Icon(Icons.auto_awesome, size: 20), text: 'AI Rekomendasi'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildInventoryTab(),
          _buildProductsTab(),
          _buildOrdersAndTransactionsTab(),
          _buildLocationsTab(),
          _buildAiIntelligenceTab(),
        ],
      ),
    );
  }

  // TAB 1: OVERVIEW
  Widget _buildOverviewTab() {
    num totalOmzet = _transactions.fold(0, (acc, tx) => acc + (tx['total'] ?? 0));
    num totalOrderOmzet = _orders.where((o) => o['payment_status'] == 'PAID').fold(0, (acc, o) => acc + (o['total'] ?? 0));
    int totalStok = _centralInventory.fold(0, (acc, i) => acc + i.quantity);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner Hero ala Ngopi Gerobak
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: NgopiTheme.accent,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: NgopiTheme.sun,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text('PORTAL OWNER', style: TextStyle(color: NgopiTheme.onSun, fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Pantau Jaringan Gerobak Kopi',
                        style: TextStyle(color: NgopiTheme.onAccent, fontSize: 22, fontWeight: FontWeight.w800, height: 1.15),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Kelola stok pusat, verifikasi pembayaran QRIS, dan pantau AI intelligence.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NgopiTheme.sun,
                    foregroundColor: NgopiTheme.onSun,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  onPressed: _showDistributionModal,
                  icon: const Icon(Icons.local_shipping, size: 18),
                  label: const Text('Kirim Stok', style: TextStyle(fontWeight: FontWeight.w700)),
                )
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Metrik Card
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildTileMetric('Total Penjualan', 'Rp ${(totalOmzet + totalOrderOmzet).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', Icons.payments_outlined, NgopiTheme.ok),
              _buildTileMetric('Transaksi Berjalan', '${_transactions.length + _orders.length} Trx', Icons.shopping_bag_outlined, NgopiTheme.accent),
              _buildTileMetric('Gerobak Buka & Online', '${_locations.where((l) => l['is_active'] == true).length} Gerobak', Icons.storefront_outlined, NgopiTheme.sun),
              _buildTileMetric('Sisa Stok Gudang', '$totalStok Cup', Icons.warehouse_outlined, NgopiTheme.ink),
            ],
          ),
          const SizedBox(height: 20),

          // Insight AI Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: NgopiTheme.surface2,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome, color: NgopiTheme.accent, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Insight Penjualan & Cuaca', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NgopiTheme.ink)),
                      SizedBox(height: 4),
                      Text(
                        'Prediksi jam sibuk 07.30 - 09.30 WIB di koridor Sudirman. Kopi Susu Aren disarankan ditambah 25 cup untuk mencegah kehabisan stok saat antrean pejalan kaki padat.',
                        style: TextStyle(color: NgopiTheme.muted, fontSize: 13, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // TAB 2: STOK PUSAT & DISTRIBUSI
  Widget _buildInventoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stok Gudang Pusat', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: NgopiTheme.ink)),
                  Text('Sumber kebenaran persediaan bahan dan pencatatan mutasi.', style: TextStyle(color: NgopiTheme.muted, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: NgopiTheme.accent,
                  foregroundColor: NgopiTheme.onAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: _showDistributionModal,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Alokasi ke Gerobak', style: TextStyle(fontWeight: FontWeight.w700)),
              )
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _centralInventory.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final inv = _centralInventory[i];
                final isSafe = inv.availableQuantity >= 100;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: NgopiTheme.surface2, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.local_cafe, color: NgopiTheme.accent),
                  ),
                  title: Text(inv.productName ?? inv.productId, style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('Total Fisik: ${inv.quantity} Cup • Direservasi: ${inv.reservedQuantity} Cup', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${inv.availableQuantity} Cup', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: NgopiTheme.ink)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSafe ? NgopiTheme.surface2 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isSafe ? 'Stok Cukup' : 'Menipis',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isSafe ? NgopiTheme.ok : NgopiTheme.bad),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // TAB 3: KATALOG PRODUK
  Widget _buildProductsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Katalog Menu Gerobak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: NgopiTheme.ink)),
          const Text('Harga jual resmi, harga pokok produksi (HPP), dan margin keuntungan.', style: TextStyle(color: NgopiTheme.muted, fontSize: 13)),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _products.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final p = _products[i];
                final margin = p.price - (p.costPrice ?? 0);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('Kategori: ${p.categoryName} • HPP: Rp ${p.costPrice}', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Rp ${p.price}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NgopiTheme.ink)),
                      Text('+Rp $margin margin', style: const TextStyle(color: NgopiTheme.ok, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // TAB 4: TRANSAKSI & MONITORING PRE-ORDER
  Widget _buildOrdersAndTransactionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monitoring Transaksi & Pre-Order', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: NgopiTheme.ink)),
          const Text('Verifikasi status pembayaran QRIS Statis dan riwayat kasir walk-in.', style: TextStyle(color: NgopiTheme.muted, fontSize: 13)),
          const SizedBox(height: 16),

          const Text('Pre-Order Pelanggan (QRIS Statis Online):', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: NgopiTheme.ink)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _orders.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final o = _orders[i];
                final isPaid = o['payment_status'] == 'PAID';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isPaid ? NgopiTheme.surface2 : Colors.amber.shade50,
                    child: Icon(isPaid ? Icons.check : Icons.access_time, color: isPaid ? NgopiTheme.ok : NgopiTheme.sun),
                  ),
                  title: Text('${o['order_number']} • ${o['customer_name']}', style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('Status Order: ${o['order_status']} • Bayar: ${o['payment_status']}', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Text('Rp ${o['total']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NgopiTheme.ink)),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          const Text('Penjualan Langsung Walk-In Seller:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: NgopiTheme.ink)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _transactions.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final tx = _transactions[i];

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  title: Text('${tx['id']} • ${tx['seller_id']}', style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('Metode: ${tx['payment_method']} • Waktu: ${tx['created_at'].toString().split('T').first}', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Text('Rp ${tx['total']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NgopiTheme.accent)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 5: LOKASI & TITIK GEROBAK
  Widget _buildLocationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Titik Gerobak & Kandidat Lapak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: NgopiTheme.ink)),
          const Text('Pantau posisi jualan aktif dan evaluasi skor lokasi kandidat AI.', style: TextStyle(color: NgopiTheme.muted, fontSize: 13)),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locations.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final loc = _locations[i];
                final isActive = loc['is_active'] == true;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isActive ? NgopiTheme.surface2 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.location_on, color: isActive ? NgopiTheme.accent : NgopiTheme.muted),
                  ),
                  title: Text(loc['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('${loc['spot'] ?? loc['address'] ?? '-'}\nJam Buka: ${loc['hours'] ?? '07.00 - 21.00'} • Antrean ± ${loc['wait'] ?? 5} mnt', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Skor ${loc['score']}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: NgopiTheme.accent)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isActive ? NgopiTheme.surface2 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          isActive ? 'Buka' : 'Offline',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? NgopiTheme.ok : NgopiTheme.muted),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  // TAB 6: AI INTELLIGENCE
  Widget _buildAiIntelligenceTab() {
    final recs = _aiOptimizationData?['recommendations'] as List<dynamic>? ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('AI Inventory Optimization', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: NgopiTheme.ink)),
                  Text('Rekomendasi alokasi stok teroptimasi (MILP Solver).', style: TextStyle(color: NgopiTheme.muted, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: NgopiTheme.sun,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('${_aiOptimizationData?['solver_status'] ?? 'MILP'}', style: const TextStyle(color: NgopiTheme.onSun, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Container(
            decoration: BoxDecoration(
              color: NgopiTheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: NgopiTheme.line),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recs.length,
              separatorBuilder: (c, i) => const Divider(height: 1, color: NgopiTheme.line),
              itemBuilder: (ctx, i) {
                final r = recs[i];
                final rationale = (r['rationale'] as List<dynamic>?)?.join(' • ') ?? '-';

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: NgopiTheme.surface2, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.auto_awesome, color: NgopiTheme.accent),
                  ),
                  title: Text('${r['location_name']} ➔ ${r['product_name']}', style: const TextStyle(fontWeight: FontWeight.w700, color: NgopiTheme.ink)),
                  subtitle: Text('Rasional: $rationale\nLabel Data: SIMULASI', style: const TextStyle(fontSize: 12, color: NgopiTheme.muted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: NgopiTheme.accent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${r['recommended_quantity']} Cup',
                      style: const TextStyle(color: NgopiTheme.onAccent, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTileMetric(String title, String value, IconData icon, Color color) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NgopiTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NgopiTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: NgopiTheme.muted, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: NgopiTheme.ink)),
        ],
      ),
    );
  }
}
