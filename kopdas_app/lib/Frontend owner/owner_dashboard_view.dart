import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'real_web_map.dart';
import 'web_download_helper.dart';

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

  // Warehouse filter
  String _warehouseCategoryFilter = 'Semua';

  // Sidebar Collapse State (3S.NET style)
  bool _isSidebarCollapsed = false;

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
      'cash_submitted': 900000,
      'cash_status': 'BALANCE',
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
      'cash_submitted': 520000,
      'cash_status': 'BALANCE',
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
      'cash_submitted': 640000,
      'cash_status': 'BALANCE',
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
      'cash_submitted': 780000,
      'cash_status': 'BALANCE',
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
      'cash_submitted': 0,
      'cash_status': 'STANDBY',
      'gps_status': 'Offline',
      'lat_long': '-6.2185, 106.8302',
      'lat': -6.2185,
      'lng': 106.8302,
      'map_x': 240.0,
      'map_y': 230.0,
    },
  ];

  final List<Map<String, dynamic>> _warehouseStock = [
    {'sku': 'KPS-01', 'name': 'Kopi Susu Soft', 'category': 'Kopi Susu', 'central_stock': 850, 'allocated': 160, 'held_by_cart': 110, 'min_stock': 150, 'price': 18000, 'cost': 7500, 'status': 'Aman'},
    {'sku': 'KPS-02', 'name': 'Kopi Susu Strong', 'category': 'Kopi Susu', 'central_stock': 750, 'allocated': 140, 'held_by_cart': 95, 'min_stock': 150, 'price': 18000, 'cost': 7500, 'status': 'Aman'},
    {'sku': 'KPS-03', 'name': 'Kopi Susu Butter', 'category': 'Kopi Susu', 'central_stock': 620, 'allocated': 120, 'held_by_cart': 80, 'min_stock': 120, 'price': 20000, 'cost': 8000, 'status': 'Aman'},
    {'sku': 'COF-01', 'name': 'Americano', 'category': 'Classic Coffee', 'central_stock': 540, 'allocated': 90, 'held_by_cart': 65, 'min_stock': 100, 'price': 15000, 'cost': 4500, 'status': 'Aman'},
    {'sku': 'NCF-01', 'name': 'Coklat', 'category': 'Non-Coffee', 'central_stock': 480, 'allocated': 80, 'held_by_cart': 50, 'min_stock': 100, 'price': 18000, 'cost': 7000, 'status': 'Aman'},
    {'sku': 'NCF-02', 'name': 'Matcha', 'category': 'Non-Coffee', 'central_stock': 410, 'allocated': 70, 'held_by_cart': 45, 'min_stock': 100, 'price': 20000, 'cost': 8500, 'status': 'Aman'},
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
                  'cash_submitted': 0,
                  'cash_status': 'NOT_STARTED',
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
  // INTERACTIVE MODALS (REAL-TIME LOCATION, CASH SETTLEMENT, TAX REPORT)
  // ===========================================================================

  // MODAL 1: Real-time Live Map & Telemetry Popup (Requirement 5)
  void _showSellerRealtimeLocationDialog(Map<String, dynamic> s) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 640,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3932).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.location_on, color: Color(0xFF1E3932), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lokasi Realtime & Telemetri Armada',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827)),
                          ),
                          Text(
                            '${s['name']} — Unit ${s['cart_id']}',
                            style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close, size: 20, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 16),

              // Live GPS Map Frame
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  height: 240,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                  ),
                  child: RealLiveGoogleMap(
                    latitude: (s['lat'] as num).toDouble(),
                    longitude: (s['lng'] as num).toDouble(),
                    zoom: 16,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Telemetry Grid
              Row(
                children: [
                  Expanded(
                    child: _modalTelemetryTile(
                      'Titik Lapak Jualan',
                      s['location'] as String,
                      Icons.storefront_outlined,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _modalTelemetryTile(
                      'Koordinat Live GPS',
                      '${s['lat_long']} (${s['gps_status']})',
                      Icons.gps_fixed,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _modalTelemetryTile(
                      'Stok Cup Gerobak',
                      'Sisa: ${s['current_stock']} cup • Bawa: ${s['morning_stock']} cup',
                      Icons.coffee,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _modalTelemetryTile(
                      'Penjualan & Kas Saat Ini',
                      'Terjual: ${s['cups_sold']} cup • Kas: ${_formatRupiah(s['cash'] as num)}',
                      Icons.point_of_sale,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD1D5DB)),
                      foregroundColor: const Color(0xFF374151),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ping sensor telemetri dikirim ke unit ${s['cart_id']}. Sinyal GPS 100% responsif.')),
                      );
                    },
                    icon: const Icon(Icons.cell_tower, size: 16),
                    label: const Text('Ping Sensor IoT'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3932),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Tutup'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MODAL 2: Cash Settlement & Shift Audit Modal (Requirement 7)
  void _showCashSettlementDialog(Map<String, dynamic> s) {
    final cashExpected = s['cash'] as num;
    final physicalCtrl = TextEditingController(text: '${s['cash_submitted'] ?? s['cash']}');
    final int returnedCups = (s['current_stock'] as num).toInt();
    final int morningStock = (s['morning_stock'] as num).toInt();
    final int soldCups = (s['cups_sold'] as num).toInt();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final parsedCash = num.tryParse(physicalCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
          final variance = parsedCash - cashExpected;
          final isBalance = variance == 0;
          final isShort = variance < 0;

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3932).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.account_balance_wallet, color: Color(0xFF1E3932), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Rekonsiliasi Tutup Shift: ${s['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('Unit ${s['cart_id']} — Verifikasi Fisik Sisa Kopi & Uang Tunai', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Stok Bawaan Pagi:', style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563))),
                            Text('$morningStock Cup', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Sisa Fisik Kembali:', style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563))),
                            Text('$returnedCups Cup', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Cup Terjual (Fisik):', style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563))),
                            Text('$soldCups Cup', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          ],
                        ),
                        const Divider(height: 16, color: Color(0xFFE5E7EB)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Omzet QRIS Otomatis (Non-Tunai):', style: TextStyle(fontSize: 12.5, color: Color(0xFF4B5563))),
                            Text(_formatRupiah(s['qris'] as num), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Uang Kas Seharusnya Masuk (Expected):', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                            Text(_formatRupiah(cashExpected), style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Uang Kas Fisik Diserahkan Seller (Rp):', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: physicalCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    onChanged: (val) => setModalState(() {}),
                  ),
                  const SizedBox(height: 14),

                  // Variance status container
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isBalance
                          ? const Color(0xFFECFDF5)
                          : (isShort ? const Color(0xFFFEF2F2) : const Color(0xFFFFFBEB)),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isBalance
                            ? const Color(0xFFA7F3D0)
                            : (isShort ? const Color(0xFFFECACA) : const Color(0xFFFDE68A)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isBalance ? Icons.check_circle : Icons.warning_amber_rounded,
                          color: isBalance
                              ? const Color(0xFF059669)
                              : (isShort ? const Color(0xFFDC2626) : const Color(0xFFD97706)),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBalance
                                    ? 'STATUS AUDIT: BALANCE (Sesuai 100%)'
                                    : (isShort
                                        ? 'STATUS AUDIT: SELISIH KURANG ${_formatRupiah(variance.abs())}'
                                        : 'STATUS AUDIT: SELISIH LEBIH ${_formatRupiah(variance)}'),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: isBalance
                                      ? const Color(0xFF065F46)
                                      : (isShort ? const Color(0xFF991B1B) : const Color(0xFF92400E)),
                                ),
                              ),
                              Text(
                                isBalance
                                    ? 'Uang fisik yang diserahkan klop dengan seluruh pesanan tunai di pos kasir.'
                                    : (isShort
                                        ? 'Uang fisik lebih sedikit dari kalkulasi penjualan kasir lapangan.'
                                        : 'Uang fisik berlebih dari total nota kasir.'),
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isBalance
                                      ? const Color(0xFF047857)
                                      : (isShort ? const Color(0xFFB91C1C) : const Color(0xFFB45309)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              OutlinedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3932),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    s['cash_status'] = isBalance ? 'BALANCE' : (isShort ? 'DEFICIT' : 'SURPLUS');
                    s['cash_submitted'] = parsedCash;
                    s['operational_status'] = 'CLOSED_SHIFT';
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tutup shift unit ${s['cart_id']} diverifikasi. Status: ${isBalance ? "BALANCE" : "SELISIH ${_formatRupiah(variance)}"}.',
                      ),
                    ),
                  );
                },
                child: const Text('Setujui & Tutup Shift'),
              ),
            ],
          );
        },
      ),
    );
  }

  // MODAL 3: Tax Report Official CSV Export Dialog (Requirement 8)
  void _showTaxReportExportDialog() {
    final List<Map<String, dynamic>> records = [
      {'no': 'INV-20261114-001', 'tgl': '14/11/2026', 'sumber': 'GRB-01 (Sudirman)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 900000, 'qris': 0, 'dpp': 900000, 'pph': 4500, 'kjs': '411128-420'},
      {'no': 'INV-20261114-002', 'tgl': '14/11/2026', 'sumber': 'GRB-01 (Sudirman)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1940000, 'dpp': 1940000, 'pph': 9700, 'kjs': '411128-420'},
      {'no': 'INV-20261114-003', 'tgl': '14/11/2026', 'sumber': 'GRB-02 (Suropati)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 520000, 'qris': 0, 'dpp': 520000, 'pph': 2600, 'kjs': '411128-420'},
      {'no': 'INV-20261114-004', 'tgl': '14/11/2026', 'sumber': 'GRB-02 (Suropati)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 900000, 'dpp': 900000, 'pph': 4500, 'kjs': '411128-420'},
      {'no': 'INV-20261114-005', 'tgl': '14/11/2026', 'sumber': 'GRB-03 (Senen)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 640000, 'qris': 0, 'dpp': 640000, 'pph': 3200, 'kjs': '411128-420'},
      {'no': 'INV-20261114-006', 'tgl': '14/11/2026', 'sumber': 'GRB-03 (Senen)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1340000, 'dpp': 1340000, 'pph': 6700, 'kjs': '411128-420'},
      {'no': 'INV-20261114-007', 'tgl': '14/11/2026', 'sumber': 'GRB-04 (Juanda)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 780000, 'qris': 0, 'dpp': 780000, 'pph': 3900, 'kjs': '411128-420'},
      {'no': 'INV-20261114-008', 'tgl': '14/11/2026', 'sumber': 'GRB-04 (Juanda)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1580000, 'dpp': 1580000, 'pph': 7900, 'kjs': '411128-420'},
      {'no': 'INV-20261114-009', 'tgl': '14/11/2026', 'sumber': 'Discovery App Pre-Order', 'kanal': 'Online App', 'metode': 'QRIS Dinamis', 'cash': 0, 'qris': 3420000, 'dpp': 3420000, 'pph': 17100, 'kjs': '411128-420'},
    ];

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('No_Bukti,Tanggal,Sumber_Pendapatan,Kanal,Metode_Bayar,Penerimaan_Cash_IDR,Penerimaan_QRIS_IDR,Total_Omzet_DPP_IDR,Tarif_PPh,PPh_Final_Terutang_IDR,KAP_KJS,Keterangan');
    for (final r in records) {
      csvBuffer.writeln('${r['no']},${r['tgl']},"${r['sumber']}",${r['kanal']},${r['metode']},${r['cash']},${r['qris']},${r['dpp']},0.5%,${r['pph']},${r['kjs']},"Penjualan KopiCerdas Lapangan"');
    }
    csvBuffer.writeln('TOTAL,14/11/2026,"Konsolidasi Seluruh Kanal",Semua,Cash+QRIS,2840000,5850000,8690000,0.5%,43450,411128-420,"Total Omzet & PPh Final UMKM PP 55/2022"');
    final String csvData = csvBuffer.toString();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 960,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3932).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.table_view_rounded, color: Color(0xFF1E3932), size: 24),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Rekapitulasi Keuangan Cash vs QRIS & Pelaporan Pajak Resmi',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827)),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Format Standar SPT Masa / e-Bupot DJP Online • Tarif PPh Final UMKM 0.5% (PP 55/2022)',
                            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close, size: 20)),
                ],
              ),
              const SizedBox(height: 16),

              // 4 Stat Metric Cards (Cash, QRIS, DPP, PPh Final)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Penerimaan Cash (Tunai)', style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Rp 2.840.000', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF78350F))),
                          SizedBox(height: 2),
                          Text('32.7% Omzet • Kas Gerobak', style: TextStyle(fontSize: 10.5, color: Color(0xFFB45309))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Penerimaan QRIS (Non-Tunai)', style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Rp 5.850.000', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1E3A8A))),
                          SizedBox(height: 2),
                          Text('67.3% Omzet • Rekening Bank H+0', style: TextStyle(fontSize: 10.5, color: Color(0xFF2563EB))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Dasar Pengenaan Pajak (DPP)', style: TextStyle(fontSize: 11, color: Color(0xFF4B5563), fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Rp 8.690.000', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                          SizedBox(height: 2),
                          Text('Total Omzet Bruto Konsolidasi', style: TextStyle(fontSize: 10.5, color: Color(0xFF059669))),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('PPh Final UMKM (0.5%)', style: TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w600)),
                          SizedBox(height: 4),
                          Text('Rp 43.450', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF065F46))),
                          SizedBox(height: 2),
                          Text('PP 55/2022 (KAP 411128-420)', style: TextStyle(fontSize: 10.5, color: Color(0xFF047857))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Spreadsheet Preview Label
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Pratinjau Lembar Kerja Spreadsheet (Data Siap Ekspor):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1F2937))),
                  Text('9 Transaksi Konsolidasi • 1 Baris Total', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
                ],
              ),
              const SizedBox(height: 8),

              // Clean, Gorgeous Spreadsheet Data Table (Replacing the ugly dark terminal box!)
              Container(
                height: 240,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Scrollbar(
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowHeight: 36,
                        dataRowMinHeight: 32,
                        dataRowMaxHeight: 34,
                        horizontalMargin: 14,
                        columnSpacing: 18,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFFF8FAFC)),
                        border: const TableBorder(
                          horizontalInside: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                        ),
                        columns: const [
                          DataColumn(label: Text('No. Bukti', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                          DataColumn(label: Text('Tanggal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                          DataColumn(label: Text('Sumber & Unit Lapak', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                          DataColumn(label: Text('Metode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF475569)))),
                          DataColumn(numeric: true, label: Text('Cash (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF92400E)))),
                          DataColumn(numeric: true, label: Text('QRIS (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF1E40AF)))),
                          DataColumn(numeric: true, label: Text('DPP Omzet (Rp)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF111827)))),
                          DataColumn(numeric: true, label: Text('PPh Final 0.5%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF047857)))),
                          DataColumn(label: Text('KAP/KJS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF64748B)))),
                        ],
                        rows: [
                          for (final r in records)
                            DataRow(
                              cells: [
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
                                    child: Text(r['no'] as String, style: const TextStyle(fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.bold, color: Color(0xFF334155))),
                                  ),
                                ),
                                DataCell(Text(r['tgl'] as String, style: const TextStyle(fontSize: 11))),
                                DataCell(Text(r['sumber'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: (r['metode'] as String).contains('Tunai') ? const Color(0xFFFEF3C7) : const Color(0xFFDBEAFE),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      r['metode'] as String,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: (r['metode'] as String).contains('Tunai') ? const Color(0xFF92400E) : const Color(0xFF1E40AF),
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(Text(
                                  r['cash'] == 0 ? '-' : _formatRupiah(r['cash'] as num),
                                  style: TextStyle(fontSize: 11, fontWeight: r['cash'] > 0 ? FontWeight.w600 : FontWeight.normal, color: r['cash'] > 0 ? const Color(0xFF92400E) : const Color(0xFF94A3B8)),
                                )),
                                DataCell(Text(
                                  r['qris'] == 0 ? '-' : _formatRupiah(r['qris'] as num),
                                  style: TextStyle(fontSize: 11, fontWeight: r['qris'] > 0 ? FontWeight.w600 : FontWeight.normal, color: r['qris'] > 0 ? const Color(0xFF1E40AF) : const Color(0xFF94A3B8)),
                                )),
                                DataCell(Text(_formatRupiah(r['dpp'] as num), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827)))),
                                DataCell(Text(_formatRupiah(r['pph'] as num), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF047857)))),
                                DataCell(Text(r['kjs'] as String, style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)))),
                              ],
                            ),
                          // TOTAL ROW
                          DataRow(
                            color: WidgetStateProperty.all(const Color(0xFFECFDF5)),
                            cells: const [
                              DataCell(Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF065F46)))),
                              DataCell(Text('14/11/2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF065F46)))),
                              DataCell(Text('Konsolidasi Seluruh Kanal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF065F46)))),
                              DataCell(Text('Cash + QRIS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF065F46)))),
                              DataCell(Text('Rp 2.840.000', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF92400E)))),
                              DataCell(Text('Rp 5.850.000', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Color(0xFF1E40AF)))),
                              DataCell(Text('Rp 8.690.000', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF111827)))),
                              DataCell(Text('Rp 43.450', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11.5, color: Color(0xFF047857)))),
                              DataCell(Text('411128-420', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: Color(0xFF065F46)))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Modal Footer: Info note + Real Working Download Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.info_outline, size: 15, color: Color(0xFF059669)),
                      SizedBox(width: 6),
                      Text(
                        'Format CSV dilengkapi UTF-8 BOM — Dapat langsung dibuka di Microsoft Excel, Google Sheets, & Portal DJP.',
                        style: TextStyle(fontSize: 11, color: Color(0xFF065F46), fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          foregroundColor: const Color(0xFF374151),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: csvData));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              duration: Duration(seconds: 2),
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Teks CSV pelaporan pajak berhasil disalin ke clipboard!'),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 15),
                        label: const Text('Salin Teks CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3932), // 3S.NET Forest Green
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () {
                          // Real Browser File Download!
                          downloadWebFile(csvData, 'Laporan_Pajak_KopiCerdas_14Nov2026.csv');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              backgroundColor: Color(0xFF065F46),
                              duration: Duration(seconds: 3),
                              content: Row(
                                children: [
                                  Icon(Icons.download_done, color: Colors.white, size: 20),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'File "Laporan_Pajak_KopiCerdas_14Nov2026.csv" berhasil diunduh ke folder Downloads!',
                                      style: TextStyle(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.download, size: 16),
                        label: const Text('Unduh File .CSV (Excel)', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modalTelemetryTile(String title, String val, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF1E3932)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                const SizedBox(height: 2),
                Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ROOT BUILD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // 3S.NET crisp light background
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar 3S.NET Theme (Clean White, Forest Green Active Pill, Collapsible Toggle)
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
      case 9: return _buildAnalyticsReportsView(); // Komisi ditiadakan, dialihkan ke Laporan Keuangan
      case 10: return _buildTrafficRadarView();
      case 11: return _buildAnalyticsReportsView();
      case 12: return _buildSettingsView();
      default: return _buildDashboardView();
    }
  }

  // ===========================================================================
  // 1. SIDEBAR 3S.NET (CLEAN WHITE, #1E3932 FOREST GREEN PILL, COLLAPSIBLE TOGGLE)
  // ===========================================================================
  Widget _buildMinimalSidebar() {
    final double width = _isSidebarCollapsed ? 70.0 : 240.0;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 3S.NET Brand Logo
              Padding(
                padding: EdgeInsets.fromLTRB(_isSidebarCollapsed ? 14 : 20, 20, _isSidebarCollapsed ? 14 : 20, 18),
                child: _isSidebarCollapsed
                    ? Center(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3932),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.coffee, color: Colors.white, size: 20),
                        ),
                      )
                    : Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3932), // Forest Green Brand
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.coffee, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 10),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'KopiCerdas AI',
                                style: TextStyle(
                                  color: Color(0xFF111827),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'MANAGEMENT SYSTEM',
                                style: TextStyle(
                                  color: Color(0xFF6B7280),
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Categorized Navigation List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _sidebarCategoryHeader('OPERASIONAL UTAMA'),
                    _navItem(0, Icons.dashboard_outlined, 'Dashboard'),
                    _navItem(1, Icons.people_outline, 'Data Pelanggan & Tim'),
                    _navItem(3, Icons.map_outlined, 'Peta Live & GPS'),
                    _navItem(2, Icons.access_time, 'Absensi Shift'),

                    _sidebarCategoryHeader('LOGISTIK & KEUANGAN'),
                    _navItem(5, Icons.warehouse_outlined, 'Gudang & Stok'),
                    _navItem(6, Icons.local_shipping_outlined, 'Distribusi Bawaan Pagi'),
                    _navItem(7, Icons.point_of_sale_outlined, 'Manage Penghasilan Penjualan'),
                    _navItem(11, Icons.analytics_outlined, 'Laporan Keuangan & Pajak'),

                    _sidebarCategoryHeader('SISTEM & INTELIJEN'),
                    _navItem(10, Icons.psychology_outlined, 'Analisis AI Permintaan'),
                    _navItem(8, Icons.qr_code_scanner, 'Pesanan Online QRIS'),
                    _navItem(12, Icons.settings_outlined, 'Pengaturan Sistem'),
                  ],
                ),
              ),

              // User Profile Footer
              Container(
                padding: EdgeInsets.all(_isSidebarCollapsed ? 12 : 16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
                ),
                child: _isSidebarCollapsed
                    ? const Center(
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Color(0xFF1E3932),
                          child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      )
                    : Row(
                        children: [
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Color(0xFF1E3932),
                            child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Owner KopiCerdas', style: TextStyle(color: Color(0xFF111827), fontSize: 12, fontWeight: FontWeight.w700)),
                                Text('Administrator Bisnis', style: TextStyle(color: Color(0xFF6B7280), fontSize: 10)),
                              ],
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),

        // Circular Sidebar Toggle Button (< / >) matching 3S.NET screenshot!
        Positioned(
          right: -12,
          top: 360,
          child: InkWell(
            onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3932), // Dark Forest Green matching active pill
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _isSidebarCollapsed ? Icons.chevron_right : Icons.chevron_left,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sidebarCategoryHeader(String title) {
    if (_isSidebarCollapsed) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9CA3AF),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String title) {
    final isSelected = _selectedNavIndex == index;
    if (_isSidebarCollapsed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        child: Tooltip(
          message: title,
          child: InkWell(
            onTap: () => setState(() => _selectedNavIndex = index),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1E3932) : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3932) : Colors.transparent, // 3S.NET dark green pill
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              if (index == 7 || index == 11)
                Icon(
                  Icons.chevron_right,
                  size: 14,
                  color: isSelected ? Colors.white70 : const Color(0xFF9CA3AF),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // 2. HEADER 3S.NET (CLEAN TITLE, REAL-TIME STATUS, DATE FILTER, NO SEARCH BOX)
  // ===========================================================================
  Widget _buildSimpleTopHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: Row(
        children: [
          // Breadcrumb / Title area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _getNavTitle(),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                const Text(
                  'KopiCerdas AI — Smart Operational & Intelligence Management',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Status Badge: Real-time Live Synced (like 3S.NET)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.circle, size: 7, color: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'Real-time Live Synced',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Date Filter Toggle Pills [Hari Ini | Kemarin | 7 Hari | 30 Hari]
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: ['Hari Ini', 'Kemarin', '7 Hari', '30 Hari'].map((label) {
                final isSelected = _activeTimeFilter == label;
                return InkWell(
                  onTap: () {
                    setState(() => _activeTimeFilter = label);
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: const Duration(milliseconds: 800),
                        content: Text('Filter data diperbarui: $label'),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: isSelected
                          ? [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 3, offset: const Offset(0, 1))]
                          : null,
                    ),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF1E3932) : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 14),

          // Quick Action: Refresh Button (like 3S.NET)
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              foregroundColor: const Color(0xFF374151),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(duration: Duration(seconds: 1), content: Text('Sinkronisasi data real-time diperbarui.')),
              );
            },
            icon: const Icon(Icons.refresh, size: 15),
            label: const Text('Refresh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 8),

          // Notification Bell
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(duration: Duration(seconds: 1), content: Text('Notifikasi operasional real-time bersih.')),
                  );
                },
                icon: const Icon(Icons.notifications_none, size: 20, color: Color(0xFF6B7280)),
                tooltip: 'Notifikasi',
              ),
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),

          // User Profile Avatar
          Row(
            children: const [
              CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1E3932),
                child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Owner KopiCerdas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  Text('Administrator Bisnis', style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getNavTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Ringkasan Operasional & Intelijen Bisnis';
      case 1: return 'Data Pelanggan & Tim Lapangan';
      case 2: return 'Absensi & Jam Kerja Shift';
      case 3: return 'Peta Posisi Tim & GPS Realtime';
      case 4: return 'Daftar Titik Lapak Jualan';
      case 5: return 'Gudang Pusat & Manajemen Stok';
      case 6: return 'Distribusi Stok Bawaan Pagi';
      case 7: return 'Manage Penghasilan Penjualan & Verifikasi Kas';
      case 8: return 'Daftar Pesanan Online QRIS';
      case 9: return 'Laporan Keuangan & Pajak';
      case 10: return 'Analisis AI Permintaan & Optimasi Stok';
      case 11: return 'Laporan Keuangan & Pelaporan Pajak Resmi';
      case 12: return 'Pengaturan Sistem Operasional';
      default: return 'Portal Owner KopiCerdas';
    }
  }

  // ===========================================================================
  // 3. TAMPILAN DASHBOARD UTAMA (REAKTIF SESUAI FILTER WAKTU)
  // ===========================================================================
  Map<String, dynamic> _getDashboardDataForFilter() {
    switch (_activeTimeFilter) {
      case 'Kemarin':
        return {
          'period_label': 'Kemarin (13 Nov 2026)',
          'omzet': 6980000,
          'cash': 2330000,
          'qris': 4650000,
          'cups': 341,
          'online_cups': 130,
          'walkin_cups': 211,
          'net_profit': 4558000,
          'growth': '12.30%',
          'is_positive': true,
          'active_staff': 4,
          'total_staff': _staffList.length,
          'order_value_str': '9.8k',
          'orders_str': '11k',
          'users_str': '64.20%',
          'downloads_str': '29850',
          'chart_label': 'Sales Report Kemarin',
          'chart_bars': [
            {'yellow': 20.0, 'amber': 35.0, 'label': '07:00'},
            {'yellow': 26.0, 'amber': 18.0, 'label': '09:00'},
            {'yellow': 38.0, 'amber': 50.0, 'label': '12:00'},
            {'yellow': 15.0, 'amber': 25.0, 'label': '14:00'},
            {'yellow': 42.0, 'amber': 55.0, 'label': '17:00'},
            {'yellow': 22.0, 'amber': 30.0, 'label': '19:00'},
          ],
          'top_products': [
            {'name': 'Kopi Susu Gula Aren', 'sold': '172 cup (50%)', 'omzet': 3096000, 'stock': '950 cup'},
            {'name': 'Americano Double Shot', 'sold': '80 cup (23%)', 'omzet': 1200000, 'stock': '650 cup'},
            {'name': 'Matcha Uji Latte Creamy', 'sold': '48 cup (14%)', 'omzet': 1056000, 'stock': '430 cup'},
            {'name': 'Cafe Latte Steam Velvet', 'sold': '31 cup (9%)', 'omzet': 620000, 'stock': '520 cup'},
            {'name': 'Cold Brew Citrus Refresh', 'sold': '10 cup (3%)', 'omzet': 220000, 'stock': '310 cup'},
          ],
          'speed_label': '+12.3% vs hari sebelumnya',
          'speed_rows': [
            {'time': '06:00 – 08:30 (Pagi Komuter)', 'cups': '78 cup', 'is_peak': false},
            {'time': '08:30 – 11:30 (Jam Kantor)', 'cups': '62 cup', 'is_peak': false},
            {'time': '11:30 – 13:30 (Makan Siang)', 'cups': '118 cup', 'is_peak': true},
            {'time': '13:30 – 15:30 (Sore Berjalan)', 'cups': '83 cup', 'is_peak': false},
            {'time': '16:30 – 19:00 (Sore Komuter)', 'cups': '~120 cup', 'is_peak': false},
          ],
        };
      case '7 Hari':
        return {
          'period_label': '7 Hari Terakhir (8 - 14 Nov 2026)',
          'omzet': 54320000,
          'cash': 17920000,
          'qris': 36400000,
          'cups': 2650,
          'online_cups': 1050,
          'walkin_cups': 1600,
          'net_profit': 35470000,
          'growth': '18.70%',
          'is_positive': true,
          'active_staff': 5,
          'total_staff': _staffList.length,
          'order_value_str': '76.5k',
          'orders_str': '88k',
          'users_str': '82.40%',
          'downloads_str': '48200',
          'chart_label': 'Sales Report 7 Hari (Harian)',
          'chart_bars': [
            {'yellow': 32.0, 'amber': 48.0, 'label': 'Sen'},
            {'yellow': 35.0, 'amber': 52.0, 'label': 'Sel'},
            {'yellow': 38.0, 'amber': 55.0, 'label': 'Rab'},
            {'yellow': 40.0, 'amber': 58.0, 'label': 'Kam'},
            {'yellow': 48.0, 'amber': 68.0, 'label': 'Jum'},
            {'yellow': 55.0, 'amber': 75.0, 'label': 'Sab'},
          ],
          'top_products': [
            {'name': 'Kopi Susu Gula Aren', 'sold': '1.350 cup (51%)', 'omzet': 24300000, 'stock': '950 cup'},
            {'name': 'Americano Double Shot', 'sold': '615 cup (23%)', 'omzet': 9225000, 'stock': '650 cup'},
            {'name': 'Matcha Uji Latte Creamy', 'sold': '395 cup (15%)', 'omzet': 8690000, 'stock': '430 cup'},
            {'name': 'Cafe Latte Steam Velvet', 'sold': '215 cup (8%)', 'omzet': 4300000, 'stock': '520 cup'},
            {'name': 'Cold Brew Citrus Refresh', 'sold': '75 cup (3%)', 'omzet': 1650000, 'stock': '310 cup'},
          ],
          'speed_label': '+18.7% vs minggu lalu',
          'speed_rows': [
            {'time': 'Senin (Awal Pekan)', 'cups': '350 cup', 'is_peak': false},
            {'time': 'Selasa – Rabu (Stabil)', 'cups': '720 cup', 'is_peak': false},
            {'time': 'Kamis (Tinggi)', 'cups': '410 cup', 'is_peak': false},
            {'time': 'Jumat (Peak Komuter)', 'cups': '580 cup', 'is_peak': true},
            {'time': 'Sabtu – Minggu (Lounge CFD)', 'cups': '590 cup', 'is_peak': false},
          ],
        };
      case '30 Hari':
        return {
          'period_label': '30 Hari Terakhir (16 Okt - 14 Nov 2026)',
          'omzet': 238450000,
          'cash': 76300000,
          'qris': 162150000,
          'cups': 11640,
          'online_cups': 4600,
          'walkin_cups': 7040,
          'net_profit': 155708000,
          'growth': '31.40%',
          'is_positive': true,
          'active_staff': 5,
          'total_staff': _staffList.length,
          'order_value_str': '340k',
          'orders_str': '385k',
          'users_str': '89.15%',
          'downloads_str': '62400',
          'chart_label': 'Sales Report 30 Hari (Per Minggu)',
          'chart_bars': [
            {'yellow': 32.0, 'amber': 50.0, 'label': 'Mgg 1'},
            {'yellow': 40.0, 'amber': 58.0, 'label': 'Mgg 2'},
            {'yellow': 46.0, 'amber': 65.0, 'label': 'Mgg 3'},
            {'yellow': 55.0, 'amber': 72.0, 'label': 'Mgg 4'},
          ],
          'top_products': [
            {'name': 'Kopi Susu Gula Aren', 'sold': '5.940 cup (51%)', 'omzet': 106920000, 'stock': '950 cup'},
            {'name': 'Americano Double Shot', 'sold': '2.680 cup (23%)', 'omzet': 40200000, 'stock': '650 cup'},
            {'name': 'Matcha Uji Latte Creamy', 'sold': '1.740 cup (15%)', 'omzet': 38280000, 'stock': '430 cup'},
            {'name': 'Cafe Latte Steam Velvet', 'sold': '940 cup (8%)', 'omzet': 18800000, 'stock': '520 cup'},
            {'name': 'Cold Brew Citrus Refresh', 'sold': '340 cup (3%)', 'omzet': 7480000, 'stock': '310 cup'},
          ],
          'speed_label': '+31.4% vs bulan sebelumnya',
          'speed_rows': [
            {'time': 'Minggu 1 (16–22 Okt)', 'cups': '2.520 cup', 'is_peak': false},
            {'time': 'Minggu 2 (23–29 Okt)', 'cups': '2.840 cup', 'is_peak': false},
            {'time': 'Minggu 3 (30 Okt–5 Nov)', 'cups': '3.010 cup', 'is_peak': false},
            {'time': 'Minggu 4 (6–14 Nov Peak)', 'cups': '3.270 cup', 'is_peak': true},
          ],
        };
      case 'Hari Ini':
      default:
        final num totalCash = _staffList.fold(0, (acc, s) => acc + (s['cash'] as num));
        final num totalQris = _staffList.fold(0, (acc, s) => acc + (s['qris'] as num));
        final num totalOmzet = totalCash + totalQris;
        final num totalCups = _staffList.fold(0, (acc, s) => acc + (s['cups_sold'] as num));
        final num netProfit = (totalOmzet * 0.653).round();
        final activeStaff = _staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length;
        return {
          'period_label': 'Hari Ini (14 Nov 2026)',
          'omzet': totalOmzet,
          'cash': totalCash,
          'qris': totalQris,
          'cups': totalCups.toInt(),
          'online_cups': 168,
          'walkin_cups': 255,
          'net_profit': netProfit,
          'growth': '24.50%',
          'is_positive': true,
          'active_staff': activeStaff,
          'total_staff': _staffList.length,
          'order_value_str': '12.3k',
          'orders_str': '14k',
          'users_str': '71.56%',
          'downloads_str': '34040',
          'chart_label': 'Sales Report Hari Ini',
          'chart_bars': [
            {'yellow': 24.0, 'amber': 42.0, 'label': '07:00'},
            {'yellow': 32.0, 'amber': 20.0, 'label': '09:00'},
            {'yellow': 46.0, 'amber': 62.0, 'label': '12:00'},
            {'yellow': 18.0, 'amber': 30.0, 'label': '14:00'},
            {'yellow': 52.0, 'amber': 68.0, 'label': '17:00'},
            {'yellow': 28.0, 'amber': 38.0, 'label': '19:00'},
          ],
          'top_products': [
            {'name': 'Kopi Susu Gula Aren', 'sold': '215 cup (51%)', 'omzet': 3870000, 'stock': '950 cup'},
            {'name': 'Americano Double Shot', 'sold': '98 cup (23%)', 'omzet': 1470000, 'stock': '650 cup'},
            {'name': 'Matcha Uji Latte Creamy', 'sold': '62 cup (15%)', 'omzet': 1364000, 'stock': '430 cup'},
            {'name': 'Cafe Latte Steam Velvet', 'sold': '36 cup (8%)', 'omzet': 720000, 'stock': '520 cup'},
            {'name': 'Cold Brew Citrus Refresh', 'sold': '12 cup (3%)', 'omzet': 264000, 'stock': '310 cup'},
          ],
          'speed_label': '+24% vs kemarin',
          'speed_rows': [
            {'time': '06:00 – 08:30 (Pagi Komuter)', 'cups': '95 cup', 'is_peak': false},
            {'time': '08:30 – 11:30 (Jam Kantor)', 'cups': '75 cup', 'is_peak': false},
            {'time': '11:30 – 13:30 (Makan Siang)', 'cups': '145 cup', 'is_peak': true},
            {'time': '13:30 – 15:30 (Sore Berjalan)', 'cups': '108 cup', 'is_peak': false},
            {'time': '16:30 – 19:00 (Estimasi Pulang)', 'cups': '~150 cup', 'is_peak': false},
          ],
        };
    }
  }

  Widget _buildDashboardView() {
    final d = _getDashboardDataForFilter();
    final num totalCash = d['cash'] as num;
    final num totalOmzet = d['omzet'] as num;
    final int totalCups = (d['cups'] as num).toInt();
    final int onlineCups = (d['online_cups'] as num).toInt();
    final int walkinCups = (d['walkin_cups'] as num).toInt();
    final num netProfit = d['net_profit'] as num;
    final int activeStaff = (d['active_staff'] as num).toInt();
    final int totalStaff = (d['total_staff'] as num).toInt();
    final String growth = d['growth'] as String;
    final String periodLabel = d['period_label'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // =====================================================================
        // 1. CONTENT HEADER WITH ACTION BUTTONS (LIKE 3S.NET SCREENSHOT)
        // =====================================================================
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pipeline Calon Pelanggan & Penjualan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.4),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Monitoring penjualan live gerobak, telemetri armada real-time, status inventori dan lapak aktif • $periodLabel',
                    style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    side: const BorderSide(color: Color(0xFFE5E7EB)),
                    foregroundColor: const Color(0xFF374151),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: Duration(seconds: 1), content: Text('Data operasional & telemetri gerobak diperbarui.')),
                    );
                  },
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    foregroundColor: const Color(0xFF1E3932),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => setState(() => _selectedNavIndex = 10),
                  icon: const Icon(Icons.psychology, size: 16, color: Color(0xFF1E3932)),
                  label: const Text('Analisis AI Alokasi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932), // 3S.NET Dark Forest Green
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _showAddStaffDialog,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah Petugas / Gerobak', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // =====================================================================
        // 2. CONSOLIDATED STATUS CONTAINER (EXACT 3S.NET UPPER CARD)
        // =====================================================================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Status Operasional & Penjualan Terkonsolidasi',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF111827)),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.circle, size: 8, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text(
                          'Real-time Live Telemetry Synced',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              IntrinsicHeight(
                child: Row(
                  children: [
                    // Col 1: Omzet
                    Expanded(
                      child: _buildConsolidatedColumn(
                        'Total Omzet Konsolidasi',
                        _formatRupiah(totalOmzet),
                        '+$growth vs target harian',
                        const Color(0xFF059669),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),

                    // Col 2: Cups
                    Expanded(
                      child: _buildConsolidatedColumn(
                        'Total Cup Terjual',
                        '$totalCups Cup',
                        '$onlineCups Online 40% • $walkinCups Lapak 60%',
                        const Color(0xFF4B5563),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),

                    // Col 3: Armada
                    Expanded(
                      child: _buildConsolidatedColumn(
                        'Armada Beroperasi',
                        '$activeStaff / $totalStaff Unit',
                        '1 Gerobak Standby di Gudang',
                        const Color(0xFF4B5563),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),

                    // Col 4: Laba Bersih
                    Expanded(
                      child: _buildConsolidatedColumn(
                        'Estimasi Laba Bersih',
                        _formatRupiah(netProfit),
                        'Margin 65.3% Bersih setelah HPP Bahan',
                        const Color(0xFF059669),
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),

                    // Col 5: Kas Lapangan Belum Setor
                    Expanded(
                      child: _buildConsolidatedColumn(
                        'Kas Lapangan Belum Setor',
                        _formatRupiah(totalCash),
                        'Penerimaan Cash Fisik di Gerobak',
                        const Color(0xFFD97706),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // =====================================================================
        // 3. SUB-FILTER TABS (LIKE 3S.NET SCREENSHOT)
        // =====================================================================
        Row(
          children: [
            _build3STab('Semua Tim Lapangan', true),
            const SizedBox(width: 6),
            _build3STab('4 Unit Aktif Jualan', false),
            const SizedBox(width: 6),
            _build3STab('1 Standby Gudang', false),
            const SizedBox(width: 6),
            _build3STab('Rekonsiliasi Kas Siap', false),
            const SizedBox(width: 6),
            _build3STab('Analisis AI Permintaan', false),
          ],
        ),
        const SizedBox(height: 14),

        // Warning Alert Banner (Stok Menipis)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, size: 18, color: Color(0xFFD97706)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Peringatan Stok Menipis: Hendra Wijaya - GRB-04 Stasiun Juanda sisa 15 Cup. Peak komuter pulang kerja KRL 16:30 WIB. Model AI menyarankan restock 20 cup segera.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                ),
              ),
              InkWell(
                onTap: _showDistributeStockDialog,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('Beri Tambahan Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFD97706))),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward, size: 13, color: Color(0xFFD97706)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // =====================================================================
        // 4. PERFORMANCE HIGHLIGHTS: TOP SELLER, TOP AREA, TOP MENU (REQUIREMENT 3)
        // =====================================================================
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CARD A: TOP SELLER LAPANGAN
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.emoji_events_outlined, size: 18, color: Color(0xFF1E3932)),
                            SizedBox(width: 8),
                            Text('Top Seller Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF111827))),
                          ],
                        ),
                        const Text('Target: 100-120 Cup', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildTopSellerRow('1', 'Budi Santoso - GRB-01', '142 / 120 Cup • 118%', 'Omzet: Rp 2.840.000 • Cash: Rp 900.000 | QRIS: Rp 1.940.000', 1.0, const Color(0xFF059669)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('2', 'Hendra Wijaya - GRB-04', '118 / 110 Cup • 107%', 'Omzet: Rp 2.360.000 • Cash: Rp 780.000 | QRIS: Rp 1.580.000', 0.95, const Color(0xFF0D9488)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('3', 'Siti Rahmawati - GRB-03', '95 / 120 Cup • 79%', 'Omzet: Rp 1.980.000 • Cash: Rp 640.000 | QRIS: Rp 1.340.000', 0.79, const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('4', 'Ahmad Fauzi - GRB-02', '68 / 120 Cup • 56%', 'Omzet: Rp 1.420.000 • Cash: Rp 520.000 | QRIS: Rp 900.000', 0.56, const Color(0xFFD97706)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // CARD B: TOP TITIK JUALAN TERLAKU
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF1E3932)),
                            SizedBox(width: 8),
                            Text('Top Area & Titik Jualan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF111827))),
                          ],
                        ),
                        const Text('Volume & Arus', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildTopAreaTile('1', 'Pintu Timur Stasiun Juanda', '155 Cup terjual', 'Peak: 07:00-09:15 & 16:30-18:30 KRL • Arus 14.800/jam', isAlert: true, alertText: 'Sisa 15 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('2', 'Halte Dukuh Atas Sudirman', '142 Cup terjual', 'Peak: 07:30-09:30 & 12:00-13:30 • Arus 12.200/jam', isAlert: false, alertText: 'Aman 42 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('3', 'Pojok Blok III Pasar Senen', '95 Cup terjual', 'Peak: 06:00-10:00 Grosir • Arus 8.500/jam', isAlert: false, alertText: 'Aman 35 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('4', 'Taman Suropati Menteng', '68 Cup terjual', 'Peak: 17:30-21:00 Santai Malam • Arus 4.200/jam', isAlert: false, alertText: 'Aman 28 cup'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // CARD C: TOP MENU & PRODUK TERLARIS
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.local_cafe_outlined, size: 18, color: Color(0xFF1E3932)),
                            SizedBox(width: 8),
                            Text('Top Menu & Produk Terlaris', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF111827))),
                          ],
                        ),
                        Text('$totalCups Cup Terjual', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                      ],
                    ),
                    const SizedBox(height: 14),

                    _buildTopProductTile('1', 'Kopi Susu Gula Aren', '215 Cup • 50.8%', 'Rp 3.870.000 • Gudang: 950 cup', '+28%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('2', 'Americano Double Shot', '98 Cup • 23.2%', 'Rp 1.470.000 • Gudang: 650 cup', '+15%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('3', 'Matcha Uji Latte Creamy', '62 Cup • 14.6%', 'Rp 1.364.000 • Gudang: 430 cup', '+9%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('4', 'Cafe Latte Steam Velvet', '36 Cup • 8.5%', 'Rp 720.000 • Gudang: 520 cup', '+5%'),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // =====================================================================
        // 5. ANALISIS AI PREDIKSI PERMINTAAN & REKOMENDASI ALOKASI (REQUIREMENT 6)
        // =====================================================================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3932).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.psychology, color: Color(0xFF1E3932), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Analisis AI Prediksi Permintaan Lapangan & Rekomendasi Alokasi Stok',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827)),
                            ),
                            Text(
                              'Optimasi alokasi cup bawaan per gerobak berdasarkan cuaca, temperatur, indeks dingin, sensor arus komuter transit, dan histori penjualan',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Akurasi Model: 96.4% • MILP Engine',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.6),
                  1: FlexColumnWidth(1.6),
                  2: FlexColumnWidth(1.6),
                  3: FlexColumnWidth(2.2),
                  4: FlexColumnWidth(2.2),
                  5: FlexColumnWidth(3.8),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
                    children: [
                      _cleanTh('Titik Lapak & Area'),
                      _cleanTh('Alokasi AI'),
                      _cleanTh('Estimasi Laku'),
                      _cleanTh('Parameter Cuaca'),
                      _cleanTh('Trafik Keramaian'),
                      _cleanTh('Rekomendasi Tindakan AI Realtime'),
                    ],
                  ),
                  _buildAiAnalysisRow(
                    'Area A: Pintu Stasiun Juanda',
                    'Transit Komuter KRL',
                    '130 Cup',
                    'Bawa kini: 110 cup',
                    '125 – 135 Cup',
                    'Terserap: 118 cup',
                    '32°C Cerah Terik',
                    'Indeks Es Kopi +38%',
                    'Sangat Padat',
                    '14.800 org/jam • Peak 16:30',
                    'Stok kritis sisa 15 cup! Segera kirim 20 cup restock dari gudang sebelum jam 16:30.',
                    isWarning: true,
                  ),
                  _buildAiAnalysisRow(
                    'Area B: Halte Dukuh Atas Sudirman',
                    'Perkantoran & MRT/TJ',
                    '150 Cup',
                    'Bawa kini: 120 cup',
                    '140 – 150 Cup',
                    'Terserap: 142 cup',
                    '29°C Berawan Tipis',
                    'Demand Kopi Susu Aren stabil',
                    'Tinggi Komuter',
                    '12.200 org/jam • Kantor Pulang',
                    'Optimal: Target 118% tercapai. Sisa 42 cup aman hingga penutupan shift.',
                    isWarning: false,
                  ),
                  _buildAiAnalysisRow(
                    'Area C: Pojok Pasar Senen',
                    'Pusat Grosir & Niaga',
                    '110 Cup',
                    'Bawa kini: 120 cup',
                    '95 – 105 Cup',
                    'Terserap: 95 cup',
                    '31°C Panas Terbuka',
                    'Tinggi Es Kopi Hitam & Aren',
                    'Stabil Ramai',
                    '8.500 org/jam • Pedagang',
                    'Target 95 cup tercapai. Sisa 35 cup mencukupi closing shift pukul 16:00 WIB.',
                    isWarning: false,
                  ),
                  _buildAiAnalysisRow(
                    'Area D: Taman Suropati Menteng',
                    'Kawasan Santai & Komunitas',
                    '80 Cup',
                    'Bawa kini: 100 cup',
                    '70 – 80 Cup',
                    'Terserap: 68 cup',
                    '27°C Sejuk Teduh',
                    'Permintaan kopi hangat malam',
                    'Sedang ke Puncak Sore',
                    '4.200 org/jam • Peak 18:00–21:00',
                    'Demand bergeser ke malam hari. Siapkan varian hangat dan Matcha.',
                    isWarning: false,
                  ),
                  _buildAiAnalysisRow(
                    'Area E: Kuningan Madya Standby',
                    'Koridor Rasuna Said',
                    '70 Cup',
                    'GRB-05 di Gudang',
                    '60 – 70 Cup',
                    'Peluang jam pulang kantor',
                    '30°C Cerah',
                    'Demand komuter kantor',
                    'Padat Kantor',
                    '10.000 org/jam • 16:30–18:30',
                    'Peluang ekspansi: Deploy GRB-05 dengan seller Rizky untuk menangkap arus pulang kerja.',
                    isWarning: false,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // =====================================================================
        // 6. ARMADA & GEROBAK LAPANGAN (REQUIREMENT 5: MODAL LOCATION POPUP)
        // =====================================================================
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Armada & Gerobak Lapangan', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF111827))),
                    Row(
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
                            foregroundColor: const Color(0xFF374151),
                          ),
                          onPressed: _showDistributeStockDialog,
                          child: const Text('Bagi Stok Pagi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E3932),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                          onPressed: _showAddStaffDialog,
                          child: const Text('+ Petugas', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(3.0),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.1),
                  4: FlexColumnWidth(1.1),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.6),
                  7: FlexColumnWidth(1.2),
                  8: FlexColumnWidth(2.0),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
                    children: [
                      _cleanTh('Petugas & Unit'),
                      _cleanTh('Titik Lapak'),
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
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                      children: [
                        _cleanTd('${s['name']}\n${s['cart_id']}', bold: true),
                        _cleanTd(s['location']),
                        _cleanTd(s['clock_in']),
                        _cleanTd('${s['morning_stock']} cup'),
                        _cleanTd('${s['current_stock']} cup', color: (s['current_stock'] as int) < 20 && s['operational_status'] == 'ACTIVE_SELLING' ? const Color(0xFFDC2626) : null, bold: (s['current_stock'] as int) < 20),
                        _cleanTd(_formatRupiah(s['cash'] as num)),
                        _cleanTd(_formatRupiah(s['qris'] as num)),
                        _cleanStatusPill(s['operational_status'] == 'ACTIVE_SELLING' ? 'Jualan' : (s['operational_status'] == 'CLOSED_SHIFT' ? 'Tutup Shift' : 'Belum Mulai'), s['operational_status'] == 'ACTIVE_SELLING'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // POPUP MODAL REALTIME LOCATION (REQUIREMENT 5: NO PAGE SWITCH)
                              InkWell(
                                onTap: () => _showSellerRealtimeLocationDialog(s),
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3932).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF1E3932).withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.place_outlined, size: 14, color: Color(0xFF1E3932)),
                                      SizedBox(width: 4),
                                      Text('Lokasi Live', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3932))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    final isSelling = s['operational_status'] == 'ACTIVE_SELLING';
                                    s['operational_status'] = isSelling ? 'OFFLINE' : 'ACTIVE_SELLING';
                                  });
                                },
                                child: Text(
                                  s['operational_status'] == 'ACTIVE_SELLING' ? 'Tutup' : 'Buka',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: s['operational_status'] == 'ACTIVE_SELLING' ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                                ),
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
  // WIDGET HELPERS: 3S.NET COMPONENTS, TILES, AI ROWS & FINANCE BREAKDOWN
  // ===========================================================================
  Widget _buildConsolidatedColumn(String title, String value, String sub, Color subColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 11, color: subColor, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _build3STab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isSelected ? const Color(0xFFD1D5DB) : Colors.transparent),
        boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 2, offset: const Offset(0, 1))] : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          color: isSelected ? const Color(0xFF1E3932) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildTopSellerRow(String rank, String name, String cups, String sub, double progress, Color barColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(rank, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              ],
            ),
            Text(cups, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFE5E7EB),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 5,
          ),
        ),
        const SizedBox(height: 3),
        Text(sub, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
      ],
    );
  }

  Widget _buildTopAreaTile(String rank, String title, String cups, String detail, {bool isAlert = false, String alertText = ''}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAlert ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(rank, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF374151))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isAlert ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      alertText,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAlert ? const Color(0xFFDC2626) : const Color(0xFF059669)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(detail, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopProductTile(String rank, String name, String sold, String revenue, String growth) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(rank, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                  Text(growth, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                ],
              ),
              const SizedBox(height: 2),
              Text('$sold • $revenue', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
            ],
          ),
        ),
      ],
    );
  }

  TableRow _buildAiAnalysisRow(
    String area,
    String subtitle,
    String aiStock,
    String currentStock,
    String estSales,
    String absorbed,
    String weather,
    String weatherSub,
    String traffic,
    String trafficSub,
    String action, {
    required bool isWarning,
  }) {
    return TableRow(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(area, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(aiStock, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E3932))),
              Text(currentStock, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(estSales, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Text(absorbed, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(weather, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              Text(weatherSub, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(traffic, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
              Text(trafficSub, style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            action,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isWarning ? FontWeight.bold : FontWeight.normal,
              color: isWarning ? const Color(0xFFB45309) : const Color(0xFF374151),
            ),
          ),
        ),
      ],
    );
  }

  Widget _cleanCashStatusBadge(String status) {
    final bool isBalance = status == 'BALANCE';
    final bool isStandby = status == 'STANDBY';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: isBalance ? const Color(0xFFECFDF5) : (isStandby ? const Color(0xFFF3F4F6) : const Color(0xFFFEF2F2)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            isBalance ? 'BALANCE' : (isStandby ? 'STANDBY' : 'SELISIH'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isBalance ? const Color(0xFF047857) : (isStandby ? const Color(0xFF6B7280) : const Color(0xFFDC2626)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value, String sub, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 11.5, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? const Color(0xFF111827) : const Color(0xFF4B5563))),
          Row(
            children: [
              Text(value, style: TextStyle(fontSize: 11.5, fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600, color: color ?? (isTotal ? const Color(0xFF111827) : const Color(0xFF111827)))),
              const SizedBox(width: 6),
              Text('($sub)', style: TextStyle(fontSize: 10, color: color ?? const Color(0xFF6B7280))),
            ],
          ),
        ],
      ),
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
        // 1. Header Toolbar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Peta Posisi Tim & GPS Realtime',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.4),
                ),
                SizedBox(height: 3),
                Text(
                  'Peta interaktif pelacakan telemetri GPS armada gerobak. Pin bergerak mengikuti peta, klik pin untuk melihat detail.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(
                        '${_staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length} Unit Jualan Aktif',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    foregroundColor: const Color(0xFF374151),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  icon: const Icon(Icons.refresh, size: 15),
                  label: const Text('Refresh', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  onPressed: () {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: Duration(seconds: 1), content: Text('Koordinat GPS telemetri seluruh armada diperbarui.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. Bar Selektor Titik Tim Cepat (Diletakkan di atas peta agar tidak bentrok klik)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
            ],
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3932).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me, size: 14, color: Color(0xFF1E3932)),
                    SizedBox(width: 4),
                    Text(
                      'Pilih Titik Tim:',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF1E3932)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _staffList.map((s) {
                      final isSelected = s['id'] == _focusedStaffId;
                      final isSelling = s['operational_status'] == 'ACTIVE_SELLING';
                      final isLowStock = isSelling && (s['current_stock'] as int) < 20;

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _focusedStaffId = s['id'] as String;
                              _liveMapLat = (s['lat'] as num).toDouble();
                              _liveMapLng = (s['lng'] as num).toDouble();
                              _liveMapZoom = 16;
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1E3932) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFF1E3932)
                                    : (isLowStock ? const Color(0xFFF87171) : const Color(0xFFD1D5DB)),
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 7,
                                  height: 7,
                                  decoration: BoxDecoration(
                                    color: isSelling ? (isLowStock ? Colors.amber : const Color(0xFF10B981)) : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(s['cart_id'] as String).split(' ')[0]} • ${s['name']}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                    color: isSelected ? Colors.white : const Color(0xFF1F2937),
                                  ),
                                ),
                                if (isLowStock) ...[
                                  const SizedBox(width: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.red.shade700 : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      '${s['current_stock']} cup',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : const Color(0xFFDC2626),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 3. Peta Interaktif Penuh (Leaflet Map dengan Marker Asli Terintegrasi)
        Container(
          height: 600,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: RealLiveGoogleMap(
            latitude: _liveMapLat,
            longitude: _liveMapLng,
            zoom: _liveMapZoom,
            staffList: _staffList,
            focusedStaffId: _focusedStaffId,
            onStaffSelected: (staffId) {
              setState(() {
                _focusedStaffId = staffId;
                final st = _staffList.firstWhere((s) => s['id'] == staffId, orElse: () => _staffList.first);
                _liveMapLat = (st['lat'] as num).toDouble();
                _liveMapLng = (st['lng'] as num).toDouble();
              });
            },
          ),
        ),
        const SizedBox(height: 14),

        // 4. Panel Informasi & Telemetri Lengkap Tim Terpilih
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFF1E3932),
                        child: Text(
                          (focusedStaff['name'] as String).split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            focusedStaff['name'] as String,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          ),
                          Text(
                            '${focusedStaff['role']} • ${focusedStaff['cart_id']}',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: focusedStaff['operational_status'] == 'ACTIVE_SELLING'
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: focusedStaff['operational_status'] == 'ACTIVE_SELLING'
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          focusedStaff['operational_status'] == 'ACTIVE_SELLING' ? 'Jualan Aktif' : 'Standby Gudang',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: focusedStaff['operational_status'] == 'ACTIVE_SELLING'
                                ? const Color(0xFF065F46)
                                : const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          foregroundColor: const Color(0xFF374151),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _showRelocateStaffDialog(focusedStaff),
                        child: const Text('Relokasi Lapak', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3932),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: () => _showAddStockToStaffDialog(focusedStaff),
                        child: const Text('+ Tambah Stok', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildMapDetailColumn('Titik Lapak Jualan', focusedStaff['location'] as String, isHighlight: true),
                  ),
                  Expanded(
                    child: _buildMapDetailColumn('Koordinat GPS Telemetri', '${focusedStaff['lat']}, ${focusedStaff['lng']} (${focusedStaff['gps_status']})'),
                  ),
                  Expanded(
                    child: _buildMapDetailColumn('Jam Mulai Shift', focusedStaff['clock_in'] as String),
                  ),
                  Expanded(
                    child: _buildMapDetailColumn('Kontak Telepon Seller', focusedStaff['phone'] as String),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _buildMapStatBox(
                      'Sisa Stok di Box',
                      '${focusedStaff['current_stock']} Cup',
                      sub: 'Bawaan: ${focusedStaff['morning_stock']} Cup',
                      color: (focusedStaff['current_stock'] as int) < 20 && focusedStaff['operational_status'] == 'ACTIVE_SELLING'
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF1E3932),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMapStatBox(
                      'Total Terjual Hari Ini',
                      '${focusedStaff['cups_sold']} Cup',
                      sub: 'Kanal Offline Lapak',
                      color: const Color(0xFF059669),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMapStatBox(
                      'Penerimaan Kas Fisik',
                      _formatRupiah(focusedStaff['cash'] as num),
                      sub: 'Penerimaan QRIS: ${_formatRupiah(focusedStaff['qris'] as num)}',
                      color: const Color(0xFFD97706),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMapStatBox(
                      'Status Rekonsiliasi Kas',
                      focusedStaff['cash_status'] as String,
                      sub: 'Audit Kas Lapangan',
                      color: focusedStaff['cash_status'] == 'BALANCE' ? const Color(0xFF065F46) : const Color(0xFFDC2626),
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

  Widget _buildMapDetailColumn(String label, String value, {bool isHighlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
            color: isHighlight ? const Color(0xFF1E3932) : const Color(0xFF111827),
          ),
        ),
      ],
    );
  }

  Widget _buildMapStatBox(String label, String value, {required String sub, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9.5, color: Color(0xFF6B7280))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 1),
          Text(sub, style: const TextStyle(fontSize: 8.5, color: Color(0xFF9CA3AF)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
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
  // SUB-PAGES: GUDANG & STOK (FOKUS MONITORING STOK 6 MENU UTAMA)
  // ===========================================================================
  Widget _buildWarehouseManagementView() {
    final int totalCentralStock = _warehouseStock.fold<int>(0, (sum, item) => sum + (item['central_stock'] as int));
    final int totalInCarts = _warehouseStock.fold<int>(0, (sum, item) => sum + ((item['held_by_cart'] ?? 0) as int));
    final int grandTotalStock = totalCentralStock + totalInCarts;
    final int lowStockItems = _warehouseStock.where((item) => (item['central_stock'] as int) <= ((item['min_stock'] ?? 150) as int)).length;

    final categories = ['Semua', 'Kopi Susu', 'Classic Coffee', 'Non-Coffee'];
    final filteredStock = _warehouseStock.where((item) {
      final matchCat = _warehouseCategoryFilter == 'Semua' || item['category'] == _warehouseCategoryFilter;
      return matchCat;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. PAGE HEADER & QUICK ACTIONS
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Gudang Pusat & Manajemen Stok',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF111827), letterSpacing: -0.3),
                ),
                SizedBox(height: 3),
                Text(
                  'Monitoring persediaan fisik 6 menu resmi KopiCerdas, sisa stok gudang pusat, dan pantauan alokasi gerobak',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3932),
                    side: const BorderSide(color: Color(0xFF1E3932)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _showAddStockDialog,
                  icon: const Icon(Icons.add_box_outlined, size: 16),
                  label: const Text('Input Stok Masuk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _showDistributeStockDialog,
                  icon: const Icon(Icons.local_shipping_outlined, size: 16),
                  label: const Text('Alokasi ke Gerobak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 2. CONSOLIDATED KPI SUMMARY BAR (FOKUS FISIK QUANTITY STOK)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Total Stok Gudang Pusat',
                    '$totalCentralStock Porsi',
                    'Kapasitas Ruang Aman 85%',
                    const Color(0xFF059669),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Stok Terbawa di Gerobak',
                    '$totalInCarts Porsi',
                    'Bawaan Aktif 5 Unit Lapangan',
                    const Color(0xFFD97706),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Total Akumulasi Stok',
                    '$grandTotalStock Porsi',
                    'Konsolidasi Gudang + Gerobak',
                    const Color(0xFF1E3932),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Status Persediaan 6 Menu',
                    lowStockItems == 0 ? 'Semua Stok Aman' : '$lowStockItems SKU Menipis',
                    lowStockItems == 0 ? 'Semua produk di atas batas aman' : 'Perlu order bahan baku',
                    lowStockItems == 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 3. MAIN WAREHOUSE STOCK TABLE CONTAINER (FOKUS FISIK STOK)
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Toolbar: Title + Category Filter Chips
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3932).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF1E3932), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Persediaan Stok 6 Menu Utama',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827)),
                            ),
                            Text(
                              'Menampilkan  dari  menu resmi KopiCerdas',
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Filter category pills
                    Row(
                      children: categories.map((cat) {
                        final isSel = _warehouseCategoryFilter == cat;
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: InkWell(
                            onTap: () => setState(() => _warehouseCategoryFilter = cat),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF1E3932) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                  color: isSel ? Colors.white : const Color(0xFF4B5563),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // Enhanced Data Table - Pure Stock Focused
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2), // SKU
                  1: FlexColumnWidth(2.6), // Menu Kopi
                  2: FlexColumnWidth(1.5), // Kategori
                  3: FlexColumnWidth(2.6), // Stok Gudang Pusat & Level Bar
                  4: FlexColumnWidth(1.5), // Di Gerobak
                  5: FlexColumnWidth(1.4), // Batas Min
                  6: FlexColumnWidth(1.5), // Total Fisik
                  7: FlexColumnWidth(1.4), // Status
                  8: FlexColumnWidth(2.0), // Aksi Cepat
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    children: [
                      _cleanTh('SKU'),
                      _cleanTh('Menu Produk'),
                      _cleanTh('Kategori'),
                      _cleanTh('Stok Gudang Pusat'),
                      _cleanTh('Di Gerobak'),
                      _cleanTh('Batas Min'),
                      _cleanTh('Total Stok'),
                      _cleanTh('Status'),
                      _cleanTh('Aksi Cepat'),
                    ],
                  ),
                  for (final w in filteredStock)
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                      ),
                      children: [
                        // SKU
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                w['sku'].toString(),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                              ),
                            ),
                          ),
                        ),

                        // Menu Produk
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Text(
                            w['name'].toString(),
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                          ),
                        ),

                        // Kategori
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Text(
                                w['category'].toString(),
                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                              ),
                            ),
                          ),
                        ),

                        // Stok Gudang Pusat & Visual Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827)),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text('Porsi', style: TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: LinearProgressIndicator(
                                  value: ((w['central_stock'] as int) / 1000).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFE5E7EB),
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    (w['central_stock'] as int) < ((w['min_stock'] ?? 150) as int)
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF059669),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Di Gerobak
                        _cleanTd('${w['held_by_cart'] ?? 0} Porsi', bold: true, color: const Color(0xFFD97706)),

                        // Batas Minimum
                        _cleanTd('${w['min_stock'] ?? 100} Porsi', color: const Color(0xFF6B7280)),

                        // Total Stok (Gudang + Gerobak)
                        _cleanTd('${(w['central_stock'] as int) + ((w['held_by_cart'] ?? 0) as int)} Porsi', bold: true, color: const Color(0xFF1E3932)),

                        // Status Badge
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: w['status'] == 'Aman' ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: w['status'] == 'Aman' ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: w['status'] == 'Aman' ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    w['status'] == 'Aman' ? 'Aman' : 'Menipis',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: w['status'] == 'Aman' ? const Color(0xFF065F46) : const Color(0xFF991B1B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Aksi Cepat
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: _showAddStockDialog,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3932).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add, size: 12, color: Color(0xFF1E3932)),
                                      SizedBox(width: 2),
                                      Text(
                                        'Restock',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF1E3932)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              InkWell(
                                onTap: _showDistributeStockDialog,
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF3F4F6),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Kirim',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
                                  ),
                                ),
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
  // SUB-PAGES: MANAGE PENGHASILAN PENJUALAN & VERIFIKASI KAS SHIFT
  // ===========================================================================
  Widget _buildSalesMonitoringView() {
    final d = _getDashboardDataForFilter();
    final num totalOmzet = d['omzet'] as num;
    final num totalCash = d['cash'] as num;
    final num totalQris = d['qris'] as num;
    final int totalCups = (d['cups'] as num).toInt();
    final String periodLabel = d['period_label'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Content Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manage Penghasilan Penjualan & Verifikasi Kas Shift',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF111827), letterSpacing: -0.3),
                ),
                const SizedBox(height: 3),
                Text(
                  'Verifikasi penerimaan dana tunai fisik seller, audit sisa stok box, dan rekonsiliasi pembayaran QRIS • $periodLabel',
                  style: const TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF374151),
                side: const BorderSide(color: Color(0xFFD1D5DB)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: () => setState(() {}),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Data', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Consolidated KPI Metrics Bar
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Total Omzet Penjualan',
                    _formatRupiah(totalOmzet),
                    'Konsolidasi Cash & QRIS',
                    const Color(0xFF059669),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Penerimaan Kas Tunai',
                    _formatRupiah(totalCash),
                    'Kas Fisik Petugas Gerobak',
                    const Color(0xFFD97706),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Penerimaan Digital QRIS',
                    _formatRupiah(totalQris),
                    'Settlement Rekening Bank',
                    const Color(0xFF1E3932),
                  ),
                ),
                const VerticalDivider(width: 1, color: Color(0xFFE5E7EB)),
                Expanded(
                  child: _buildConsolidatedColumn(
                    'Total Volume Terjual',
                    '$totalCups Cup',
                    'Akumulasi Penjualan Hari Ini',
                    const Color(0xFF4B5563),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),

        // 1. REKONSILIASI KAS & AUDIT TUTUP SHIFT
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3932).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF1E3932), size: 20),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Verifikasi Setoran Kas & Tutup Shift',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827)),
                            ),
                            Text(
                              'Audit sisa cup fisik pulang, pencocokan dana tunai di tangan seller vs kas sistem, dan verifikasi status selisih',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Text(
                        'Total Kas Tunai Belum Disetor: ${_formatRupiah(totalCash)}',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.6),
                  1: FlexColumnWidth(1.2),
                  2: FlexColumnWidth(1.2),
                  3: FlexColumnWidth(1.2),
                  4: FlexColumnWidth(1.7),
                  5: FlexColumnWidth(1.8),
                  6: FlexColumnWidth(1.8),
                  7: FlexColumnWidth(1.5),
                  8: FlexColumnWidth(1.6),
                  9: FlexColumnWidth(2.0),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
                    children: [
                      _cleanTh('Petugas & Unit'),
                      _cleanTh('Bawaan'),
                      _cleanTh('Sisa Box'),
                      _cleanTh('Terjual'),
                      _cleanTh('QRIS Masuk'),
                      _cleanTh('Kas Seharusnya'),
                      _cleanTh('Kas Disetor'),
                      _cleanTh('Selisih'),
                      _cleanTh('Status Audit'),
                      _cleanTh('Aksi Verifikasi'),
                    ],
                  ),
                  for (final s in _staffList.where((st) => (st['morning_stock'] as int) > 0))
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6)))),
                      children: [
                        _cleanTd('${s['name']}\n${s['cart_id']}', bold: true),
                        _cleanTd('${s['morning_stock']} cup'),
                        _cleanTd('${s['current_stock']} cup', bold: true, color: const Color(0xFFD97706)),
                        _cleanTd('${s['cups_sold']} cup', bold: true, color: const Color(0xFF059669)),
                        _cleanTd(_formatRupiah(s['qris'] as num)),
                        _cleanTd(_formatRupiah(s['cash'] as num), bold: true),
                        _cleanTd(_formatRupiah((s['cash_submitted'] ?? s['cash']) as num)),
                        _cleanTd(
                          ((s['cash_submitted'] ?? s['cash']) as num) - (s['cash'] as num) == 0
                              ? 'Rp 0'
                              : _formatRupiah((((s['cash_submitted'] ?? s['cash']) as num) - (s['cash'] as num)).abs()),
                          color: ((s['cash_submitted'] ?? s['cash']) as num) - (s['cash'] as num) == 0 ? const Color(0xFF059669) : const Color(0xFFDC2626),
                          bold: true,
                        ),
                        _cleanCashStatusBadge(s['cash_status'] ?? 'BALANCE'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3932),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () => _showCashSettlementDialog(s),
                            child: const Text('Verifikasi Shift', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // 2. LOG TRANSAKSI PENJUALAN MASUK
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3932).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.receipt_long_outlined, color: Color(0xFF1E3932), size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Log Transaksi Penjualan Masuk (POS Kasir & Pre-Order)',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF111827)),
                        ),
                        Text(
                          'Catatan transaksi live setiap penjualan per cup kopi dari seluruh gerobak operasional',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
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
                    decoration: const BoxDecoration(color: Color(0xFFF9FAFB), border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))),
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
    final d = _getDashboardDataForFilter();
    final num totalOmzet = d['omzet'] as num;
    final num totalCash = d['cash'] as num;
    final num totalQris = d['qris'] as num;
    final num totalHpp = (totalOmzet * 0.323).round();
    final num operationalCost = 210000;
    final num netProfit = totalOmzet - totalHpp - operationalCost;
    final String periodLabel = d['period_label'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Laporan Keuangan Rinci: Arus Kas Tunai vs QRIS — $periodLabel', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111827))),
                const SizedBox(height: 2),
                const Text('Rincian penerimaan Cash tunai, QRIS digital, HPP bahan baku, laba bersih (tanpa potongan komisi), dan kepatuhan perpajakan UMKM (PP 55/2022)', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3932),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              onPressed: _showTaxReportExportDialog,
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Ekspor CSV Pelaporan Pajak Resmi', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(child: _cleanStatTile('Total Omzet Bruto (DPP)', _formatRupiah(totalOmzet), 'Total Pendapatan Seluruh Kanal', isPositive: true, growth: '+24.5%')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Penerimaan Cash (Tunai)', _formatRupiah(totalCash), '32.7% Omzet • Kas Gerobak Lapangan')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Penerimaan QRIS (Non-Tunai)', _formatRupiah(totalQris), '67.3% Omzet • Rekening Bank Utama')),
            const SizedBox(width: 12),
            Expanded(child: _cleanStatTile('Laba Bersih Riil', _formatRupiah(netProfit), 'Margin 65.3% • Komisi Ditiadakan', isPositive: true, growth: '65.3%')),
          ],
        ),
        const SizedBox(height: 18),

        // Detail Komparasi Cash vs QRIS
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rincian Kanal Penerimaan: Cash (Tunai) vs QRIS (Non-Tunai)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
              const SizedBox(height: 6),
              const Text('Pemisahan dana kas fisik di gerobak dan transaksi digital otomatis rekening penampung:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. Arus Kas Tunai (Cash Lapangan)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E))),
                          const SizedBox(height: 8),
                          _buildFinanceRow('Total Kas Diterima Penjualan POS', _formatRupiah(totalCash), '100% Cash'),
                          _buildFinanceRow('Porsi terhadap Total Omzet Usaha', '32.7%', 'Tunai Fisik'),
                          _buildFinanceRow('Biaya Lapangan Terbayar Tunai (Es/Unit)', 'Rp 210.000', 'Beban Tunai'),
                          const Divider(height: 12, color: Color(0xFFFDE68A)),
                          _buildFinanceRow('Total Kas Fisik Siap Disetor ke Owner', _formatRupiah(totalCash - 210000), 'Rekonsiliasi Tutup Shift', isTotal: true, color: const Color(0xFF78350F)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('2. Penerimaan Non-Tunai (QRIS Digital)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E40AF))),
                          const SizedBox(height: 8),
                          _buildFinanceRow('QRIS Statis Lapak Gerobak (POS)', 'Rp 2.430.000', '41.5% QRIS'),
                          _buildFinanceRow('QRIS Dinamis Aplikasi Pre-Order', 'Rp 3.420.000', '58.5% QRIS'),
                          _buildFinanceRow('Biaya MDR QRIS (0.0% Bebas MDR)', 'Rp 0', 'Kebijakan BI'),
                          const Divider(height: 12, color: Color(0xFFBFDBFE)),
                          _buildFinanceRow('Total Dana Masuk Rekening Bank', _formatRupiah(totalQris), 'H+0 Settlement Otomatis', isTotal: true, color: const Color(0xFF1E3A8A)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kepatuhan Pajak Resmi (Tax Compliance)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
              const SizedBox(height: 6),
              const Text('Kalkulasi pajak resmi berdasarkan peraturan perpajakan Republik Indonesia untuk pelaporan SPT Masa:', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('1. PPh Final UMKM 0.5% (PP 55 Tahun 2022)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF065F46))),
                          const SizedBox(height: 8),
                          _buildFinanceRow('Dasar Pengenaan Pajak (DPP)', _formatRupiah(totalOmzet), 'Omzet Bruto'),
                          _buildFinanceRow('Tarif PPh Final UMKM', '0.5%', 'PP 55/2022'),
                          _buildFinanceRow('Kode Akun Pajak / Jenis Setoran', '411128 / 420', 'PPh Final UMKM'),
                          const Divider(height: 12, color: Color(0xFFA7F3D0)),
                          _buildFinanceRow('PPh Final Terutang', 'Rp 43.450', 'Disetor ke Kas Negara', isTotal: true, color: const Color(0xFF065F46)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('2. Opsi PB1 / Pajak Restoran 10% (Pemda)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                          const SizedBox(height: 8),
                          _buildFinanceRow('Dasar Pengenaan Pajak (DPP)', _formatRupiah(totalOmzet), 'Omzet Mamin'),
                          _buildFinanceRow('Tarif Pajak Barang & Jasa Tertentu', '10.0%', 'Perda Pemda'),
                          _buildFinanceRow('Status Ketetapan Bapenda', 'Tercatat / SPT Masa', 'Kompilasi e-SPTPD'),
                          const Divider(height: 12, color: Color(0xFFE5E7EB)),
                          _buildFinanceRow('PB1 10% Terutang (Jika Diterapkan)', 'Rp 869.000', 'Bapenda Daerah', isTotal: true, color: const Color(0xFF111827)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _showTaxReportExportDialog,
                  icon: const Icon(Icons.receipt_long, size: 16),
                  label: const Text('Buka Lembar Ekspor CSV Pajak'),
                ),
              ),
            ],
          ),
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
              TextField(decoration: const InputDecoration(labelText: 'Tarif PPh Final UMKM Resmi', border: OutlineInputBorder()), controller: TextEditingController(text: '0.5% (PP 55/2022)')),
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
  Widget _cleanStatTile(String label, String value, String subtext, {String? growth, bool isPositive = true, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE8ECEF)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12.5, color: Color(0xFF7E8B9B), fontWeight: FontWeight.w600)),
              if (icon != null)
                Icon(icon, size: 22, color: const Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B), letterSpacing: -0.5)),
          const SizedBox(height: 8),
          if (growth != null)
            Row(
              children: [
                Text(
                  growth,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? const Color(0xFF71C02B) : const Color(0xFFFF4747),
                  ),
                ),
                const SizedBox(width: 4),
                const Text('(30 days)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
              ],
            )
          else
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
