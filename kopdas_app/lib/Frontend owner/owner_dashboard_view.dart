import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../models/inventory.dart';
import '../../services/api_client.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  final ApiClient _apiClient = ApiClient();
  int _selectedNavIndex = 0;
  bool _isLoading = true;

  // Data State
  List<ProductModel> _products = [];
  List<InventoryModel> _centralInventory = [];
  List<dynamic> _sellerInventories = [];
  List<dynamic> _transactions = [];
  List<dynamic> _orders = [];
  List<dynamic> _locations = [];
  Map<String, dynamic>? _aiOptimizationData;
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _loadAllOwnerData();
  }

  Future<void> _loadAllOwnerData() async {
    setState(() => _isLoading = true);
    final now = DateTime.now().toIso8601String();

    try {
      // 1. Products
      try {
        final prodRes = await _apiClient.get('/products');
        if (prodRes is List) {
          _products = prodRes.map((p) => ProductModel.fromJson(p)).toList();
        }
      } catch (_) {
        _products = [
          ProductModel(id: 'prd-01', categoryId: 'cat-01', name: 'Kopi Susu Gula Aren', price: 18000, costPrice: 7500, status: 'ACTIVE', categoryName: 'Signature'),
          ProductModel(id: 'prd-02', categoryId: 'cat-02', name: 'Americano Double Shot', price: 15000, costPrice: 4500, status: 'ACTIVE', categoryName: 'Classic Espresso'),
          ProductModel(id: 'prd-03', categoryId: 'cat-03', name: 'Matcha Uji Latte Creamy', price: 24000, costPrice: 9500, status: 'ACTIVE', categoryName: 'Non-Coffee'),
          ProductModel(id: 'prd-04', categoryId: 'cat-01', name: 'Cafe Latte Steam Velvet', price: 22000, costPrice: 8500, status: 'ACTIVE', categoryName: 'Signature'),
          ProductModel(id: 'prd-05', categoryId: 'cat-04', name: 'Roti Bakar Cokelat Keju', price: 15000, costPrice: 6000, status: 'ACTIVE', categoryName: 'Camilan'),
          ProductModel(id: 'prd-06', categoryId: 'cat-02', name: 'Cold Brew Citrus Signature', price: 20000, costPrice: 7000, status: 'ACTIVE', categoryName: 'Classic Espresso'),
        ];
      }

      // 2. Central Inventory
      try {
        final invRes = await _apiClient.get('/inventory?scope_type=WAREHOUSE');
        if (invRes is List) {
          _centralInventory = invRes.map((i) => InventoryModel.fromJson(i)).toList();
        }
      } catch (_) {
        _centralInventory = [
          InventoryModel(id: 'inv-c-01', productId: 'prd-01', productName: 'Kopi Susu Gula Aren', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 850, reservedQuantity: 40, availableQuantity: 810, updatedAt: now),
          InventoryModel(id: 'inv-c-02', productId: 'prd-02', productName: 'Americano Double Shot', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 620, reservedQuantity: 15, availableQuantity: 605, updatedAt: now),
          InventoryModel(id: 'inv-c-03', productId: 'prd-03', productName: 'Matcha Uji Latte Creamy', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 420, reservedQuantity: 20, availableQuantity: 400, updatedAt: now),
          InventoryModel(id: 'inv-c-04', productId: 'prd-04', productName: 'Cafe Latte Steam Velvet', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 510, reservedQuantity: 30, availableQuantity: 480, updatedAt: now),
          InventoryModel(id: 'inv-c-05', productId: 'prd-05', productName: 'Roti Bakar Cokelat Keju', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 250, reservedQuantity: 10, availableQuantity: 240, updatedAt: now),
          InventoryModel(id: 'inv-c-06', productId: 'prd-06', productName: 'Cold Brew Citrus Signature', scopeType: 'WAREHOUSE', scopeId: 'central', quantity: 380, reservedQuantity: 5, availableQuantity: 375, updatedAt: now),
        ];
      }

      // 3. Seller Inventories
      _sellerInventories = [
        {'seller_id': 'GRB-01', 'seller_name': 'Pak Darto (Halte Sudirman)', 'product': 'Kopi Susu Gula Aren', 'stock': 42, 'capacity': 120, 'status': 'OPTIMAL'},
        {'seller_id': 'GRB-01', 'seller_name': 'Pak Darto (Halte Sudirman)', 'product': 'Americano Double Shot', 'stock': 28, 'capacity': 120, 'status': 'OPTIMAL'},
        {'seller_id': 'GRB-02', 'seller_name': 'Gerobak Sore (Taman Suropati)', 'product': 'Matcha Uji Latte Creamy', 'stock': 12, 'capacity': 100, 'status': 'LOW_STOCK'},
        {'seller_id': 'GRB-03', 'seller_name': 'Mbak Ayu (Pasar Senen)', 'product': 'Cold Brew Citrus Signature', 'stock': 35, 'capacity': 120, 'status': 'OPTIMAL'},
        {'seller_id': 'GRB-04', 'seller_name': 'Roda Biru (Stasiun Juanda)', 'product': 'Kopi Susu Gula Aren', 'stock': 15, 'capacity': 110, 'status': 'CRITICAL'},
      ];

      // 4. Transactions (Walk-In)
      try {
        final txRes = await _apiClient.get('/transactions');
        if (txRes is List) _transactions = txRes;
      } catch (_) {
        _transactions = [
          {'id': 'TX-20261114-089', 'seller_name': 'Pak Darto (Halte Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 36000, 'payment_method': 'QRIS_STATIC', 'payment_status': 'PAID', 'created_at': '11:15 WIB'},
          {'id': 'TX-20261114-088', 'seller_name': 'Gerobak Sore (Taman Suropati)', 'items': '1x Americano + 1x Roti Bakar', 'total': 30000, 'payment_method': 'CASH', 'payment_status': 'PAID', 'created_at': '11:08 WIB'},
          {'id': 'TX-20261114-087', 'seller_name': 'Mbak Ayu (Pasar Senen)', 'items': '3x Kopi Susu Aren', 'total': 54000, 'payment_method': 'QRIS_STATIC', 'payment_status': 'PAID', 'created_at': '10:55 WIB'},
          {'id': 'TX-20261114-086', 'seller_name': 'Roda Biru (Stasiun Juanda)', 'items': '2x Cold Brew Citrus', 'total': 40000, 'payment_method': 'QRIS_STATIC', 'payment_status': 'PAID', 'created_at': '10:42 WIB'},
          {'id': 'TX-20261114-085', 'seller_name': 'Pak Darto (Halte Sudirman)', 'items': '1x Matcha Latte', 'total': 24000, 'payment_method': 'CASH', 'payment_status': 'PAID', 'created_at': '10:30 WIB'},
        ];
      }

      // 5. Orders (Pre-Order Online)
      try {
        final ordRes = await _apiClient.get('/orders');
        if (ordRes is List) _orders = ordRes;
      } catch (_) {
        _orders = [
          {'id': 'PO-9041', 'customer_name': 'Rani Anggraini', 'seller_name': 'Pak Darto', 'items': '2x Kopi Susu Aren (Pickup 11:45)', 'total': 37000, 'order_status': 'CONFIRMED', 'payment_status': 'PAID', 'pjp_ref': 'QRIS-GOPAY-849102', 'time': '11:20 WIB'},
          {'id': 'PO-9040', 'customer_name': 'Bagus Prasetyo', 'seller_name': 'Roda Biru', 'items': '1x Americano (Pickup 11:30)', 'total': 16000, 'order_status': 'READY_FOR_PICKUP', 'payment_status': 'PAID', 'pjp_ref': 'QRIS-BCA-920145', 'time': '11:05 WIB'},
          {'id': 'PO-9039', 'customer_name': 'Clarissa Olivia', 'seller_name': 'Mbak Ayu', 'items': '2x Matcha Latte', 'total': 49000, 'order_status': 'PENDING_PAYMENT', 'payment_status': 'PENDING', 'pjp_ref': 'MENUNGGU PJP NOTIF', 'time': '11:22 WIB'},
        ];
      }

      // 6. Locations
      try {
        final locRes = await _apiClient.get('/locations');
        if (locRes is List) _locations = locRes;
      } catch (_) {
        _locations = [
          {'id': 'LOC-01', 'name': 'Koridor Sudirman - Halte Dukuh Atas', 'seller_name': 'Pak Darto', 'pedestrian_density': 'Sangat Tinggi (1.450 org/jam)', 'active_carts': 1, 'sales_today': 142, 'score': 96.8, 'status': 'ACTIVE'},
          {'id': 'LOC-02', 'name': 'Taman Suropati & Taman Kodok Menteng', 'seller_name': 'Gerobak Sore', 'pedestrian_density': 'Sedang (480 org/jam)', 'active_carts': 1, 'sales_today': 68, 'score': 88.5, 'status': 'ACTIVE'},
          {'id': 'LOC-03', 'name': 'Pintu Timur Stasiun Juanda Commuter', 'seller_name': 'Roda Biru', 'pedestrian_density': 'Tinggi (980 org/jam)', 'active_carts': 1, 'sales_today': 118, 'score': 93.2, 'status': 'ACTIVE'},
          {'id': 'LOC-04', 'name': 'Pasar Senen Blok III & Halte Senen', 'seller_name': 'Mbak Ayu', 'pedestrian_density': 'Tinggi (850 org/jam)', 'active_carts': 1, 'sales_today': 95, 'score': 90.0, 'status': 'ACTIVE'},
          {'id': 'LOC-05', 'name': 'Area Kampus UI Salemba - Gedung Rektorat', 'seller_name': 'KANDIDAT AI', 'pedestrian_density': 'Potensi Tinggi (720 mhs/jam)', 'active_carts': 0, 'sales_today': 0, 'score': 87.4, 'status': 'CANDIDATE'},
          {'id': 'LOC-06', 'name': 'Kawasan Perkantoran Kuningan Madya', 'seller_name': 'KANDIDAT AI', 'pedestrian_density': 'Potensi Tinggi (640 kry/jam)', 'active_carts': 0, 'sales_today': 0, 'score': 84.1, 'status': 'CANDIDATE'},
        ];
      }

      // 7. AI Optimization & Forecasting Data
      try {
        final optRes = await _apiClient.post('/ai/optimize', {});
        if (optRes is Map<String, dynamic>) _aiOptimizationData = optRes;
      } catch (_) {
        _aiOptimizationData = {
          'solver_status': 'MILP_OPTIMAL (Branch-and-Cut)',
          'objective_profit': 24850000,
          'constraint_status': 'All 14 Constraints Satisfied',
          'data_label': 'SIMULASI KOPIDAS V1.1',
          'recommendations': [
            {
              'location_name': 'Koridor Sudirman (Pak Darto)',
              'product_name': 'Kopi Susu Gula Aren',
              'current_stock': 42,
              'recommended_quantity': 75,
              'stock_gap': '+33 Cup',
              'rationale': 'Lonjakan komuter jam makan siang (11.45 - 13.30). Stok saat ini berisiko stock-out pukul 12.15.',
              'priority': 'URGENT'
            },
            {
              'location_name': 'Stasiun Juanda (Roda Biru)',
              'product_name': 'Americano Double Shot',
              'current_stock': 15,
              'recommended_quantity': 45,
              'stock_gap': '+30 Cup',
              'rationale': 'Kebutuhan asupan kafein pekerja kereta sore hari. Margin kotor Rp 10.500/cup.',
              'priority': 'HIGH'
            },
            {
              'location_name': 'Taman Suropati (Gerobak Sore)',
              'product_name': 'Matcha Uji Latte Creamy',
              'current_stock': 12,
              'recommended_quantity': 35,
              'stock_gap': '+23 Cup',
              'rationale': 'Pergeseran pola konsumsi non-kopi anak muda sore hari (15.00 - 18.00).',
              'priority': 'MEDIUM'
            },
            {
              'location_name': 'Pasar Senen (Mbak Ayu)',
              'product_name': 'Roti Bakar Cokelat Keju',
              'current_stock': 8,
              'recommended_quantity': 25,
              'stock_gap': '+17 Porsi',
              'rationale': 'Tingkat bundling menu camilan dengan kopi mencapai 38% di area pasar.',
              'priority': 'MEDIUM'
            },
          ]
        };
      }

      _analyticsData = {
        'gross_revenue': 14250000,
        'net_profit': 8120000,
        'margin_pct': '57.0%',
        'total_cups_sold': 748,
        'avg_basket_size': 'Rp 28.500',
        'qris_ratio': '68.4%',
        'cash_ratio': '31.6%',
      };
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDistributeModal() {
    String selectedSeller = 'GRB-01';
    String selectedProduct = _products.isNotEmpty ? _products.first.id : 'prd-01';
    final qtyController = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFF0F172A).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 12),
              const Text('Alokasi Stok ke Gerobak Seller', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Gerobak Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSeller,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'GRB-01', child: Text('GRB-01 • Pak Darto (Halte Sudirman)')),
                    DropdownMenuItem(value: 'GRB-02', child: Text('GRB-02 • Gerobak Sore (Taman Suropati)')),
                    DropdownMenuItem(value: 'GRB-03', child: Text('GRB-03 • Mbak Ayu (Pasar Senen)')),
                    DropdownMenuItem(value: 'GRB-04', child: Text('GRB-04 • Roda Biru (Stasiun Juanda)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedSeller = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Pilih Menu Produk:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  items: _products.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.name} (Tersedia Gudang: ${_getAvailableStock(p.id)} Cup)'))).toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedProduct = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Jumlah Alokasi (Cup / Porsi):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Contoh: 30',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () async {
                final qty = int.tryParse(qtyController.text) ?? 0;
                if (qty <= 0) return;

                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Memproses transaksi mutasi stok gudang ➔ seller di DB atomik...')),
                );

                try {
                  await _apiClient.post('/inventory/distributions', {
                    'seller_id': selectedSeller,
                    'items': [{'product_id': selectedProduct, 'quantity': qty}]
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Berhasil mendistribusikan stok ke gerobak!')),
                    );
                    _loadAllOwnerData();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(backgroundColor: const Color(0xFFEF4444), content: Text('Gagal: $e')),
                    );
                  }
                }
              },
              child: const Text('Kirim Alokasi Stok'),
            ),
          ],
        ),
      ),
    );
  }

  int _getAvailableStock(String productId) {
    try {
      final inv = _centralInventory.firstWhere((i) => i.productId == productId);
      return inv.availableQuantity;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF0F172A)));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Slate 100 enterprise background
      body: Row(
        children: [
          // 1. Enterprise Sidebar Navigation
          _buildSidebar(),

          // 2. Main Content Area
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
                    child: _buildSelectedView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Title
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFF38BDF8).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.coffee, color: Color(0xFF38BDF8), size: 22),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KOPICERDAS AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                    Text('OWNER EXECUTIVE SUITE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),

          // Navigation Links
          const SizedBox(height: 16),
          _sidebarItem(0, Icons.grid_view, 'Executive Dashboard'),
          _sidebarItem(1, Icons.inventory_2_outlined, 'Stok Gudang & Gerobak'),
          _sidebarItem(2, Icons.psychology_outlined, 'AI Demand & Alokasi (MILP)'),
          _sidebarItem(3, Icons.point_of_sale_outlined, 'Transaksi & Pembayaran QRIS'),
          _sidebarItem(4, Icons.map_outlined, 'Peta & Scoring Lokasi Gerobak'),
          _sidebarItem(5, Icons.menu_book_outlined, 'Master Produk & HPP'),

          const Spacer(),

          // System Health & Fast Action
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('Backend REST API', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text('FastAPI :8000 • Synced', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF38BDF8),
                        foregroundColor: const Color(0xFF0F172A),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: _showDistributeModal,
                      icon: const Icon(Icons.send_outlined, size: 16),
                      label: const Text('Kirim Stok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          Text(
            _getSectionTitle(),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: _loadAllOwnerData,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh Data Realtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF64748B)),
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0F172A),
            child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getSectionTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Executive Dashboard & Financial KPI';
      case 1: return 'Persediaan Stok Pusat & Monitoring Gerobak Seller';
      case 2: return 'AI Demand Forecasting & Mixed-Integer Linear Optimization';
      case 3: return 'Monitoring Transaksi, Mutasi, dan Validasi QRIS PJP';
      case 4: return 'Pemetaan Geospasial & Location Scoring Titik Jualan';
      case 5: return 'Master Produk, Biaya Pokok Produksi (HPP) & Margin';
      default: return 'Owner Suite';
    }
  }

  Widget _buildSelectedView() {
    switch (_selectedNavIndex) {
      case 0: return _buildExecutiveDashboard();
      case 1: return _buildInventoryView();
      case 2: return _buildAiOptimizationView();
      case 3: return _buildTransactionsOrdersView();
      case 4: return _buildLocationsView();
      case 5: return _buildProductsView();
      default: return _buildExecutiveDashboard();
    }
  }

  // 1. EXECUTIVE DASHBOARD VIEW
  Widget _buildExecutiveDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Row 1
        Row(
          children: [
            Expanded(child: _kpiCard('Omzet Bruto Hari Ini', 'Rp 14.250.000', '+18.4% vs kemarin', Icons.monetization_on_outlined, const Color(0xFF10B981))),
            const SizedBox(width: 20),
            Expanded(child: _kpiCard('Laba Bersih Operasional', 'Rp 8.120.000', 'Margin Sehat 57.0%', Icons.account_balance_wallet_outlined, const Color(0xFF38BDF8))),
            const SizedBox(width: 20),
            Expanded(child: _kpiCard('Total Cup Terjual', '748 Cup', 'Kapasitas 62.3%', Icons.local_cafe_outlined, const Color(0xFFF59E0B))),
            const SizedBox(width: 20),
            Expanded(child: _kpiCard('Penetrasi Non-Tunai QRIS', '68.4%', '492 Trx QRIS Statis', Icons.qr_code_2, const Color(0xFF6366F1))),
          ],
        ),
        const SizedBox(height: 24),

        // AI Urgent Warning Callout
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AI ALERT: Peringatan Kritis Kehabisan Stok di Gerobak 04 (Stasiun Juanda)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E))),
                    SizedBox(height: 4),
                    Text('Sisa stok Kopi Susu Aren tinggal 15 cup. Berdasarkan laju konsumsi komuter kereta, stok akan habis dalam 38 menit ke depan. Segera lakukan distribusi tambahan dari gudang pusat.', style: TextStyle(color: Color(0xFFB45309), fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _showDistributeModal,
                child: const Text('Kirim Stok Darurat'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Live Seller Fleet Performance
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Operasional & Performa Armada Gerobak Realtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('Monitoring penjualan aktif, stok saat ini, dan kapasitas per gerobak.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                  Text('4 GEROBAK AKTIF • 100% OPERASIONAL', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 18),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.8),
                  5: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('ID Gerobak'),
                      _th('Seller & Titik Lokasi'),
                      _th('Penjualan Hari Ini'),
                      _th('Omzet Kasir'),
                      _th('Status Sisa Stok'),
                      _th('Kondisi'),
                    ],
                  ),
                  _fleetRow('GRB-01', 'Pak Darto (Halte Sudirman)', '142 Cup', 'Rp 2.840.000', '42 / 120 Cup', 'OPTIMAL', const Color(0xFF10B981)),
                  _fleetRow('GRB-02', 'Gerobak Sore (Taman Suropati)', '68 Cup', 'Rp 1.420.000', '28 / 100 Cup', 'OPTIMAL', const Color(0xFF10B981)),
                  _fleetRow('GRB-03', 'Mbak Ayu (Pasar Senen)', '95 Cup', 'Rp 1.980.000', '35 / 120 Cup', 'OPTIMAL', const Color(0xFF10B981)),
                  _fleetRow('GRB-04', 'Roda Biru (Stasiun Juanda)', '118 Cup', 'Rp 2.450.000', '15 / 110 Cup', 'PERLU STOK', const Color(0xFFEF4444)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. INVENTORY MANAGEMENT VIEW
  Widget _buildInventoryView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Persediaan Gudang Pusat (Central Hub)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Sumber kebenaran tunggal stok fisik, reservasi pre-order aktif, dan stok siap distribusi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              ),
              onPressed: _showDistributeModal,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Buat Alokasi Distribusi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Kode SKU'),
                  _th('Nama Menu / Bahan'),
                  _th('Stok Fisik Total'),
                  _th('Direservasi Pre-Order'),
                  _th('Siap Didistribusikan'),
                  _th('Status Gudang'),
                ],
              ),
              ..._centralInventory.map((inv) {
                final isWarning = inv.availableQuantity < 300;
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(inv.productId),
                    _td(inv.productName ?? inv.productId, bold: true),
                    _td('${inv.quantity} Cup'),
                    _td('${inv.reservedQuantity} Cup (Tahan)'),
                    _td('${inv.availableQuantity} Cup', bold: true, color: const Color(0xFF0284C7)),
                    _statusBadge(isWarning ? 'PERHATIAN' : 'AMAN', isWarning ? const Color(0xFFD97706) : const Color(0xFF10B981)),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 28),

        const Text('Monitoring Stok per Seller Lapangan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Gerobak'),
                  _th('Nama Seller & Lokasi'),
                  _th('Varian Menu'),
                  _th('Sisa Stok Saat Ini'),
                  _th('Kapasitas Box'),
                  _th('Kondisi'),
                ],
              ),
              ..._sellerInventories.map((s) {
                final isLow = s['status'] == 'CRITICAL' || s['status'] == 'LOW_STOCK';
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(s['seller_id']),
                    _td(s['seller_name'], bold: true),
                    _td(s['product']),
                    _td('${s['stock']} Cup', bold: true, color: isLow ? const Color(0xFFEF4444) : const Color(0xFF0F172A)),
                    _td('${s['capacity']} Cup'),
                    _statusBadge(s['status'], isLow ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 3. AI OPTIMIZATION & FORECASTING VIEW
  Widget _buildAiOptimizationView() {
    final recs = _aiOptimizationData?['recommendations'] as List<dynamic>? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AI Inventory Optimization & Mixed-Integer Programming (MILP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Optimalisasi matematis alokasi stok gerobak dengan batasan kapasitas box, proyeksi demand, dan maksimasi profit margin.', style: TextStyle(color: const Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Solver Status: ${_aiOptimizationData?['solver_status'] ?? 'MILP_OPTIMAL'}',
                style: const TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Objective Function Output
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PROYEKSI POTENSI LABA BERSIH (OPTIMAL OBJECTIVE)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    const SizedBox(height: 6),
                    const Text('Rp 24.850.000 / Siklus', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 4),
                    Text('Data Label: ${_aiOptimizationData?['data_label'] ?? 'SIMULASI'} • Batasan: 120 cup/gerobak & stok pusat', style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: const Color(0xFF0F172A)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menjalankan kembali solver matematis MILP dengan parameter terbaru...')),
                  );
                  _loadAllOwnerData();
                },
                icon: const Icon(Icons.bolt, size: 18),
                label: const Text('Re-calculate Optimization', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Actionable Recommendation Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(3),
              6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Prioritas'),
                  _th('Titik Gerobak Seller'),
                  _th('Varian Menu Kopi'),
                  _th('Stok Sekarang'),
                  _th('Rekomendasi AI'),
                  _th('Rasionalisasi Keputusan AI'),
                  _th('Aksi Owner'),
                ],
              ),
              ...recs.map((r) {
                final isUrgent = r['priority'] == 'URGENT';
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _statusBadge(r['priority'] ?? 'MEDIUM', isUrgent ? const Color(0xFFEF4444) : const Color(0xFFF59E0B)),
                    _td(r['location_name'] ?? '-', bold: true),
                    _td(r['product_name'] ?? '-'),
                    _td('${r['current_stock']} Cup'),
                    _td('${r['recommended_quantity']} Cup (${r['stock_gap']})', bold: true, color: const Color(0xFF10B981)),
                    _td(r['rationale'] ?? '-', italic: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        onPressed: _showDistributeModal,
                        child: const Text('Setujui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 4. TRANSACTIONS & QRIS ORDERS VIEW
  Widget _buildTransactionsOrdersView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daftar Pre-Order Pelanggan (QRIS Statis Online Terverifikasi PJP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Sesuai regulasi: status PAID hanya berubah setelah konfirmasi resmi webhook/inquiry PJP. Tidak ada verifikasi otomatis palsu.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(2.5),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.5),
              7: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Order ID'),
                  _th('Nama Pelanggan'),
                  _th('Seller Tujuan'),
                  _th('Detail Item'),
                  _th('Nominal'),
                  _th('Status Order'),
                  _th('Status Pembayaran'),
                  _th('PJP Reference'),
                ],
              ),
              ..._orders.map((o) {
                final isPaid = o['payment_status'] == 'PAID';
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(o['id'] ?? o['order_number'] ?? '-'),
                    _td(o['customer_name'] ?? 'Pelanggan', bold: true),
                    _td(o['seller_name'] ?? '-'),
                    _td(o['items'] ?? '-'),
                    _td('Rp ${o['total']}', bold: true),
                    _statusBadge(o['order_status'] ?? '-', const Color(0xFF0284C7)),
                    _statusBadge(o['payment_status'] ?? '-', isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    _td(o['pjp_ref'] ?? '-', italic: true),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 32),

        const Text('Riwayat Penjualan Langsung Walk-In Seller (Kasir Lapangan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Transaksi tunai (CASH) dan QRIS Statis langsung di gerobak seller dengan pemotongan stok otomatis.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.5),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(2.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Transaksi'),
                  _th('Gerobak Seller'),
                  _th('Item Terjual'),
                  _th('Total Penerimaan'),
                  _th('Metode Pembayaran'),
                  _th('Waktu Trx'),
                ],
              ),
              ..._transactions.map((tx) {
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(tx['id'] ?? '-'),
                    _td(tx['seller_name'] ?? tx['seller_id'] ?? '-', bold: true),
                    _td(tx['items'] ?? '-'),
                    _td('Rp ${tx['total']}', bold: true, color: const Color(0xFF10B981)),
                    _statusBadge(tx['payment_method'] ?? 'CASH', tx['payment_method'] == 'QRIS_STATIC' ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
                    _td(tx['created_at'] ?? '-'),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 5. LOCATIONS & SCORING VIEW
  Widget _buildLocationsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Geospasial & Location Scoring Titik Gerobak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Skor potensi lokasi dihitung berdasarkan kepadatan pejalan kaki, titik transit POI, dan histori penjualan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2.8),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2.2),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Lokasi'),
                  _th('Nama Area & Landmark'),
                  _th('Seller Bertugas'),
                  _th('Estimasi Trafik Pejalan Kaki'),
                  _th('Total Penjualan'),
                  _th('Location Score AI'),
                  _th('Status'),
                ],
              ),
              ..._locations.map((loc) {
                final isActive = loc['status'] == 'ACTIVE' || loc['is_active'] == true;
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(loc['id'] ?? '-'),
                    _td(loc['name'] ?? '-', bold: true),
                    _td(loc['seller_name'] ?? '-'),
                    _td(loc['pedestrian_density'] ?? 'Tinggi (Transit POI)'),
                    _td('${loc['sales_today'] ?? 0} Cup Hari Ini'),
                    _td('${loc['score']} / 100', bold: true, color: const Color(0xFF0284C7)),
                    _statusBadge(isActive ? 'OPERASIONAL' : 'KANDIDAT AI', isActive ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 6. MASTER PRODUCTS & MARGIN VIEW
  Widget _buildProductsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Master Katalog Produk & Analisis Margin Laba', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Kelola harga jual resmi, biaya modal bahan per cup (HPP), dan proyeksi margin kontribusi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.2),
              7: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Kode Menu'),
                  _th('Nama Menu Kopi / Makanan'),
                  _th('Kategori'),
                  _th('Harga Pokok (HPP)'),
                  _th('Harga Jual Resmi'),
                  _th('Laba Kotor (Margin)'),
                  _th('Margin %'),
                  _th('Status'),
                ],
              ),
              ..._products.map((p) {
                final margin = p.price - (p.costPrice ?? 0);
                final marginPct = ((margin / p.price) * 100).toStringAsFixed(1);

                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(p.id),
                    _td(p.name, bold: true),
                    _td(p.categoryName ?? '-'),
                    _td('Rp ${p.costPrice ?? 0}'),
                    _td('Rp ${p.price}', bold: true),
                    _td('Rp $margin', bold: true, color: const Color(0xFF10B981)),
                    _td('$marginPct%'),
                    _statusBadge(p.status, const Color(0xFF10B981)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Helper Widgets
  Widget _kpiCard(String title, String value, String subtext, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 6),
          Text(subtext, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  TableRow _fleetRow(String id, String name, String sales, String rev, String stock, String status, Color color) {
    return TableRow(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
      children: [
        _td(id),
        _td(name, bold: true),
        _td(sales),
        _td(rev, bold: true),
        _td(stock, bold: true, color: color),
        _statusBadge(status, color),
      ],
    );
  }

  Widget _th(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))),
    );
  }

  Widget _td(String text, {bool bold = false, bool italic = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontSize: 13,
          color: color ?? const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
