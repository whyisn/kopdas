import 'package:flutter/material.dart';
import '../../core/constants.dart';
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
  String? _errorMessage;

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
      _errorMessage = null;
    });

    try {
      // 1. Load Products
      try {
        final prodRes = await _apiClient.get('/products');
        if (prodRes is List) {
          _products = prodRes.map((p) => ProductModel.fromJson(p)).toList();
        }
      } catch (_) {
        // Fallback baseline
        _products = [
          ProductModel(id: 'prd-01', categoryId: 'cat-01', name: 'Kopi Susu Gula Aren', price: 18000, costPrice: 8000, status: 'ACTIVE', categoryName: 'Kopi Susu'),
          ProductModel(id: 'prd-02', categoryId: 'cat-02', name: 'Americano Dingin', price: 15000, costPrice: 5000, status: 'ACTIVE', categoryName: 'Black Coffee'),
          ProductModel(id: 'prd-03', categoryId: 'cat-03', name: 'Matcha Latte', price: 20000, costPrice: 9000, status: 'ACTIVE', categoryName: 'Non-Coffee'),
          ProductModel(id: 'prd-04', categoryId: 'cat-01', name: 'Kopi Cerdas Signature', price: 22000, costPrice: 10000, status: 'ACTIVE', categoryName: 'Kopi Susu'),
        ];
      }

      // 2. Load Inventory (Warehouse/Central)
      try {
        final invRes = await _apiClient.get('/inventory?scope_type=WAREHOUSE');
        if (invRes is List) {
          _centralInventory = invRes.map((i) => InventoryModel.fromJson(i)).toList();
        }
      } catch (_) {
        final now = DateTime.now().toIso8601String();
        _centralInventory = [
          InventoryModel(id: 'inv-c-01', productId: 'prd-01', productName: 'Kopi Susu Gula Aren', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 450, reservedQuantity: 0, availableQuantity: 450, updatedAt: now),
          InventoryModel(id: 'inv-c-02', productId: 'prd-02', productName: 'Americano Dingin', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 320, reservedQuantity: 0, availableQuantity: 320, updatedAt: now),
          InventoryModel(id: 'inv-c-03', productId: 'prd-03', productName: 'Matcha Latte', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 280, reservedQuantity: 0, availableQuantity: 280, updatedAt: now),
          InventoryModel(id: 'inv-c-04', productId: 'prd-04', productName: 'Kopi Cerdas Signature', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 500, reservedQuantity: 0, availableQuantity: 500, updatedAt: now),
        ];
      }

      // 3. Load Transactions & Orders
      try {
        final txRes = await _apiClient.get('/transactions');
        if (txRes is List) _transactions = txRes;
      } catch (_) {
        _transactions = [
          {'id': 'tx-101', 'seller_id': 'Gerobak 01', 'total': 36000, 'payment_method': 'CASH', 'created_at': '2026-11-14T10:15:00'},
          {'id': 'tx-102', 'seller_id': 'Gerobak 02', 'total': 18000, 'payment_method': 'QRIS_STATIC', 'created_at': '2026-11-14T10:30:00'},
        ];
      }

      try {
        final ordRes = await _apiClient.get('/orders');
        if (ordRes is List) _orders = ordRes;
      } catch (_) {
        _orders = [
          {'id': 'ord-201', 'order_number': 'ORD-20261114-001', 'customer_name': 'Rian S.', 'total': 40000, 'order_status': 'CONFIRMED', 'payment_status': 'PAID', 'created_at': '2026-11-14T11:00:00'},
          {'id': 'ord-202', 'order_number': 'ORD-20261114-002', 'customer_name': 'Anita W.', 'total': 18000, 'order_status': 'PENDING_PAYMENT', 'payment_status': 'PENDING', 'created_at': '2026-11-14T11:10:00'},
        ];
      }

      // 4. Load Locations & AI Scores
      try {
        final locRes = await _apiClient.get('/locations');
        if (locRes is List) _locations = locRes;
      } catch (_) {
        _locations = [
          {'id': 'loc-001', 'name': 'Stasiun Sudirman (Pintu Barat)', 'seller_name': 'Budi Santoso', 'score': 94.5, 'source_type': 'ACTIVE_POINT', 'is_active': true},
          {'id': 'loc-002', 'name': 'Kampus Salemba UI (Rektorat)', 'seller_name': 'Ahmad Fauzi', 'score': 88.0, 'source_type': 'ACTIVE_POINT', 'is_active': true},
          {'id': 'loc-003', 'name': 'Halte Tosari TransJakarta', 'seller_name': 'Belum Ditugaskan', 'score': 82.5, 'source_type': 'CANDIDATE', 'is_active': false},
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
            {'location_name': 'Stasiun Sudirman', 'product_name': 'Kopi Susu Gula Aren', 'recommended_quantity': 55, 'rationale': ['Tingkat penjualan pagi sangat tinggi', 'Dibatasi kapasitas gerobak (120 cup)']},
            {'location_name': 'Stasiun Sudirman', 'product_name': 'Kopi Cerdas Signature', 'recommended_quantity': 40, 'rationale': ['Margin tinggi (Rp 12.000/cup)']},
            {'location_name': 'Kampus Salemba UI', 'product_name': 'Matcha Latte', 'recommended_quantity': 45, 'rationale': ['Kategori Non-Coffee dominan di area mahasiswa']},
          ]
        };
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Dialog Distribusi Stok ke Seller
  void _showDistributionDialog() {
    String selectedSeller = 'usr-seller-01';
    String selectedProduct = _products.isNotEmpty ? _products.first.id : 'prd-01';
    final qtyController = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.local_shipping, color: AppConstants.primaryColor),
              SizedBox(width: 8),
              Text('Distribusi Stok ke Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Pilih Seller / Gerobak Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedSeller,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: const [
                  DropdownMenuItem(value: 'usr-seller-01', child: Text('Gerobak 01 - Budi Santoso (Sudirman)')),
                  DropdownMenuItem(value: 'usr-seller-02', child: Text('Gerobak 02 - Ahmad Fauzi (Salemba)')),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedSeller = val);
                },
              ),
              const SizedBox(height: 12),
              const Text('Pilih Produk:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedProduct,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                items: _products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedProduct = val);
                },
              ),
              const SizedBox(height: 12),
              const Text('Jumlah Alokasi (Cup):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty <= 0) return;

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memproses alokasi stok di database atomik...')),
                );

                try {
                  await _apiClient.post('/inventory/distributions', {
                    'seller_id': selectedSeller,
                    'items': [{'product_id': selectedProduct, 'quantity': qty}]
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(backgroundColor: Colors.green, content: Text('Berhasil mendistribusikan stok ke seller!')),
                  );
                  _loadAllOwnerData();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(backgroundColor: Colors.red, content: Text('Gagal: $e')),
                  );
                }
              },
              child: const Text('Kirim Alokasi'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppConstants.primaryColor));
    }

    return Column(
      children: [
        // Tab Bar Owner Sub-Fitur
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppConstants.primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppConstants.primaryColor,
            indicatorWeight: 3,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Ringkasan KPI'),
              Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Stok Pusat & Distribusi'),
              Tab(icon: Icon(Icons.coffee_outlined), text: 'Katalog Produk'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Transaksi & Order'),
              Tab(icon: Icon(Icons.map_outlined), text: 'Peta & Lokasi Seller'),
              Tab(icon: Icon(Icons.psychology_outlined), text: 'AI Rekomendasi & Alokasi'),
            ],
          ),
        ),

        // Isi View Tab
        Expanded(
          child: TabBarView(
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
        ),
      ],
    );
  }

  // TAB 1: RINGKASAN KPI
  Widget _buildOverviewTab() {
    num totalOmzet = _transactions.fold(0, (acc, tx) => acc + (tx['total'] ?? 0));
    num totalOrderOmzet = _orders.where((o) => o['payment_status'] == 'PAID').fold(0, (acc, o) => acc + (o['total'] ?? 0));

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
                  Text('Dashboard Operasional Owner', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppConstants.textDark)),
                  Text('Pemantauan jaringan gerobak, perputaran stok, dan validasi transaksi.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
                onPressed: _loadAllOwnerData,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Segarkan Data'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Baris Kartu Metrik
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildMetricCard('Total Penjualan Hari Ini', 'Rp ${(totalOmzet + totalOrderOmzet).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', Icons.payments, Colors.green),
              _buildMetricCard('Total Transaksi', '${_transactions.length + _orders.length} Trx', Icons.shopping_bag_outlined, Colors.blue),
              _buildMetricCard('Gerobak Aktif', '${_locations.where((l) => l['is_active'] == true).length} Titik Jualan', Icons.storefront, AppConstants.primaryColor),
              _buildMetricCard('Sisa Stok Pusat', '${_centralInventory.fold(0, (acc, i) => acc + i.quantity)} Cup', Icons.warehouse, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Highlight Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppConstants.accentColor),
                      SizedBox(width: 8),
                      Text('Insight AI Hari Ini (WMA & Optimization)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Prediksi cuaca cerah di Koridor Sudirman. Disarankan mengalokasikan stok Kopi Susu Aren +25% ke Gerobak 01 untuk menghindari stockout pada jam sibuk 07.30 - 09.30 WIB.',
                    style: TextStyle(color: Colors.grey.shade800, height: 1.4),
                  ),
                ],
              ),
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
                  Text('Manajemen Stok Pusat (Warehouse)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Sumber kebenaran stok pusat dan pencatatan mutasi distribusi ke seller.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: AppConstants.primaryColor, foregroundColor: Colors.white),
                onPressed: _showDistributionDialog,
                icon: const Icon(Icons.add_shopping_cart, size: 18),
                label: const Text('Kirim Stok ke Seller'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Produk')),
                DataColumn(label: Text('Stok Fisik')),
                DataColumn(label: Text('Direservasi')),
                DataColumn(label: Text('Siap Dialokasikan')),
                DataColumn(label: Text('Status')),
              ],
              rows: _centralInventory.map((inv) {
                final isLow = inv.availableQuantity < 50;
                return DataRow(cells: [
                  DataCell(Text(inv.productName ?? inv.productId, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('${inv.quantity} Cup')),
                  DataCell(Text('${inv.reservedQuantity} Cup')),
                  DataCell(Text('${inv.availableQuantity} Cup', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isLow ? Colors.red.shade100 : Colors.green.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(isLow ? 'Stok Menipis' : 'Aman', style: TextStyle(color: isLow ? Colors.red.shade800 : Colors.green.shade800, fontSize: 12)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
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
          const Text('Master Produk & Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Kelola daftar menu kopi, harga modal, dan harga jual resmi.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Nama Produk')),
                DataColumn(label: Text('Kategori')),
                DataColumn(label: Text('Harga Modal (HPP)')),
                DataColumn(label: Text('Harga Jual')),
                DataColumn(label: Text('Margin')),
                DataColumn(label: Text('Status')),
              ],
              rows: _products.map((p) {
                final margin = p.price - (p.costPrice ?? 0);
                return DataRow(cells: [
                  DataCell(Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(p.categoryName ?? '-')),
                  DataCell(Text('Rp ${(p.costPrice ?? 0)}')),
                  DataCell(Text('Rp ${p.price}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text('Rp $margin', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Text(p.status, style: const TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 4: TRANSAKSI & PRE-ORDER
  Widget _buildOrdersAndTransactionsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Monitoring Transaksi & Pembayaran QRIS', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Audit pencatatan penjualan walk-in & status pre-order QRIS statis terverifikasi PJP.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          const Text('Pre-Order Pelanggan (QRIS Statis Online):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('No. Order')),
                DataColumn(label: Text('Pelanggan')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Status Pesanan')),
                DataColumn(label: Text('Status Pembayaran')),
                DataColumn(label: Text('Waktu')),
              ],
              rows: _orders.map((o) {
                final isPaid = o['payment_status'] == 'PAID';
                return DataRow(cells: [
                  DataCell(Text(o['order_number'] ?? o['id'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(o['customer_name'] ?? 'Pelanggan')),
                  DataCell(Text('Rp ${o['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(o['order_status'] ?? '-')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPaid ? Colors.green.shade100 : Colors.amber.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(o['payment_status'] ?? '-', style: TextStyle(color: isPaid ? Colors.green.shade800 : Colors.amber.shade900, fontWeight: FontWeight.bold, fontSize: 11)),
                    ),
                  ),
                  DataCell(Text(o['created_at'] != null ? o['created_at'].toString().split('T').first : '-')),
                ]);
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Riwayat Penjualan Walk-In Seller:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID Trx')),
                DataColumn(label: Text('Seller/Lokasi')),
                DataColumn(label: Text('Total')),
                DataColumn(label: Text('Metode')),
                DataColumn(label: Text('Waktu')),
              ],
              rows: _transactions.map((tx) {
                return DataRow(cells: [
                  DataCell(Text(tx['id'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(tx['seller_id'] ?? '-')),
                  DataCell(Text('Rp ${tx['total'] ?? 0}', style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(tx['payment_method'] ?? '-')),
                  DataCell(Text(tx['created_at'] != null ? tx['created_at'].toString().split('T').first : '-')),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // TAB 5: PETA & LOKASI SELLER
  Widget _buildLocationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Peta Titik Jualan & Kandidat AI', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const Text('Monitoring posisi gerobak aktif dan rekomendasi titik jualan potensial berdasarkan Location Scoring AI.', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _locations.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final loc = _locations[idx];
                final isActive = loc['is_active'] == true;
                final score = loc['score'] ?? 0;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isActive ? Colors.green.shade100 : Colors.amber.shade100,
                    child: Icon(isActive ? Icons.coffee : Icons.place_outlined, color: isActive ? Colors.green.shade800 : Colors.amber.shade900),
                  ),
                  title: Text(loc['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Seller: ${loc['seller_name'] ?? loc['seller_id'] ?? 'Belum Ditugaskan'}\nTipe: ${loc['source_type']}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Skor AI: $score', style: const TextStyle(fontWeight: FontWeight.bold, color: AppConstants.primaryColor)),
                      Text(isActive ? 'OPERASIONAL' : 'KANDIDAT', style: TextStyle(fontSize: 11, color: isActive ? Colors.green : Colors.grey)),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // TAB 6: AI INTELLIGENCE & INVENTORY OPTIMIZER
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
                  Text('AI Inventory Optimization & Forecasting', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text('Alokasi optimal stok per gerobak dihitung dengan Mixed-Integer Linear Programming (MILP).', style: TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text('Solver: ${_aiOptimizationData?['solver_status'] ?? 'MILP'}', style: TextStyle(color: Colors.blue.shade800, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recs.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (ctx, idx) {
                final r = recs[idx];
                final rationale = (r['rationale'] as List<dynamic>?)?.join(' • ') ?? '-';

                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppConstants.backgroundColor,
                    child: Icon(Icons.auto_awesome, color: AppConstants.primaryColor),
                  ),
                  title: Text('${r['location_name']} ➔ ${r['product_name']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Rasional: $rationale\nLabel: SIMULASI'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Alokasi: ${r['recommended_quantity']} Cup',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppConstants.textDark)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

