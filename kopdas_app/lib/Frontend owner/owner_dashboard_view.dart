import 'package:flutter/material.dart';
import 'real_web_map.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  // 13 Modul Navigasi Utama (Clean, Unnumbered)
  int _selectedNavIndex = 0;

  // Filter Waktu (Asia/Jakarta)
  String _activeTimeFilter = 'Hari Ini';

  // Search filter
  String _searchFilter = '';

  // Google Maps Live GPS State
  double _liveMapLat = -6.2088;
  double _liveMapLng = 106.8227;
  int _liveMapZoom = 15;
  String _focusedStaffId = 'USR-01';

  // ===========================================================================
  // DATA OPERASIONAL TERINTEGRASI (SINGLE SOURCE OF TRUTH)
  // ===========================================================================
  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'USR-01',
      'username': 'budi_sudirman',
      'name': 'Budi Santoso',
      'phone': '0812-8821-9901',
      'cart_id': 'GRB-01 (Sudirman)',
      'location': 'Halte Dukuh Atas Sudirman',
      'role': 'Seller Lead',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '06:15 WIB',
      'morning_stock': 120,
      'current_stock': 42,
      'cups_sold': 142,
      'cash': 900000,
      'qris': 1940000,
      'commission_rate': 2000,
      'total_commission': 284000,
      'commission_paid': false,
      'gps_status': 'Live (4m akurasi)',
      'lat_long': '-6.2088, 106.8227',
      'lat': -6.2088,
      'lng': 106.8227,
      'map_x': 180.0,
      'map_y': 150.0,
    },
    {
      'id': 'USR-02',
      'username': 'ahmad_suropati',
      'name': 'Ahmad Fauzi',
      'phone': '0813-1102-4451',
      'cart_id': 'GRB-02 (Suropati)',
      'location': 'Taman Suropati Menteng',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '06:40 WIB',
      'morning_stock': 100,
      'current_stock': 28,
      'cups_sold': 68,
      'cash': 520000,
      'qris': 900000,
      'commission_rate': 2000,
      'total_commission': 136000,
      'commission_paid': false,
      'gps_status': 'Live (6m akurasi)',
      'lat_long': '-6.1994, 106.8326',
      'lat': -6.1994,
      'lng': 106.8326,
      'map_x': 320.0,
      'map_y': 110.0,
    },
    {
      'id': 'USR-03',
      'username': 'siti_senen',
      'name': 'Siti Rahmawati',
      'phone': '0857-4491-0023',
      'cart_id': 'GRB-03 (Pasar Senen)',
      'location': 'Pojok Blok III Senen',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '05:30 WIB',
      'morning_stock': 120,
      'current_stock': 35,
      'cups_sold': 95,
      'cash': 640000,
      'qris': 1340000,
      'commission_rate': 2000,
      'total_commission': 190000,
      'commission_paid': false,
      'gps_status': 'Live (5m akurasi)',
      'lat_long': '-6.1744, 106.8432',
      'lat': -6.1744,
      'lng': 106.8432,
      'map_x': 460.0,
      'map_y': 70.0,
    },
    {
      'id': 'USR-04',
      'username': 'hendra_juanda',
      'name': 'Hendra Wijaya',
      'phone': '0821-7781-3312',
      'cart_id': 'GRB-04 (Juanda)',
      'location': 'Pintu Timur Stasiun Juanda',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '05:50 WIB',
      'morning_stock': 110,
      'current_stock': 15,
      'cups_sold': 118,
      'cash': 780000,
      'qris': 1670000,
      'commission_rate': 2000,
      'total_commission': 236000,
      'commission_paid': false,
      'gps_status': 'Live (3m akurasi)',
      'lat_long': '-6.1668, 106.8312',
      'lat': -6.1668,
      'lng': 106.8312,
      'map_x': 270.0,
      'map_y': 40.0,
    },
    {
      'id': 'USR-05',
      'username': 'rizky_kuningan',
      'name': 'Rizky Pratama',
      'phone': '0812-9900-1122',
      'cart_id': 'GRB-05 (Standby)',
      'location': 'Kuningan Madya (Lapak Rencana)',
      'role': 'Seller Trainee',
      'account_status': 'ACTIVE',
      'operational_status': 'NOT_STARTED',
      'clock_in': 'Belum Mulai',
      'morning_stock': 0,
      'current_stock': 0,
      'cups_sold': 0,
      'cash': 0,
      'qris': 0,
      'commission_rate': 1500,
      'total_commission': 0,
      'commission_paid': false,
      'gps_status': 'Offline',
      'lat_long': '-6.2185, 106.8302',
      'lat': -6.2185,
      'lng': 106.8302,
      'map_x': 240.0,
      'map_y': 230.0,
    },
  ];

  final List<Map<String, dynamic>> _warehouseStock = [
    {'sku': 'PRD-01', 'name': 'Kopi Susu Gula Aren', 'category': 'Signature', 'central_stock': 950, 'allocated': 160, 'held_by_cart': 120, 'price': 18000, 'cost': 7500, 'status': 'Aman'},
    {'sku': 'PRD-02', 'name': 'Americano Double Shot', 'category': 'Espresso', 'central_stock': 650, 'allocated': 90, 'held_by_cart': 75, 'price': 15000, 'cost': 4500, 'status': 'Aman'},
    {'sku': 'PRD-03', 'name': 'Matcha Uji Latte Creamy', 'category': 'Non-Coffee', 'central_stock': 430, 'allocated': 60, 'held_by_cart': 45, 'price': 22000, 'cost': 9000, 'status': 'Aman'},
    {'sku': 'PRD-04', 'name': 'Cafe Latte Steam Velvet', 'category': 'Signature', 'central_stock': 520, 'allocated': 50, 'held_by_cart': 40, 'price': 20000, 'cost': 8000, 'status': 'Aman'},
    {'sku': 'PRD-05', 'name': 'Cold Brew Citrus Refresh', 'category': 'Artisan Brew', 'central_stock': 310, 'allocated': 40, 'held_by_cart': 30, 'price': 22000, 'cost': 8500, 'status': 'Aman'},
    {'sku': 'PRD-06', 'name': 'Roti Bakar Kaya Butter', 'category': 'Bites', 'central_stock': 140, 'allocated': 40, 'held_by_cart': 35, 'price': 15000, 'cost': 6000, 'status': 'Stok Menipis'},
  ];

  final List<Map<String, dynamic>> _locations = [
    {'id': 'LOC-01', 'name': 'Halte Dukuh Atas Sudirman', 'seller': 'Budi Santoso (GRB-01)', 'traffic': 'Padat', 'footfall': '1.450/jam', 'score': 96.8, 'status': 'Terisi', 'lat': -6.2088, 'lng': 106.8227},
    {'id': 'LOC-02', 'name': 'Taman Suropati Menteng', 'seller': 'Ahmad Fauzi (GRB-02)', 'traffic': 'Sedang', 'footfall': '480/jam', 'score': 88.5, 'status': 'Terisi', 'lat': -6.1994, 'lng': 106.8326},
    {'id': 'LOC-03', 'name': 'Pintu Timur Stasiun Juanda', 'seller': 'Hendra Wijaya (GRB-04)', 'traffic': 'Padat Komuter', 'footfall': '1.980/jam', 'score': 93.2, 'status': 'Terisi', 'lat': -6.1668, 'lng': 106.8312},
    {'id': 'LOC-04', 'name': 'Pojok Blok III Pasar Senen', 'seller': 'Siti Rahmawati (GRB-03)', 'traffic': 'Padat Niaga', 'footfall': '850/jam', 'score': 90.0, 'status': 'Terisi', 'lat': -6.1744, 'lng': 106.8432},
    {'id': 'LOC-05', 'name': 'Kampus UI Salemba Rektorat', 'seller': 'Tersedia untuk Tim', 'traffic': 'Normal', 'footfall': '720/jam', 'score': 87.4, 'status': 'Kosong', 'lat': -6.1953, 'lng': 106.8502},
    {'id': 'LOC-06', 'name': 'Kuningan Madya (Rasuna Said)', 'seller': 'Tersedia untuk Tim', 'traffic': 'Padat Kantor', 'footfall': '640/jam', 'score': 84.1, 'status': 'Kosong', 'lat': -6.2185, 'lng': 106.8302},
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {'id': 'TRX-1089', 'time': '13:42', 'seller': 'Budi (Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 36000, 'method': 'QRIS', 'pjp': 'BCA Settlement'},
    {'id': 'TRX-1088', 'time': '13:38', 'seller': 'Hendra (Juanda)', 'items': '1x Americano Double Shot', 'total': 15000, 'method': 'TUNAI', 'pjp': 'Kasir Fisik'},
    {'id': 'TRX-1087', 'time': '13:25', 'seller': 'Ahmad (Suropati)', 'items': '1x Matcha + 1x Roti Bakar', 'total': 37000, 'method': 'QRIS', 'pjp': 'GoPay Webhook'},
    {'id': 'TRX-1086', 'time': '13:14', 'seller': 'Siti (Senen)', 'items': '2x Kopi Susu Aren', 'total': 36000, 'method': 'TUNAI', 'pjp': 'Kasir Fisik'},
  ];

  final List<Map<String, dynamic>> _customerOrders = [
    {'id': 'ORD-9042', 'time': '13:40', 'customer': 'Farhan Maulana', 'seller': 'Budi (Sudirman)', 'items': '1x Latte + 1x Roti Kaya', 'total': 35000, 'status': 'Diproses', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9041', 'time': '13:28', 'customer': 'Rani Anggraini', 'seller': 'Budi (Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 36000, 'status': 'Siap Diambil', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9040', 'time': '13:10', 'customer': 'Bagus Prasetyo', 'seller': 'Hendra (Juanda)', 'items': '1x Americano Dingin', 'total': 15000, 'status': 'Selesai', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9039', 'time': '13:35', 'customer': 'Clarissa Olivia', 'seller': 'Siti (Senen)', 'items': '2x Matcha Latte', 'total': 44000, 'status': 'Menunggu Bayar', 'pay': 'PENDING'},
  ];

  // ===========================================================================
  // INTERACTIVE MODALS
  // ===========================================================================
  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cartCtrl = TextEditingController(text: 'GRB-0${_staffList.length + 1}');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Tambah Petugas Lapangan Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Petugas', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username Aplikasi', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor WhatsApp', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: cartCtrl, decoration: const InputDecoration(labelText: 'Unit Gerobak', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              setState(() {
                _staffList.add({
                  'id': 'USR-0${_staffList.length + 1}',
                  'username': userCtrl.text.isNotEmpty ? userCtrl.text : 'seller_${_staffList.length + 1}',
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '0812-0000-0000',
                  'cart_id': cartCtrl.text,
                  'location': 'Belum ditentukan',
                  'role': 'Seller Reguler',
                  'account_status': 'ACTIVE',
                  'operational_status': 'NOT_STARTED',
                  'clock_in': 'Belum Mulai',
                  'morning_stock': 0,
                  'current_stock': 0,
                  'cups_sold': 0,
                  'cash': 0,
                  'qris': 0,
                  'commission_rate': 2000,
                  'total_commission': 0,
                  'commission_paid': false,
                  'gps_status': 'Offline',
                  'lat_long': '-6.1950, 106.8300',
                  'lat': -6.1950,
                  'lng': 106.8300,
                  'map_x': 200.0,
                  'map_y': 150.0,
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Petugas ${nameCtrl.text} berhasil ditambahkan!')));
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showAddStockDialog() {
    String selectedSku = _warehouseStock.first['sku'];
    final qtyCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Input Stok Baru Gudang Pusat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedSku,
                  decoration: const InputDecoration(labelText: 'Menu / Bahan Kopi', border: OutlineInputBorder()),
                  items: _warehouseStock.map((w) => DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['sku']} • ${w['name']} (Sisa: ${w['central_stock']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSku = val);
                  },
                ),
                const SizedBox(height: 14),
                TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Stok Masuk (Porsi)', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                setState(() {
                  for (var item in _warehouseStock) {
                    if (item['sku'] == selectedSku) {
                      item['central_stock'] = (item['central_stock'] as int) + qty;
                    }
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Stok gudang berhasil ditambah $qty porsi!')));
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDistributeStockDialog() {
    String selectedSellerId = _staffList.first['id'];
    String selectedSku = _warehouseStock.first['sku'];
    final qtyCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Distribusi Stok Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SizedBox(
            width: 440,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedSellerId,
                  decoration: const InputDecoration(labelText: 'Petugas Penerima', border: OutlineInputBorder()),
                  items: _staffList.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text('${s['name']} (${s['cart_id']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSellerId = val);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedSku,
                  decoration: const InputDecoration(labelText: 'Produk Gudang', border: OutlineInputBorder()),
                  items: _warehouseStock.map((w) => DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['name']} (Sedia: ${w['central_stock']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSku = val);
                  },
                ),
                const SizedBox(height: 12),
                TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Cup yang Dibawa', border: OutlineInputBorder())),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: () {
                final qty = int.tryParse(qtyCtrl.text) ?? 0;
                if (qty <= 0) return;
                setState(() {
                  for (var w in _warehouseStock) {
                    if (w['sku'] == selectedSku) {
                      if ((w['central_stock'] as int) < qty) return;
                      w['central_stock'] = (w['central_stock'] as int) - qty;
                    }
                  }
                  for (var s in _staffList) {
                    if (s['id'] == selectedSellerId) {
                      s['current_stock'] = (s['current_stock'] as int) + qty;
                      s['morning_stock'] = (s['morning_stock'] as int) + qty;
                    }
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Alokasi stok berhasil dikirim ke gerobak!')));
              },
              child: const Text('Kirim Stok'),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // ROOT BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC), // Calm slate canvas
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar Bersih & Minimalis (Tanpa Nomor, Tanpa Badge Rame)
          _buildMinimalSidebar(),

          // Konten Utama
          Expanded(
            child: Column(
              children: [
                _buildSimpleTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: _buildCurrentModuleView(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentModuleView() {
    switch (_selectedNavIndex) {
      case 0: return _buildDashboardView();
      case 1: return _buildStaffManagementView();
      case 2: return _buildAttendanceView();
      case 3: return _buildGoogleMapsMonitoringView();
      case 4: return _buildLocationManagementView();
      case 5: return _buildWarehouseManagementView();
      case 6: return _buildStockDistributionView();
      case 7: return _buildSalesMonitoringView();
      case 8: return _buildOrdersMonitoringView();
      case 9: return _buildCommissionSystemView();
      case 10: return _buildTrafficRadarView();
      case 11: return _buildAnalyticsReportsView();
      case 12: return _buildSettingsView();
      default: return _buildDashboardView();
    }
  }

  // ===========================================================================
  // 1. SIDEBAR MINIMALIS & PROFESIONAL
  // ===========================================================================
  Widget _buildMinimalSidebar() {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: Column(
        children: [
          // Brand Logo
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.coffee, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('KopiCerdas', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: -0.3)),
                    Text('Owner Portal', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _navItem(0, Icons.dashboard_outlined, 'Dashboard'),
                _navItem(1, Icons.people_outline, 'Tim Lapangan'),
                _navItem(2, Icons.access_time, 'Absensi Shift'),
                _navItem(3, Icons.map_outlined, 'Peta Live'),
                _navItem(4, Icons.place_outlined, 'Lapak Jualan'),
                _navItem(5, Icons.warehouse_outlined, 'Gudang & Stok'),
                _navItem(6, Icons.local_shipping_outlined, 'Distribusi Pagi'),
                _navItem(7, Icons.point_of_sale_outlined, 'Penjualan'),
                _navItem(8, Icons.receipt_long_outlined, 'Pesanan QRIS'),
                _navItem(9, Icons.military_tech_outlined, 'Komisi Tim'),
                _navItem(10, Icons.radar_outlined, 'Analisis Lokasi'),
                _navItem(11, Icons.analytics_outlined, 'Laporan Keuangan'),
                _navItem(12, Icons.settings_outlined, 'Pengaturan'),
              ],
            ),
          ),

          // User Profile Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(border: Border(top: BorderSide(color: Color(0xFF1E293B), width: 1))),
            child: const Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: Color(0xFF334155), child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Owner Pusat', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('Administrator', style: TextStyle(color: Color(0xFF64748B), fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String title) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. HEADER BERSIH
  // ===========================================================================
  Widget _buildSimpleTopHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Row(
        children: [
          Text(_getNavTitle(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
          const Spacer(),

          // Filter Waktu Ringkas
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
            child: Row(
              children: ['Hari Ini', 'Kemarin', '7 Hari', '30 Hari'].map((label) {
                final isSelected = _activeTimeFilter == label;
                return InkWell(
                  onTap: () => setState(() => _activeTimeFilter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(4), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 2)] : null),
                    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 12),

          IconButton(
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(duration: Duration(seconds: 1), content: Text('Data operasional diperbarui.')));
            },
            icon: const Icon(Icons.refresh, size: 18, color: Color(0xFF64748B)),
            tooltip: 'Segarkan data',
          ),
        ],
      ),
    );
  }

  String _getNavTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Ringkasan Bisnis & Penjualan';
      case 1: return 'Daftar & Status Petugas Lapangan';
      case 2: return 'Absensi & Jam Kerja Shift';
      case 3: return 'Peta Posisi Tim Realtime';
      case 4: return 'Daftar Titik Lapak Jualan';
      case 5: return 'Stok Gudang Pusat';
      case 6: return 'Distribusi Stok Bawaan Pagi';
      case 7: return 'Log Penjualan Lapangan';
      case 8: return 'Daftar Pesanan Pre-Order';
      case 9: return 'Sistem Komisi Tim';
      case 10: return 'Analisis Potensi Titik Jualan';
      case 11: return 'Laporan Keuangan & Laba Bersih';
      case 12: return 'Pengaturan Operasional';
      default: return 'Portal Owner';
    }
  }

  // ===========================================================================
  // 3. TAMPILAN DASHBOARD UTAMA (SEDERHANA, CLEAN, ELEGAN)
  // ===========================================================================
  Widget _buildDashboardView() {
    final num totalCash = _staffList.fold(0, (acc, s) => acc + (s['cash'] as num));
    final num totalQris = _staffList.fold(0, (acc, s) => acc + (s['qris'] as num));
    final num totalOmzet = totalCash + totalQris;
    final num totalCups = _staffList.fold(0, (acc, s) => acc + (s['cups_sold'] as num));
    final num totalCommission = _staffList.fold(0, (acc, s) => acc + (s['total_commission'] as num));
    final num netProfit = (totalOmzet * 0.58).round();
    final activeStaff = _staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4 KPI Stat Tiles (Sederhana, Minimalis, Tipografi Jelas)
        Row(
          children: [
            Expanded(child: _cleanStatTile('Total Penjualan', _formatRupiah(totalOmzet), 'QRIS ${_formatRupiah(totalQris)} • Tunai ${_formatRupiah(totalCash)}')),
            const SizedBox(width: 14),
            Expanded(child: _cleanStatTile('Kopi Terjual', '$totalCups Cup', 'Rata-rata 105 cup/gerobak')),
            const SizedBox(width: 14),
            Expanded(child: _cleanStatTile('Petugas Berjualan', '$activeStaff dari ${_staffList.length} Gerobak', '1 Gerobak Belum Mulai')),
            const SizedBox(width: 14),
            Expanded(child: _cleanStatTile('Laba Bersih Riil', _formatRupiah(netProfit), 'Komisi Tim: ${_formatRupiah(totalCommission)}')),
          ],
        ),
        const SizedBox(height: 20),

        // Inline Warning Chip (Hanya muncul jika stok tipis, tidak heboh)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFFDE68A))),
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Stok Menipis: Hendra Wijaya (GRB-04 • Stasiun Juanda) tersisa 15 Cup.', style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w500)),
              ),
              InkWell(
                onTap: _showDistributeStockDialog,
                child: const Text('Beri Tambahan Stok ➔', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // TABEL TUNGGAL KONTROL PETUGAS LAPANGAN (Semua data penting dalam 1 pandangan)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status Operasional Seluruh Gerobak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), side: const BorderSide(color: Color(0xFFCBD5E1))),
                          onPressed: _showDistributeStockDialog,
                          child: const Text('Bagi Stok Pagi', style: TextStyle(fontSize: 11.5, color: Color(0xFF334155))),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6)),
                          onPressed: _showAddStaffDialog,
                          child: const Text('+ Tambah Petugas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.2),
                  4: FlexColumnWidth(1.2),
                  5: FlexColumnWidth(1.5),
                  6: FlexColumnWidth(1.5),
                  7: FlexColumnWidth(1.2),
                  8: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                    children: [
                      _cleanTh('Petugas & Unit'),
                      _cleanTh('Lokasi Lapak'),
                      _cleanTh('Mulai Shift'),
                      _cleanTh('Bawaan'),
                      _cleanTh('Sisa Box'),
                      _cleanTh('Kas Tunai'),
                      _cleanTh('QRIS Masuk'),
                      _cleanTh('Status'),
                      _cleanTh('Aksi'),
                    ],
                  ),
                  for (final s in _staffList)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                      children: [
                        _cleanTd('${s['name']}\n${s['cart_id']}', bold: true),
                        _cleanTd(s['location']),
                        _cleanTd(s['clock_in']),
                        _cleanTd('${s['morning_stock']} Cup'),
                        _cleanTd('${s['current_stock']} Cup', color: (s['current_stock'] as int) < 20 ? Colors.red : null, bold: (s['current_stock'] as int) < 20),
                        _cleanTd(_formatRupiah(s['cash'] as num)),
                        _cleanTd(_formatRupiah(s['qris'] as num)),
                        _cleanStatusPill(s['operational_status'] == 'ACTIVE_SELLING' ? 'Jualan' : 'Belum Mulai', s['operational_status'] == 'ACTIVE_SELLING'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    final isSelling = s['operational_status'] == 'ACTIVE_SELLING';
                                    s['operational_status'] = isSelling ? 'OFFLINE' : 'ACTIVE_SELLING';
                                  });
                                },
                                child: Text(
                                  s['operational_status'] == 'ACTIVE_SELLING' ? 'Tutup' : 'Buka',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: s['operational_status'] == 'ACTIVE_SELLING' ? Colors.red : Colors.green),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    _liveMapLat = (s['lat'] as num).toDouble();
                                    _liveMapLng = (s['lng'] as num).toDouble();
                                    _liveMapZoom = 17;
                                    _focusedStaffId = s['id'] as String;
                                    _selectedNavIndex = 3; // Switch to Peta Live
                                  });
                                },
                                child: const Icon(Icons.place_outlined, size: 15, color: Color(0xFF2563EB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: TIM LAPANGAN
  // ===========================================================================
  Widget _buildStaffManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 280,
              child: TextField(
                decoration: const InputDecoration(hintText: 'Cari nama atau gerobak...', prefixIcon: Icon(Icons.search, size: 18), border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                onChanged: (val) => setState(() => _searchFilter = val),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: _showAddStaffDialog,
              child: const Text('+ Tambah Akun Petugas'),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.6),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.2),
              6: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('ID'),
                  _cleanTh('Nama Petugas'),
                  _cleanTh('WhatsApp'),
                  _cleanTh('Gerobak & Lapak'),
                  _cleanTh('GPS'),
                  _cleanTh('Status'),
                  _cleanTh('Aksi'),
                ],
              ),
              for (final s in _staffList.where((x) => x['name'].toString().toLowerCase().contains(_searchFilter.toLowerCase())))
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(s['id']),
                    _cleanTd('${s['name']}\n@${s['username']}', bold: true),
                    _cleanTd(s['phone']),
                    _cleanTd('${s['cart_id']}\n${s['location']}'),
                    _cleanTd(s['gps_status']),
                    _cleanStatusPill(s['account_status'] == 'ACTIVE' ? 'Aktif' : 'Nonaktif', s['account_status'] == 'ACTIVE'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                final isAct = s['account_status'] == 'ACTIVE';
                                s['account_status'] = isAct ? 'INACTIVE' : 'ACTIVE';
                              });
                            },
                            child: Text(s['account_status'] == 'ACTIVE' ? 'Nonaktifkan' : 'Aktifkan', style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: ABSENSI
  // ===========================================================================
  Widget _buildAttendanceView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rekap Kehadiran Petugas Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(1.2),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('Petugas'),
                  _cleanTh('Unit Gerobak'),
                  _cleanTh('Jam Masuk'),
                  _cleanTh('Status Shift'),
                  _cleanTh('Koordinat Absen'),
                ],
              ),
              for (final s in _staffList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(s['name'], bold: true),
                    _cleanTd(s['cart_id']),
                    _cleanTd(s['clock_in']),
                    _cleanStatusPill(s['operational_status'] == 'ACTIVE_SELLING' ? 'Sedang Shift' : 'Belum Mulai', s['operational_status'] == 'ACTIVE_SELLING'),
                    _cleanTd(s['lat_long']),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: PETA LIVE (INTERACTIVE GOOGLE MAPS)
  // ===========================================================================
  Widget _buildGoogleMapsMonitoringView() {
    final focusedStaff = _staffList.firstWhere(
      (s) => s['id'] == _focusedStaffId,
      orElse: () => _staffList.first,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Toolbar & Controls
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'LIVE TELEMETRI GPS',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green, letterSpacing: 0.5),
              ),
              const SizedBox(width: 16),
              Text(
                'Koordinat Aktif: ${_liveMapLat.toStringAsFixed(4)}, ${_liveMapLng.toStringAsFixed(4)} (Zoom ${_liveMapZoom}x)',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              // Zoom Controls
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                icon: const Icon(Icons.zoom_in, size: 16),
                label: const Text('Zoom +', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    if (_liveMapZoom < 19) _liveMapZoom++;
                  });
                },
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  foregroundColor: const Color(0xFF0F172A),
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                ),
                icon: const Icon(Icons.zoom_out, size: 16),
                label: const Text('Zoom -', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    if (_liveMapZoom > 10) _liveMapZoom--;
                  });
                },
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.my_location, size: 14),
                label: const Text('Reset Peta (Jakarta Pusat)', style: TextStyle(fontSize: 11)),
                onPressed: () {
                  setState(() {
                    _liveMapLat = -6.1950;
                    _liveMapLng = 106.8300;
                    _liveMapZoom = 14;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Two Column Layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left: Real Interactive Google Maps
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 520,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        // The actual real Google Map widget
                        RealLiveGoogleMap(
                          latitude: _liveMapLat,
                          longitude: _liveMapLng,
                          zoom: _liveMapZoom,
                        ),
                        // Top info badge overlay
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A).withOpacity(0.92),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.place, size: 14, color: Colors.amberAccent),
                                const SizedBox(width: 6),
                                Text(
                                  'Fokus: ${focusedStaff['name']} (${focusedStaff['cart_id']})',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '• ${focusedStaff['location']}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Location intelligence recommendation banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline, size: 18, color: Color(0xFF475569)),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Saran Lokasi AI: Jam padat komuter Stasiun Juanda diprediksi jam 16:30 - 18:30 WIB. Disarankan siapkan penambahan 40 cup untuk Gerobak 04.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF334155), height: 1.3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            side: const BorderSide(color: Color(0xFF94A3B8)),
                            foregroundColor: const Color(0xFF0F172A),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Notifikasi pengarahan lokasi telah dikirimkan ke petugas lapangan.')),
                            );
                          },
                          child: const Text('Kirim Pengarahan', style: TextStyle(fontSize: 11)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Right: Staff List & Focused Staff Telemetry
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Armada Gerobak Terpantau',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A)),
                            ),
                            Text(
                              '${_staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length} Aktif Jualan',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Staff List
                        for (final s in _staffList) ...[
                          _buildMapStaffTile(s),
                          const SizedBox(height: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Detail Telemetri Petugas Terpilih
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.gps_fixed, size: 14, color: Color(0xFF0F172A)),
                            const SizedBox(width: 6),
                            Text(
                              'Telemetri: ${focusedStaff['name']}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (focusedStaff['operational_status'] == 'ACTIVE_SELLING') ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                focusedStaff['operational_status'] as String,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: (focusedStaff['operational_status'] == 'ACTIVE_SELLING') ? const Color(0xFF166534) : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _buildMiniTelemetryCard('Sisa Stok', '${focusedStaff['current_stock']} Cup', (focusedStaff['current_stock'] as int) < 20 ? Colors.red : const Color(0xFF0F172A)),
                            const SizedBox(width: 8),
                            _buildMiniTelemetryCard('Penjualan', '${focusedStaff['cups_sold']} Cup', const Color(0xFF0F172A)),
                            const SizedBox(width: 8),
                            _buildMiniTelemetryCard('Akurasi GPS', (focusedStaff['gps_status'] as String).split(' ').length > 1 ? (focusedStaff['gps_status'] as String).split(' ')[1] : '3m', const Color(0xFF0F172A)),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  foregroundColor: const Color(0xFF0F172A),
                                  side: const BorderSide(color: Color(0xFF94A3B8)),
                                ),
                                icon: const Icon(Icons.share_location, size: 14),
                                label: const Text('Tugaskan Lokasi Baru', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showRelocateStaffDialog(focusedStaff),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F172A),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                ),
                                icon: const Icon(Icons.add_shopping_cart, size: 14),
                                label: const Text('Kirim Stok Tambahan', style: TextStyle(fontSize: 11)),
                                onPressed: () => _showAddStockToStaffDialog(focusedStaff),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMapStaffTile(Map<String, dynamic> s) {
    final isSelected = s['id'] == _focusedStaffId;
    final isSelling = s['operational_status'] == 'ACTIVE_SELLING';
    final isLowStock = isSelling && (s['current_stock'] as int) < 20;

    return InkWell(
      onTap: () {
        setState(() {
          _liveMapLat = (s['lat'] as num).toDouble();
          _liveMapLng = (s['lng'] as num).toDouble();
          _liveMapZoom = 17;
          _focusedStaffId = s['id'] as String;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelling ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.storefront_outlined,
                  size: 16,
                  color: isSelling ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        s['name'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        s['cart_id'] as String,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    s['location'] as String,
                    style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Stok: ${s['current_stock']} Cup',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                          color: isLowStock ? Colors.red : const Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• Terjual: ${s['cups_sold']} Cup',
                        style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelling ? const Color(0xFFDCFCE7) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isSelling ? 'LIVE' : 'OFFLINE',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isSelling ? const Color(0xFF166534) : const Color(0xFF64748B),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Pusatkan',
                  style: TextStyle(fontSize: 10, color: Color(0xFF2563EB), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTelemetryCard(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
            const SizedBox(height: 2),
            Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: valueColor)),
          ],
        ),
      ),
    );
  }

  void _showRelocateStaffDialog(Map<String, dynamic> staff) {
    String selectedLocName = _locations.first['name'];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Text('Tugaskan Lokasi Baru: ${staff['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unit Gerobak: ${staff['cart_id']}'),
                const SizedBox(height: 4),
                Text('Lokasi Saat Ini: ${staff['location']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                const SizedBox(height: 16),
                const Text('Pilih Titik Lapak Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: selectedLocName,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _locations.map((loc) {
                    return DropdownMenuItem<String>(
                      value: loc['name'] as String,
                      child: Text('${loc['name']} (${loc['traffic']})', style: const TextStyle(fontSize: 12)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDlgState(() => selectedLocName = val);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: () {
                final targetLoc = _locations.firstWhere((loc) => loc['name'] == selectedLocName);
                setState(() {
                  staff['location'] = selectedLocName;
                  staff['lat'] = targetLoc['lat'];
                  staff['lng'] = targetLoc['lng'];
                  staff['lat_long'] = '${targetLoc['lat']}, ${targetLoc['lng']}';
                  _liveMapLat = (targetLoc['lat'] as num).toDouble();
                  _liveMapLng = (targetLoc['lng'] as num).toDouble();
                  _liveMapZoom = 17;
                  _focusedStaffId = staff['id'] as String;
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Penugasan ${staff['cart_id']} ke $selectedLocName berhasil dikirimkan!')),
                );
              },
              child: const Text('Konfirmasi Relokasi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddStockToStaffDialog(Map<String, dynamic> staff) {
    final qtyCtrl = TextEditingController(text: '30');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text('Kirim Stok Tambahan: ${staff['cart_id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Petugas: ${staff['name']}'),
              const SizedBox(height: 4),
              Text('Sisa Stok Saat Ini: ${staff['current_stock']} Cup', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 16),
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah Cup Tambahan (Gudang Pusat)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              final addQty = int.tryParse(qtyCtrl.text) ?? 0;
              if (addQty <= 0) return;
              setState(() {
                staff['current_stock'] = (staff['current_stock'] as int) + addQty;
                staff['morning_stock'] = (staff['morning_stock'] as int) + addQty;
                _warehouseStock[0]['central_stock'] = (_warehouseStock[0]['central_stock'] as int) - addQty;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Berhasil mengirim $addQty Cup tambahan ke ${staff['name']}')),
              );
            },
            child: const Text('Kirim Stok'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SUB-PAGES: LAPAK JUALAN
  // ===========================================================================
  Widget _buildLocationManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daftar Titik Lapak & Estimasi Kepadatan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.2),
              6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('ID'),
                  _cleanTh('Nama Lokasi Lapak'),
                  _cleanTh('Petugas Bertugas'),
                  _cleanTh('Kondisi Lalu Lintas'),
                  _cleanTh('Pejalan Kaki'),
                  _cleanTh('Status'),
                  _cleanTh('Aksi'),
                ],
              ),
              for (final loc in _locations)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(loc['id']),
                    _cleanTd(loc['name'], bold: true),
                    _cleanTd(loc['seller']),
                    _cleanTd(loc['traffic']),
                    _cleanTd(loc['footfall']),
                    _cleanStatusPill(loc['status'] == 'Terisi' ? 'Terisi' : 'Kosong', loc['status'] == 'Terisi'),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _liveMapLat = (loc['lat'] as num).toDouble();
                            _liveMapLng = (loc['lng'] as num).toDouble();
                            _liveMapZoom = 17;
                            _selectedNavIndex = 3; // Switch to Peta Live
                          });
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.place_outlined, size: 14, color: Color(0xFF2563EB)),
                            SizedBox(width: 4),
                            Text('Peta', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: GUDANG & STOK
  // ===========================================================================
  Widget _buildWarehouseManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Katalog Persediaan Gudang Pusat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Row(
              children: [
                OutlinedButton(
                  onPressed: _showAddStockDialog,
                  child: const Text('+ Input Stok Masuk'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                  onPressed: _showDistributeStockDialog,
                  child: const Text('Bagi ke Gerobak'),
                ),
              ],
            )
          ],
        ),
        const SizedBox(height: 14),

        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.4),
              6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('SKU'),
                  _cleanTh('Menu Kopi / Bahan'),
                  _cleanTh('Kategori'),
                  _cleanTh('Stok Pusat'),
                  _cleanTh('Harga Modal'),
                  _cleanTh('Harga Jual'),
                  _cleanTh('Status'),
                ],
              ),
              for (final w in _warehouseStock)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(w['sku']),
                    _cleanTd(w['name'], bold: true),
                    _cleanTd(w['category']),
                    _cleanTd('${w['central_stock']} Porsi', bold: true),
                    _cleanTd(_formatRupiah(w['cost'] as num)),
                    _cleanTd(_formatRupiah(w['price'] as num)),
                    _cleanStatusPill(w['status'] == 'Aman' ? 'Aman' : 'Menipis', w['status'] == 'Aman'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: DISTRIBUSI PAGI
  // ===========================================================================
  Widget _buildStockDistributionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Rekap Bawaan Pagi & Pengurangan Penjualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
              onPressed: _showDistributeStockDialog,
              child: const Text('Bagi Stok Pagi'),
            ),
          ],
        ),
        const SizedBox(height: 14),

        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('Petugas Lapangan'),
                  _cleanTh('Lokasi Gerobak'),
                  _cleanTh('Stok Awal Pagi'),
                  _cleanTh('Terjual Siang'),
                  _cleanTh('Sisa Box'),
                ],
              ),
              for (final s in _staffList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(s['name'], bold: true),
                    _cleanTd(s['cart_id']),
                    _cleanTd('${s['morning_stock']} Cup'),
                    _cleanTd('${s['cups_sold']} Cup', color: const Color(0xFF10B981), bold: true),
                    _cleanTd('${s['current_stock']} Cup', color: (s['current_stock'] as int) < 20 ? Colors.red : null, bold: (s['current_stock'] as int) < 20),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: PENJUALAN
  // ===========================================================================
  Widget _buildSalesMonitoringView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Daftar Transaksi Kasir Masuk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2.5),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.2),
              6: FlexColumnWidth(1.6),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('ID Trx'),
                  _cleanTh('Jam'),
                  _cleanTh('Petugas'),
                  _cleanTh('Item Pesanan'),
                  _cleanTh('Total'),
                  _cleanTh('Metode'),
                  _cleanTh('Penyelesaian'),
                ],
              ),
              for (final tx in _recentTransactions)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(tx['id']),
                    _cleanTd(tx['time']),
                    _cleanTd(tx['seller'], bold: true),
                    _cleanTd(tx['items']),
                    _cleanTd(_formatRupiah(tx['total'] as num), bold: true),
                    _cleanTd(tx['method']),
                    _cleanTd(tx['pjp']),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: PESANAN QRIS
  // ===========================================================================
  Widget _buildOrdersMonitoringView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monitoring Pesanan Pre-Order Pelanggan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(1),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.8),
              4: FlexColumnWidth(2.2),
              5: FlexColumnWidth(1.4),
              6: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('No. Order'),
                  _cleanTh('Jam'),
                  _cleanTh('Pelanggan'),
                  _cleanTh('Seller'),
                  _cleanTh('Item'),
                  _cleanTh('Total'),
                  _cleanTh('Status'),
                ],
              ),
              for (final o in _customerOrders)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(o['id']),
                    _cleanTd(o['time']),
                    _cleanTd(o['customer'], bold: true),
                    _cleanTd(o['seller']),
                    _cleanTd(o['items']),
                    _cleanTd(_formatRupiah(o['total'] as num), bold: true),
                    _cleanStatusPill(o['status'], o['status'] == 'Selesai' || o['status'] == 'Diproses'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: KOMISI TIM
  // ===========================================================================
  Widget _buildCommissionSystemView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Rekap Hak Komisi Petugas (Rp 2.000 / cup)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.6),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('Nama Petugas'),
                  _cleanTh('Unit Gerobak'),
                  _cleanTh('Cup Terjual'),
                  _cleanTh('Hak Komisi'),
                  _cleanTh('Status'),
                  _cleanTh('Aksi'),
                ],
              ),
              for (final s in _staffList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(s['name'], bold: true),
                    _cleanTd(s['cart_id']),
                    _cleanTd('${s['cups_sold']} Cup'),
                    _cleanTd(_formatRupiah(s['total_commission'] as num), bold: true, color: const Color(0xFF0F172A)),
                    _cleanStatusPill(s['commission_paid'] ? 'Sudah Cair' : 'Siap Cair', s['commission_paid']),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: InkWell(
                        onTap: s['commission_paid'] ? null : () {
                          setState(() => s['commission_paid'] = true);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Komisi ${s['name']} dicairkan.')));
                        },
                        child: Text(s['commission_paid'] ? 'Selesai' : 'Cairkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: s['commission_paid'] ? const Color(0xFF94A3B8) : const Color(0xFF0284C7))),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: ANALISIS LOKASI
  // ===========================================================================
  Widget _buildTrafficRadarView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Penilaian Potensi Lapak Berdasarkan Trafik Nyata', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 12),
        _tableContainer(
          Table(
            columnWidths: const {
              0: FlexColumnWidth(2.5),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(1.6),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(color: Color(0xFFFAFAFA), border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
                children: [
                  _cleanTh('Nama Lapak'),
                  _cleanTh('Kondisi Lalu Lintas'),
                  _cleanTh('Pejalan Kaki'),
                  _cleanTh('Skor Potensi'),
                  _cleanTh('Status'),
                ],
              ),
              for (final l in _locations)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))),
                  children: [
                    _cleanTd(l['name'], bold: true),
                    _cleanTd(l['traffic']),
                    _cleanTd(l['footfall']),
                    _cleanTd('${l['score']} / 100', bold: true),
                    _cleanStatusPill(l['status'] == 'Terisi' ? 'Terisi' : 'Tersedia', l['status'] == 'Terisi'),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: LAPORAN
  // ===========================================================================
  Widget _buildAnalyticsReportsView() {
    final num totalCash = _staffList.fold(0, (acc, s) => acc + (s['cash'] as num));
    final num totalQris = _staffList.fold(0, (acc, s) => acc + (s['qris'] as num));
    final num totalOmzet = totalCash + totalQris;
    final num totalHpp = (totalOmzet * 0.38).round();
    final num totalCommission = _staffList.fold(0, (acc, s) => acc + (s['total_commission'] as num));
    final num netProfit = totalOmzet - totalHpp - totalCommission;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Laporan Laba Rugi Operasional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan CSV diunduh.')));
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Ekspor CSV', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(child: _cleanStatTile('Omzet Bruto', _formatRupiah(totalOmzet), 'Total Pendapatan')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Harga Pokok (HPP)', _formatRupiah(totalHpp), 'Biaya Bahan Kopi')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Komisi Petugas', _formatRupiah(totalCommission), 'Hak Insentif')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Laba Bersih', _formatRupiah(netProfit), 'Keuntungan Riil')),
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB-PAGES: PENGATURAN
  // ===========================================================================
  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pengaturan Usaha Kopi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 14),
        Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(decoration: const InputDecoration(labelText: 'Nama Usaha', border: OutlineInputBorder()), controller: TextEditingController(text: 'KopiCerdas Jaringan Gerobak')),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Jam Buka Shift Pagi', border: OutlineInputBorder()), controller: TextEditingController(text: '05:30 WIB')),
              const SizedBox(height: 12),
              TextField(decoration: const InputDecoration(labelText: 'Rate Komisi Standar per Cup', border: OutlineInputBorder()), controller: TextEditingController(text: 'Rp 2.000')),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pengaturan disimpan.')));
                },
                child: const Text('Simpan Pengaturan'),
              )
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB WIDGET & HELPERS
  // ===========================================================================
  Widget _cleanStatTile(String label, String value, String subtext) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.5)),
          const SizedBox(height: 3),
          Text(subtext, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _tableContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: child,
    );
  }

  Widget _cleanTh(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
    );
  }

  Widget _cleanTd(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, fontWeight: bold ? FontWeight.w600 : FontWeight.normal, color: color ?? const Color(0xFF1E293B)),
      ),
    );
  }

  Widget _cleanStatusPill(String label, bool isPositive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isPositive ? const Color(0xFFECFDF5) : const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isPositive ? const Color(0xFF047857) : const Color(0xFF64748B)),
          ),
        ),
      ),
    );
  }

  String _formatRupiah(num val) {
    final str = val.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) buffer.write('.');
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }
}
