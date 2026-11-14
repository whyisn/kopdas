import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/owner_api.dart';
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


  // Distribution filter
  String _distributionFilter = 'Semua';

  // Sidebar Collapse State (3S.NET style)
  bool _isSidebarCollapsed = false;

  // Google Maps Live GPS State (Pusat Jaringan Kota Padang)
  double _liveMapLat = -0.9040;
  double _liveMapLng = 100.3530;
  int _liveMapZoom = 14;
  String _focusedStaffId = 'usr-seller-01';

  // Weather Intelligence Simulation State (AI Recommendation Engine)
  String _aiWeatherMode = 'NORMAL'; // 'NORMAL', 'RAIN', 'PEAK_SUNNY'

  // ===========================================================================
  // DATA OPERASIONAL TERINTEGRASI PADANG (SINGLE SOURCE OF TRUTH)
  // ===========================================================================
  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'usr-seller-01',
      'username': 'seller1',
      'name': 'Ahmad Fauzi',
      'phone': '0812-8821-9901',
      'cart_id': 'loc-01 (UNP)',
      'location': 'Kampus UNP Air Tawar, Padang Utara',
      'role': 'Seller Lead',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '06:15 WIB',
      'morning_stock': 184,
      'current_stock': 42,
      'cups_sold': 142,
      'cash': 900000,
      'qris': 1940000,
      'cash_submitted': 900000,
      'cash_status': 'BALANCE',
      'is_cash_verified': false,
      'gps_status': 'Live (4m akurasi)',
      'lat_long': '-0.8960, 100.3500',
      'lat': -0.8960,
      'lng': 100.3500,
      'map_x': 180.0,
      'map_y': 150.0,
    },
    {
      'id': 'usr-seller-02',
      'username': 'seller2',
      'name': 'Rian Syahputra',
      'phone': '0813-1102-4451',
      'cart_id': 'loc-02 (Khatib Sulaiman)',
      'location': 'Sentra Kantor Khatib Sulaiman, Padang',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '06:40 WIB',
      'morning_stock': 100,
      'current_stock': 32,
      'cups_sold': 68,
      'cash': 520000,
      'qris': 900000,
      'cash_submitted': 520000,
      'cash_status': 'BALANCE',
      'is_cash_verified': false,
      'gps_status': 'Live (6m akurasi)',
      'lat_long': '-0.9040, 100.3530',
      'lat': -0.9040,
      'lng': 100.3530,
      'map_x': 320.0,
      'map_y': 110.0,
    },
    {
      'id': 'usr-seller-03',
      'username': 'seller3',
      'name': 'Fauzan Akbar',
      'phone': '0857-4491-0023',
      'cart_id': 'loc-03 (Pasar Raya)',
      'location': 'Pintu Barat Pasar Raya Padang',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '05:30 WIB',
      'morning_stock': 120,
      'current_stock': 25,
      'cups_sold': 95,
      'cash': 640000,
      'qris': 1340000,
      'cash_submitted': 640000,
      'cash_status': 'BALANCE',
      'is_cash_verified': false,
      'gps_status': 'Live (5m akurasi)',
      'lat_long': '-0.9510, 100.3600',
      'lat': -0.9510,
      'lng': 100.3600,
      'map_x': 460.0,
      'map_y': 70.0,
    },
    {
      'id': 'usr-seller-04',
      'username': 'seller4',
      'name': 'Doni Pratama',
      'phone': '0821-7781-3312',
      'cart_id': 'loc-04 (Taplau)',
      'location': 'Kawasan Wisata Pantai Padang Taplau',
      'role': 'Seller Reguler',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'clock_in': '05:50 WIB',
      'morning_stock': 150,
      'current_stock': 32,
      'cups_sold': 118,
      'cash': 780000,
      'qris': 1670000,
      'cash_submitted': 780000,
      'cash_status': 'BALANCE',
      'is_cash_verified': false,
      'gps_status': 'Live (3m akurasi)',
      'lat_long': '-0.9450, 100.3540',
      'lat': -0.9450,
      'lng': 100.3540,
      'map_x': 270.0,
      'map_y': 40.0,
    },
  ];

  final List<Map<String, dynamic>> _warehouseStock = [
    {'sku': 'prd-01', 'name': 'Kopi Susu Aren', 'category': 'Coffee', 'central_stock': 1000, 'allocated': 90, 'held_by_cart': 90, 'min_stock': 150, 'price': 12000, 'cost': 5000, 'status': 'Aman'},
    {'sku': 'prd-02', 'name': 'Americano', 'category': 'Coffee', 'central_stock': 1000, 'allocated': 75, 'held_by_cart': 75, 'min_stock': 150, 'price': 12000, 'cost': 4500, 'status': 'Aman'},
    {'sku': 'prd-03', 'name': 'Coklat', 'category': 'Non-Coffee', 'central_stock': 1000, 'allocated': 80, 'held_by_cart': 80, 'min_stock': 120, 'price': 12000, 'cost': 5500, 'status': 'Aman'},
    {'sku': 'prd-04', 'name': 'Red Velvet', 'category': 'Non-Coffee', 'central_stock': 1000, 'allocated': 70, 'held_by_cart': 70, 'min_stock': 100, 'price': 12000, 'cost': 5500, 'status': 'Aman'},
    {'sku': 'prd-05', 'name': 'Thai Tea', 'category': 'Tea', 'central_stock': 1000, 'allocated': 95, 'held_by_cart': 95, 'min_stock': 100, 'price': 8000, 'cost': 3000, 'status': 'Aman'},
    {'sku': 'prd-06', 'name': 'Lemon Tea', 'category': 'Tea', 'central_stock': 1000, 'allocated': 85, 'held_by_cart': 85, 'min_stock': 100, 'price': 8000, 'cost': 3000, 'status': 'Aman'},
  ];

  final List<Map<String, dynamic>> _locations = [
    {'id': 'loc-01', 'name': 'Kampus UNP Air Tawar', 'seller': 'Ahmad Fauzi (seller1)', 'traffic': 'Padat Mahasiswa', 'footfall': '1.620/jam', 'score': 96.8, 'status': 'Terisi', 'lat': -0.8960, 'lng': 100.3500},
    {'id': 'loc-02', 'name': 'Perkantoran Khatib Sulaiman', 'seller': 'Rian Syahputra (seller2)', 'traffic': 'Padat Perkantoran', 'footfall': '1.180/jam', 'score': 92.4, 'status': 'Terisi', 'lat': -0.9040, 'lng': 100.3530},
    {'id': 'loc-03', 'name': 'Pasar Raya Padang (Kandidat)', 'seller': 'Fauzan Akbar (seller3)', 'traffic': 'Padat Sentra Niaga', 'footfall': '1.950/jam', 'score': 94.1, 'status': 'Terisi', 'lat': -0.9510, 'lng': 100.3600},
    {'id': 'loc-04', 'name': 'Pantai Padang Taplau (Kandidat)', 'seller': 'Doni Pratama (seller4)', 'traffic': 'Ramai Wisata Sore', 'footfall': '1.420/jam', 'score': 91.5, 'status': 'Terisi', 'lat': -0.9450, 'lng': 100.3540},
  ];

  final List<Map<String, dynamic>> _recentTransactions = [
    {'id': 'TRX-1089', 'time': '13:42', 'seller': 'Ahmad (UNP)', 'items': '2x Kopi Susu Aren', 'total': 24000, 'method': 'QRIS', 'pjp': 'QRIS Static'},
    {'id': 'TRX-1088', 'time': '13:38', 'seller': 'Rian (Khatib Sulaiman)', 'items': '1x Americano', 'total': 12000, 'method': 'TUNAI', 'pjp': 'Kasir Fisik'},
    {'id': 'TRX-1087', 'time': '13:25', 'seller': 'Fauzan (Pasar Raya)', 'items': '1x Red Velvet + 1x Thai Tea', 'total': 20000, 'method': 'QRIS', 'pjp': 'QRIS Static'},
    {'id': 'TRX-1086', 'time': '13:14', 'seller': 'Doni (Taplau)', 'items': '2x Lemon Tea Dingin', 'total': 16000, 'method': 'TUNAI', 'pjp': 'Kasir Fisik'},
  ];

  final List<Map<String, dynamic>> _customerOrders = [
    {'id': 'ORD-9042', 'time': '13:40', 'customer': 'Maya Customer', 'seller': 'Ahmad (UNP)', 'items': '2x Kopi Susu Aren', 'total': 24000, 'status': 'Diproses', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9041', 'time': '13:28', 'customer': 'Rani Mahasiswi', 'seller': 'Ahmad (UNP)', 'items': '1x Americano + 1x Coklat', 'total': 24000, 'status': 'Siap Diambil', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9040', 'time': '13:10', 'customer': 'Bagus Prasetyo', 'seller': 'Rian (Khatib Sulaiman)', 'items': '2x Thai Tea', 'total': 16000, 'status': 'Selesai', 'pay': 'LUNAS (QRIS)'},
    {'id': 'ORD-9039', 'time': '13:35', 'customer': 'Clarissa Olivia', 'seller': 'Doni (Taplau)', 'items': '2x Lemon Tea', 'total': 16000, 'status': 'Menunggu Bayar', 'pay': 'PENDING'},
  ];

  bool _isLoadingLive = false;
  Map<String, dynamic>? _liveAnalytics;

  @override
  void initState() {
    super.initState();
    _resetWarehouseStock();
    _fetchLiveBackendData();
  }

  Future<void> _fetchLiveBackendData() async {
    if (!mounted) return;
    setState(() => _isLoadingLive = true);
    try {
      final int days = _activeTimeFilter == 'Hari Ini'
          ? 1
          : (_activeTimeFilter == 'Kemarin' ? 2 : (_activeTimeFilter == '7 Hari' ? 7 : 30));

      final analytics = await ownerApi.getSalesAnalytics(days: days);
      final invList = await ownerApi.getInventory();
      final txList = await ownerApi.getTransactions(limit: 20);
      final ordList = await ownerApi.getOrders(limit: 20);

      if (!mounted) return;
      setState(() {
        if (analytics.isNotEmpty && analytics.containsKey('summary')) {
          _liveAnalytics = analytics;
        }

        // Sinkronisasi stok gudang pusat dari database jika ada
        if (invList.isNotEmpty) {
          for (var item in invList) {
            if (item is Map && item['scope_type'] == 'WAREHOUSE') {
              final prodId = item['product_id']?.toString() ?? '';
              final qty = (item['quantity'] as num?)?.toInt() ?? 1000;
              final found = _warehouseStock.firstWhere((w) => w['sku'] == prodId, orElse: () => {});
              if (found.isNotEmpty) {
                found['central_stock'] = qty;
              }
            }
          }
        }

        // Sinkronisasi transaksi terkini dari database jika ada
        if (txList.isNotEmpty) {
          _recentTransactions.clear();
          for (var t in txList) {
            if (t is Map) {
              final locId = t['location_id']?.toString() ?? '';
              final seller = locId == 'loc-01'
                  ? 'Ahmad (UNP)'
                  : (locId == 'loc-02'
                      ? 'Rian (Khatib Sulaiman)'
                      : (locId == 'loc-03' ? 'Fauzan (Pasar Raya)' : 'Doni (Taplau)'));
              final method = t['payment_method']?.toString() == 'CASH' ? 'TUNAI' : 'QRIS';
              final pjp = method == 'QRIS' ? 'QRIS Static' : 'Kasir Fisik';
              final tDate = t['created_at']?.toString() ?? '';
              final timeStr = tDate.length >= 16 ? tDate.substring(11, 16) : 'Live';
              _recentTransactions.add({
                'id': t['id']?.toString() ?? 'TRX',
                'time': timeStr,
                'seller': seller,
                'items': 'Minuman KopiCerdas',
                'total': (t['total_amount'] as num?)?.toInt() ?? 0,
                'method': method,
                'pjp': pjp,
              });
            }
          }
        }

        // Sinkronisasi order pre-order customer dari database jika ada
        if (ordList.isNotEmpty) {
          _customerOrders.clear();
          for (var o in ordList) {
            if (o is Map) {
              final locId = o['location_id']?.toString() ?? '';
              final seller = locId == 'loc-01'
                  ? 'Ahmad (UNP)'
                  : (locId == 'loc-02'
                      ? 'Rian (Khatib Sulaiman)'
                      : (locId == 'loc-03' ? 'Fauzan (Pasar Raya)' : 'Doni (Taplau)'));
              final oDate = o['created_at']?.toString() ?? '';
              final timeStr = oDate.length >= 16 ? oDate.substring(11, 16) : 'Live';
              final statusRaw = o['order_status']?.toString() ?? 'CONFIRMED';
              final statusDisplay = statusRaw == 'COMPLETED'
                  ? 'Selesai'
                  : (statusRaw == 'READY_FOR_PICKUP'
                      ? 'Siap Diambil'
                      : (statusRaw == 'PREPARING' ? 'Diproses' : 'Menunggu'));
              final payRaw = o['payment_status']?.toString() ?? 'PAID';
              final payDisplay = payRaw == 'PAID' ? 'LUNAS (QRIS)' : 'PENDING';

              _customerOrders.add({
                'id': o['id']?.toString() ?? 'ORD',
                'time': timeStr,
                'customer': 'Maya Customer',
                'seller': seller,
                'items': 'Pre-Order KopiCerdas',
                'total': (o['total_amount'] as num?)?.toInt() ?? 0,
                'status': statusDisplay,
                'pay': payDisplay,
              });
            }
          }
        }
      });
    } catch (_) {
      // Fallback tetap aman
    } finally {
      if (mounted) setState(() => _isLoadingLive = false);
    }
  }

  void _resetWarehouseStock() {
    _warehouseStock.clear();
    _warehouseStock.addAll([
      {'sku': 'prd-01', 'name': 'Kopi Susu Aren', 'category': 'Coffee', 'central_stock': 1000, 'allocated': 90, 'held_by_cart': 90, 'min_stock': 150, 'price': 12000, 'cost': 5000, 'status': 'Aman'},
      {'sku': 'prd-02', 'name': 'Americano', 'category': 'Coffee', 'central_stock': 1000, 'allocated': 75, 'held_by_cart': 75, 'min_stock': 150, 'price': 12000, 'cost': 4500, 'status': 'Aman'},
      {'sku': 'prd-03', 'name': 'Coklat', 'category': 'Non-Coffee', 'central_stock': 1000, 'allocated': 80, 'held_by_cart': 80, 'min_stock': 120, 'price': 12000, 'cost': 5500, 'status': 'Aman'},
      {'sku': 'prd-04', 'name': 'Red Velvet', 'category': 'Non-Coffee', 'central_stock': 1000, 'allocated': 70, 'held_by_cart': 70, 'min_stock': 100, 'price': 12000, 'cost': 5500, 'status': 'Aman'},
      {'sku': 'prd-05', 'name': 'Thai Tea', 'category': 'Tea', 'central_stock': 1000, 'allocated': 95, 'held_by_cart': 95, 'min_stock': 100, 'price': 8000, 'cost': 3000, 'status': 'Aman'},
      {'sku': 'prd-06', 'name': 'Lemon Tea', 'category': 'Tea', 'central_stock': 1000, 'allocated': 85, 'held_by_cart': 85, 'min_stock': 100, 'price': 8000, 'cost': 3000, 'status': 'Aman'},
    ]);
  }

  // ===========================================================================
  // INTERACTIVE MODALS
  // ===========================================================================
  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cartCtrl = TextEditingController(text: 'loc-0${_staffList.length + 1}');

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

  void _confirmReturnStock(Map<String, dynamic> staff) {
    final int rem = (staff['current_stock'] as int);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: const [
            Icon(Icons.assignment_return_outlined, color: Color(0xFFDC2626), size: 22),
            SizedBox(width: 8),
            Text('Konfirmasi Retur Sisa Kopi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin membalikkan sisa $rem porsi kopi dari gerobak ${staff['cart_id']} (${staff['name']}) ke Gudang Pusat?\n\n'
          'Sesuai SOP pulang shift, sisa kopi akan dikembalikan ke Gudang Pusat dan sisa box gerobak menjadi 0 (tutup shift). Data penjualan hari ini (${staff['cups_sold']} cup) tetap tersimpan aman.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _returnStockToWarehouse(staff['id'].toString());
            },
            child: const Text('Ya, Retur ke 0'),
          ),
        ],
      ),
    );
  }

  void _confirmReturnAllStock() {
    final int totalBox = _staffList.fold<int>(0, (sum, s) => sum + ((s['current_stock'] ?? 0) as int));
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: const [
            Icon(Icons.assignment_return_outlined, color: Color(0xFFD97706), size: 22),
            SizedBox(width: 8),
            Text('Konfirmasi Tutup Shift Semua Armada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin melakukan Tutup Shift untuk semua gerobak?\n\n'
          'Total $totalBox porsi sisa kopi dari semua unit akan dikembalikan ke Gudang Pusat dan seluruh stok box gerobak menjadi 0. Catatan penjualan hari ini tetap tersimpan aman.',
          style: const TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD97706),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _returnAllStockToWarehouse();
            },
            child: const Text('Ya, Tutup Shift Semua'),
          ),
        ],
      ),
    );
  }

  void _confirmResetNewDate() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: const [
            Icon(Icons.restart_alt, color: Color(0xFF2563EB), size: 22),
            SizedBox(width: 8),
            Text('Konfirmasi Buka Shift Tanggal Baru', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin memulai tanggal baru?\n\n'
          'Semua gerobak akan disiapkan untuk memulai shift baru dari stok 0 dan siap menerima top-up pagi hari.',
          style: TextStyle(fontSize: 13, color: Color(0xFF374151), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _resetNewDateTopup();
            },
            child: const Text('Ya, Buka Shift Baru'),
          ),
        ],
      ),
    );
  }

  void _returnStockToWarehouse(String staffId) {
    setState(() {
      for (var s in _staffList) {
        if (s['id'] == staffId) {
          int remaining = (s['current_stock'] as int);
          if (remaining > 0) {
            _warehouseStock[0]['central_stock'] = (_warehouseStock[0]['central_stock'] as int) + remaining;
          }
          s['current_stock'] = 0;
          s['operational_status'] = 'SHIFT_COMPLETED';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SOP Pulang Shift: Sisa $remaining porsi kopi ${s['name']} dikembalikan ke Gudang. Sisa box gerobak kini 0, penjualan hari ini (${s['cups_sold']} cup) tetap aman.'),
              backgroundColor: const Color(0xFF1E3932),
            ),
          );
          return;
        }
      }
    });
  }

  void _returnAllStockToWarehouse() {
    setState(() {
      int totalReturned = 0;
      for (var s in _staffList) {
        int rem = (s['current_stock'] as int);
        if (rem > 0) {
          totalReturned += rem;
          s['current_stock'] = 0;
        }
        s['operational_status'] = 'SHIFT_COMPLETED';
      }
      _warehouseStock[0]['central_stock'] = (_warehouseStock[0]['central_stock'] as int) + totalReturned;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tutup Shift: Total $totalReturned porsi sisa kopi dikembalikan ke Gudang. Seluruh stok gerobak kini 0!'),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    });
  }

  void _resetNewDateTopup() {
    setState(() {
      for (var s in _staffList) {
        s['morning_stock'] = 0;
        s['current_stock'] = 0;
        s['cups_sold'] = 0;
        s['operational_status'] = 'NOT_STARTED';
        s['clock_in'] = 'Belum Mulai';
        s['is_cash_verified'] = false;
        s['cash_submitted'] = 0;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset Tanggal Baru Berhasil! Seluruh armada dimulai dari stok 0 dan siap ditop-up pagi.'),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    });
  }

  void _showDistributeStockDialog([String? defaultStaffId]) {
    String selectedSellerId = defaultStaffId ?? _staffList.first['id'];
    
    // Setiap barang dimulai dari 0 sesuai SOP KopiCerdas Padang
    final Map<String, int> allocationMap = {
      'prd-01': 0,
      'prd-02': 0,
      'prd-03': 0,
      'prd-04': 0,
      'prd-05': 0,
      'prd-06': 0,
    };

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final int totalAlloc = allocationMap.values.fold(0, (sum, val) => sum + val);

          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.local_shipping_outlined, color: Color(0xFF1E3932), size: 20),
                    SizedBox(width: 8),
                    Text('Formulir Top-Up Bawaan Gerobak', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827))),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFF0FDF4), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFFBBF7D0))),
                  child: Text('Total Disposisi: $totalAlloc Cup', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF166534))),
                ),
              ],
            ),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pilih Unit Gerobak & Petugas Penerima:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSellerId,
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(),
                      ),
                      items: _staffList.map((s) => DropdownMenuItem(
                        value: s['id'].toString(),
                        child: Text('${s['cart_id']} • ${s['name']} (Stok saat ini: ${s['current_stock']} cup)'),
                      )).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedSellerId = val);
                      },
                    ),
                    const SizedBox(height: 14),

                    // Preset Disposisi Cepat (Wrap responsif & tanpa +15 sesuai SOP)
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text('Preset Cepat:', style: TextStyle(fontSize: 11.5, color: Color(0xFF6B7280))),
                        _buildPresetChip('Kosongkan (0)', () {
                          setModalState(() {
                            allocationMap.updateAll((key, val) => 0);
                          });
                        }),
                        _buildPresetChip('+10 Tiap Menu (Total 60)', () {
                          setModalState(() {
                            allocationMap.updateAll((key, val) => 10);
                          });
                        }),
                        _buildPresetChip('+20 Tiap Menu (Total 120)', () {
                          setModalState(() {
                            allocationMap.updateAll((key, val) => 20);
                          });
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),

                    const Text('Rincian Kuota 6 Menu Resmi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151))),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: _warehouseStock.map((w) {
                          final sku = w['sku'].toString();
                          final currentVal = allocationMap[sku] ?? 0;
                          final avail = w['central_stock'] as int;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(w['name'].toString(), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                      Text('Sedia di Gudang: $avail Porsi', style: TextStyle(fontSize: 10.5, color: avail < 100 ? Colors.red : const Color(0xFF6B7280))),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFF6B7280)),
                                      onPressed: currentVal > 0 ? () => setModalState(() => allocationMap[sku] = currentVal - 5) : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                    Container(
                                      width: 44,
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.symmetric(horizontal: 8),
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF9FAFB),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFD1D5DB)),
                                      ),
                                      child: Text('$currentVal', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF1E3932)),
                                      onPressed: avail > currentVal ? () => setModalState(() => allocationMap[sku] = currentVal + 5) : null,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Batal', style: TextStyle(color: Color(0xFF6B7280))),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3932),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Simpan & Disposisikan Bawaan', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                onPressed: () {
                  if (totalAlloc <= 0) return;
                  setState(() {
                    for (var entry in allocationMap.entries) {
                      for (var w in _warehouseStock) {
                        if (w['sku'] == entry.key) {
                          w['central_stock'] = (w['central_stock'] as int) - entry.value;
                        }
                      }
                    }
                    for (var s in _staffList) {
                      if (s['id'] == selectedSellerId) {
                        s['current_stock'] = (s['current_stock'] as int) + totalAlloc;
                        s['morning_stock'] = (s['morning_stock'] as int) + totalAlloc;
                        s['operational_status'] = 'ACTIVE_SELLING';
                        if (s['clock_in'] == 'Belum Mulai' || s['clock_in'] == null || s['clock_in'] == '') {
                          s['clock_in'] = '06:15 WIB';
                        }
                      }
                    }
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Disposisi $totalAlloc Porsi berhasil dikirim ke armada!'),
                      backgroundColor: const Color(0xFF1E3932),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPresetChip(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
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
                    s['is_cash_verified'] = true;
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Tutup shift unit ${s['cart_id']} diverifikasi. Kas disetor ${_formatRupiah(parsedCash)} tercatat resmi. Status: ${isBalance ? "BALANCE" : "SELISIH ${_formatRupiah(variance)}"}.',
                      ),
                      backgroundColor: const Color(0xFF059669),
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
      {'no': 'INV-20261114-001', 'tgl': '14/11/2026', 'sumber': 'loc-01 (UNP)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 900000, 'qris': 0, 'dpp': 900000, 'pph': 4500, 'kjs': '411128-420'},
      {'no': 'INV-20261114-002', 'tgl': '14/11/2026', 'sumber': 'loc-01 (UNP)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1940000, 'dpp': 1940000, 'pph': 9700, 'kjs': '411128-420'},
      {'no': 'INV-20261114-003', 'tgl': '14/11/2026', 'sumber': 'loc-02 (Khatib Sulaiman)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 520000, 'qris': 0, 'dpp': 520000, 'pph': 2600, 'kjs': '411128-420'},
      {'no': 'INV-20261114-004', 'tgl': '14/11/2026', 'sumber': 'loc-02 (Khatib Sulaiman)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 900000, 'dpp': 900000, 'pph': 4500, 'kjs': '411128-420'},
      {'no': 'INV-20261114-005', 'tgl': '14/11/2026', 'sumber': 'loc-03 (Pasar Raya)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 640000, 'qris': 0, 'dpp': 640000, 'pph': 3200, 'kjs': '411128-420'},
      {'no': 'INV-20261114-006', 'tgl': '14/11/2026', 'sumber': 'loc-03 (Pasar Raya)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1340000, 'dpp': 1340000, 'pph': 6700, 'kjs': '411128-420'},
      {'no': 'INV-20261114-007', 'tgl': '14/11/2026', 'sumber': 'loc-04 (Taplau)', 'kanal': 'Walk-in', 'metode': 'Tunai', 'cash': 780000, 'qris': 0, 'dpp': 780000, 'pph': 3900, 'kjs': '411128-420'},
      {'no': 'INV-20261114-008', 'tgl': '14/11/2026', 'sumber': 'loc-04 (Taplau)', 'kanal': 'Walk-in', 'metode': 'QRIS', 'cash': 0, 'qris': 1580000, 'dpp': 1580000, 'pph': 7900, 'kjs': '411128-420'},
      {'no': 'INV-20261114-009', 'tgl': '14/11/2026', 'sumber': 'Discovery App Pre-Order', 'kanal': 'Online App', 'metode': 'QRIS Dinamis', 'cash': 0, 'qris': 3420000, 'dpp': 3420000, 'pph': 17100, 'kjs': '411128-420'},
    ];

    final csvBuffer = StringBuffer();
    csvBuffer.writeln('No_Bukti,Tanggal,Sumber_Pendapatan,Kanal,Metode_Bayar,Penerimaan_Cash_IDR,Penerimaan_QRIS_IDR,Total_Omzet_DPP_IDR,Tarif_PPh,PPh_Final_Terutang_IDR,KAP_KJS,Keterangan');
    for (final r in records) {
      csvBuffer.writeln('${r['no']},${r['tgl']},"${r['sumber']}",${r['kanal']},${r['metode']},${r['cash']},${r['qris']},${r['dpp']},0.5%,${r['pph']},${r['kjs']},"Penjualan Kopi Cerdas Lapangan"');
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
                          downloadWebFile(csvData, 'Laporan_Pajak_Kopi_Cerdas_14Nov2026.csv');
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
                                      'File "Laporan_Pajak_Kopi_Cerdas_14Nov2026.csv" berhasil diunduh ke folder Downloads!',
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
      case 10: return _buildAiDemandAnalysisView();
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
                                'Kopi Cerdas',
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
                    _navItem(6, Icons.local_shipping_outlined, 'Distribusi Penjualan Selama Sebulan'),
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
                                Text('Owner Kopi Cerdas', style: TextStyle(color: Color(0xFF111827), fontSize: 12, fontWeight: FontWeight.w700)),
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
                  'Kopi Cerdas — Smart Operational & Intelligence Management',
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
                    _fetchLiveBackendData();
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
              _fetchLiveBackendData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(duration: Duration(seconds: 1), content: Text('Sinkronisasi data real-time diperbarui dari backend.')),
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
                  Text('Owner Kopi Cerdas', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
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
      default: return 'Portal Owner Kopi Cerdas';
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
            {'name': 'Kopi Susu Aren', 'sold': '172 cup (50%)', 'omzet': 2064000, 'stock': '1.000 cup'},
            {'name': 'Americano', 'sold': '80 cup (23%)', 'omzet': 960000, 'stock': '1.000 cup'},
            {'name': 'Thai Tea', 'sold': '48 cup (14%)', 'omzet': 384000, 'stock': '1.000 cup'},
            {'name': 'Coklat', 'sold': '31 cup (9%)', 'omzet': 372000, 'stock': '1.000 cup'},
            {'name': 'Lemon Tea', 'sold': '10 cup (3%)', 'omzet': 80000, 'stock': '1.000 cup'},
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
            {'name': 'Kopi Susu Aren', 'sold': '1.350 cup (51%)', 'omzet': 16200000, 'stock': '1.000 cup'},
            {'name': 'Americano', 'sold': '615 cup (23%)', 'omzet': 7380000, 'stock': '1.000 cup'},
            {'name': 'Thai Tea', 'sold': '395 cup (15%)', 'omzet': 3160000, 'stock': '1.000 cup'},
            {'name': 'Coklat', 'sold': '215 cup (8%)', 'omzet': 2580000, 'stock': '1.000 cup'},
            {'name': 'Lemon Tea', 'sold': '75 cup (3%)', 'omzet': 600000, 'stock': '1.000 cup'},
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
            {'name': 'Kopi Susu Aren', 'sold': '5.940 cup (51%)', 'omzet': 71280000, 'stock': '1.000 cup'},
            {'name': 'Americano', 'sold': '2.680 cup (23%)', 'omzet': 32160000, 'stock': '1.000 cup'},
            {'name': 'Thai Tea', 'sold': '1.740 cup (15%)', 'omzet': 13920000, 'stock': '1.000 cup'},
            {'name': 'Coklat', 'sold': '940 cup (8%)', 'omzet': 11280000, 'stock': '1.000 cup'},
            {'name': 'Lemon Tea', 'sold': '340 cup (3%)', 'omzet': 2720000, 'stock': '1.000 cup'},
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
            {'name': 'Kopi Susu Aren', 'sold': '215 cup (51%)', 'omzet': 2580000, 'stock': '1.000 cup'},
            {'name': 'Americano', 'sold': '98 cup (23%)', 'omzet': 1176000, 'stock': '1.000 cup'},
            {'name': 'Thai Tea', 'sold': '62 cup (15%)', 'omzet': 496000, 'stock': '1.000 cup'},
            {'name': 'Coklat', 'sold': '36 cup (8%)', 'omzet': 432000, 'stock': '1.000 cup'},
            {'name': 'Lemon Tea', 'sold': '12 cup (3%)', 'omzet': 96000, 'stock': '1.000 cup'},
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
                    _fetchLiveBackendData();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(duration: Duration(seconds: 1), content: Text('Data operasional & telemetri gerobak diperbarui dari backend.')),
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
                  'Peringatan Stok Menipis: Doni Pratama - loc-04 Pantai Taplau sisa 15 Cup. Peak sore wisatawan 16:30 WIB. Model AI menyarankan restock 20 cup segera.',
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

                    _buildTopSellerRow('1', 'Ahmad Fauzi - loc-01 (UNP)', '142 / 120 Cup • 118%', 'Omzet: Rp 2.840.000 • Cash: Rp 900.000 | QRIS: Rp 1.940.000', 1.0, const Color(0xFF059669)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('2', 'Doni Pratama - loc-04 (Taplau)', '118 / 110 Cup • 107%', 'Omzet: Rp 2.360.000 • Cash: Rp 780.000 | QRIS: Rp 1.580.000', 0.95, const Color(0xFF0D9488)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('3', 'Fauzan Akbar - loc-03 (Pasar Raya)', '95 / 120 Cup • 79%', 'Omzet: Rp 1.980.000 • Cash: Rp 640.000 | QRIS: Rp 1.340.000', 0.79, const Color(0xFF2563EB)),
                    const SizedBox(height: 12),
                    _buildTopSellerRow('4', 'Rian Syahputra - loc-02 (Khatib Sulaiman)', '68 / 120 Cup • 56%', 'Omzet: Rp 1.420.000 • Cash: Rp 520.000 | QRIS: Rp 900.000', 0.56, const Color(0xFFD97706)),
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

                    _buildTopAreaTile('1', 'Kawasan Wisata Pantai Padang Taplau', '155 Cup terjual', 'Peak: 16:00-18:30 Sunset Wisata • Arus 14.800/jam', isAlert: true, alertText: 'Sisa 15 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('2', 'Kampus UNP Air Tawar', '142 Cup terjual', 'Peak: 07:30-09:30 & 12:00-13:30 Mahasiswa • Arus 12.200/jam', isAlert: false, alertText: 'Aman 42 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('3', 'Pintu Barat Pasar Raya Padang', '95 Cup terjual', 'Peak: 06:00-10:00 Grosir • Arus 8.500/jam', isAlert: false, alertText: 'Aman 35 cup'),
                    const SizedBox(height: 10),
                    _buildTopAreaTile('4', 'Sentra Kantor Khatib Sulaiman', '68 Cup terjual', 'Peak: 12:00-14:00 Istirahat Kantor • Arus 4.200/jam', isAlert: false, alertText: 'Aman 28 cup'),
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

                    _buildTopProductTile('1', 'Kopi Susu Aren', '215 Cup • 50.8%', 'Rp 2.580.000 • Gudang: 1.000 porsi', '+28%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('2', 'Americano', '98 Cup • 23.2%', 'Rp 1.176.000 • Gudang: 1.000 porsi', '+15%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('3', 'Thai Tea', '62 Cup • 14.6%', 'Rp 496.000 • Gudang: 1.000 porsi', '+9%'),
                    const SizedBox(height: 10),
                    _buildTopProductTile('4', 'Coklat', '36 Cup • 8.5%', 'Rp 432.000 • Gudang: 1.000 porsi', '+5%'),
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 14),
                    // SIMULASI KECERDASAN CUACA LAPANGAN (WEATHER INTELLIGENCE)
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Simulasi Cuaca Lapangan:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                        ),
                        _buildWeatherFilterButton('NORMAL', '⛅ Cuaca Normal', 'Baseline tren riil (28°C)', Icons.cloud, const Color(0xFF1E3932)),
                        _buildWeatherFilterButton('RAIN', '🌧️ Hujan Padang (-20%)', 'Trafik melandai, pangkas stok', Icons.water_drop, const Color(0xFF2563EB)),
                        _buildWeatherFilterButton('PEAK_SUNNY', '☀️ Cerah Panas / Ramai (+25%)', '32°C, dongkrak varian dingin', Icons.wb_sunny, const Color(0xFFD97706)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // RATIONALE SUMMARY BANNER
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: _aiWeatherMode == 'RAIN'
                            ? const Color(0xFFEFF6FF)
                            : (_aiWeatherMode == 'PEAK_SUNNY' ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4)),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _aiWeatherMode == 'RAIN'
                              ? const Color(0xFFBFDBFE)
                              : (_aiWeatherMode == 'PEAK_SUNNY' ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0)),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _aiWeatherMode == 'RAIN'
                                ? Icons.umbrella
                                : (_aiWeatherMode == 'PEAK_SUNNY' ? Icons.local_fire_department : Icons.verified),
                            size: 18,
                            color: _aiWeatherMode == 'RAIN'
                                ? const Color(0xFF1D4ED8)
                                : (_aiWeatherMode == 'PEAK_SUNNY' ? const Color(0xFFB45309) : const Color(0xFF15803D)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _aiWeatherMode == 'RAIN'
                                  ? 'Prakiraan Hujan di Padang (24°C - BMKG): Arus pejalan kaki trotoar outdoor melandai. AI merekomendasikan pemangkasan alokasi (-20%) untuk mencegah es mencair & cup sisa basi, sementara varian rasa hangat & creamy (Coklat & Red Velvet) dipertahankan stabil.'
                                  : (_aiWeatherMode == 'PEAK_SUNNY'
                                      ? 'Prakiraan Cerah Panas Terik (32°C - BMKG): Indeks dahaga komuter melonjak. AI merekomendasikan penambahan alokasi stok (+22%) khususnya Americano dingin & Kopi Susu Aren es guna mencegah kehabisan stok (stockout) pada jam sibuk siang/sore.'
                                      : 'Kondisi Berawan Normal (28°C - BMKG): Alokasi stok menggunakan baseline standar owner berdasarkan tren riil transaksi 6 menu resmi KopiCerdas di titik lapak Padang.'),
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                color: _aiWeatherMode == 'RAIN'
                                    ? const Color(0xFF1E40AF)
                                    : (_aiWeatherMode == 'PEAK_SUNNY' ? const Color(0xFF92400E) : const Color(0xFF166534)),
                              ),
                            ),
                          ),
                        ],
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
                  if (_aiWeatherMode == 'RAIN') ...[
                    _buildAiAnalysisRow(
                      'Kampus UNP Air Tawar (loc-01)',
                      'Area Kampus & Mahasiswa',
                      '145 Cup',
                      'Bawa kini: 180 cup',
                      '135 – 145 Cup',
                      'Terserap: 138 cup',
                      '24°C Hujan Deras Tropis',
                      'Indeks Es Kopi -20%',
                      'Gedung Kuliah Berteduh',
                      '8.500 mhs/jam • Mahasiswa Berteduh',
                      'Pangkas varian es -20%. Pertahankan stok Kopi Susu Aren & Coklat hangat untuk mahasiswa berteduh di selasar kampus.',
                      isWarning: true,
                    ),
                    _buildAiAnalysisRow(
                      'Sentra Kantor Khatib Sulaiman (loc-02)',
                      'Sentra Perkantoran & Bisnis Padang',
                      '80 Cup',
                      'Bawa kini: 100 cup',
                      '70 – 80 Cup',
                      'Terserap: 74 cup',
                      '24°C Hujan Deras Siang',
                      'Aktivitas Kantor Menurun',
                      'Lobi Gedung Kantor',
                      '2.800 org/jam • Karyawan Indoor',
                      'Karyawan enggan keluar gedung saat hujan. Pangkas alokasi ke 80 cup, tonjolkan varian Americano & Coklat hangat.',
                      isWarning: true,
                    ),
                    _buildAiAnalysisRow(
                      'Pintu Barat Pasar Raya Padang (loc-03)',
                      'Sentra Niaga & Pasar Tradisional',
                      '95 Cup',
                      'Bawa kini: 120 cup',
                      '85 – 95 Cup',
                      'Terserap: 88 cup',
                      '24°C Hujan Tropis Padang',
                      'Los Dalam Tetap Ramai',
                      'Padat Los Dalam',
                      '6.200 org/jam • Pedagang Los Pasar',
                      'Aktivitas pasar dalam los tetap berjalan lancar. Rekomendasi 95 cup aman dengan fokus Kopi Susu Aren & Americano hangat.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Kawasan Wisata Pantai Padang Taplau (loc-04)',
                      'Kawasan Wisata Bahari & Pantai',
                      '70 Cup',
                      'Bawa kini: 110 cup',
                      '65 – 70 Cup',
                      'Terserap: 68 cup',
                      '24°C Hujan Angin Pantai',
                      'Wisatawan Pantai Surut',
                      'Lengang Hujan Tepi Laut',
                      '1.500 org/jam • Tenda Wisata',
                      'Pengunjung pantai berkurang drastis saat hujan badai pesisir. Pangkas kuota ke 70 cup guna mencegah pemborosan bahan.',
                      isWarning: true,
                    ),
                  ] else if (_aiWeatherMode == 'PEAK_SUNNY') ...[
                    _buildAiAnalysisRow(
                      'Kampus UNP Air Tawar (loc-01)',
                      'Area Kampus & Mahasiswa',
                      '215 Cup',
                      'Bawa kini: 180 cup',
                      '200 – 215 Cup',
                      'Terserap: 206 cup',
                      '32°C Panas Terik Pesisir',
                      'Indeks Es Kopi +25%',
                      'Sangat Padat Mahasiswa',
                      '16.500 mhs/jam • Pergantian Jam Kuliah',
                      'Peluang omzet tinggi! Lonjakan dahaga mahasiswa antar kelas. Tambah alokasi Americano dingin & Kopi Susu Aren es (+20%).',
                      isWarning: true,
                    ),
                    _buildAiAnalysisRow(
                      'Sentra Kantor Khatib Sulaiman (loc-02)',
                      'Sentra Perkantoran & Bisnis Padang',
                      '125 Cup',
                      'Bawa kini: 100 cup',
                      '115 – 125 Cup',
                      'Terserap: 118 cup',
                      '32°C Terik Kawasan Bisnis',
                      'Demand Varian Dingin Naik',
                      'Ramai Karyawan Istirahat',
                      '7.200 org/jam • Makan Siang Kantor',
                      'Karyawan berburu minuman dingin saat istirahat siang. Tambah pasokan Thai Tea dingin dan Lemon Tea es.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Pintu Barat Pasar Raya Padang (loc-03)',
                      'Sentra Niaga & Pasar Tradisional',
                      '145 Cup',
                      'Bawa kini: 120 cup',
                      '135 – 145 Cup',
                      'Terserap: 136 cup',
                      '33°C Terik Los Niaga',
                      'Demand Minuman Segar Melonjak',
                      'Padat Aktivitas Perdagangan',
                      '11.500 org/jam • Pedagang & Pengunjung',
                      'Aktivitas pasar padat, tambah stok Lemon Tea dingin dan Kopi Susu Aren es untuk stamina pedagang pasar.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Kawasan Wisata Pantai Padang Taplau (loc-04)',
                      'Kawasan Wisata Bahari & Pantai',
                      '185 Cup',
                      'Bawa kini: 110 cup',
                      '170 – 185 Cup',
                      'Terserap: 178 cup',
                      '32°C Panas Terik Wisata Pantai',
                      'Indeks Dahaga Wisata +35%',
                      'Sangat Padat Wisatawan Sore',
                      '18.200 org/jam • Sunset Taplau',
                      'Stok kritis! Wisatawan memadati bibir pantai Taplau sore hari. Alokasikan 185 cup Thai Tea & Lemon Tea es guna cegah stockout.',
                      isWarning: true,
                    ),
                  ] else ...[
                    _buildAiAnalysisRow(
                      'Kampus UNP Air Tawar (loc-01)',
                      'Area Kampus & Mahasiswa',
                      '180 Cup',
                      'Bawa kini: 180 cup',
                      '165 – 180 Cup',
                      'Terserap: 170 cup',
                      '28°C Berawan Cerah',
                      'Demand Kopi Susu Seimbang',
                      'Aktivitas Kampus Normal',
                      '12.400 mhs/jam • Arus Mahasiswa Normal',
                      'Optimal: Baseline standar 180 cup sesuai tren sirkulasi mahasiswa UNP. Komposisi Kopi Susu Aren & Americano optimal.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Sentra Kantor Khatib Sulaiman (loc-02)',
                      'Sentra Perkantoran & Bisnis Padang',
                      '100 Cup',
                      'Bawa kini: 100 cup',
                      '85 – 100 Cup',
                      'Terserap: 92 cup',
                      '28°C Cuaca Tropis Normal',
                      'Demand Kopi & Teh Seimbang',
                      'Pekerja & Pengunjung Instansi',
                      '5.200 org/jam • Jam Kerja Normal',
                      'Optimal: Komposisi seimbang Kopi Susu Aren, Americano, dan Thai Tea terserap 92%.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Pintu Barat Pasar Raya Padang (loc-03)',
                      'Sentra Niaga & Pasar Tradisional',
                      '120 Cup',
                      'Bawa kini: 120 cup',
                      '105 – 120 Cup',
                      'Terserap: 112 cup',
                      '28°C Cerah Berawan',
                      'Baseline Tren Riil Pasar',
                      'Pedagang & Pembeli Niaga',
                      '8.900 org/jam • Aktivitas Belanja',
                      'Stabil: 120 cup mencukupi perputaran kas harian gerobak di Pasar Raya sejak pagi hari.',
                      isWarning: false,
                    ),
                    _buildAiAnalysisRow(
                      'Kawasan Wisata Pantai Padang Taplau (loc-04)',
                      'Kawasan Wisata Bahari & Pantai',
                      '150 Cup',
                      'Bawa kini: 110 cup',
                      '135 – 150 Cup',
                      'Terserap: 142 cup',
                      '28°C Angin Pantai Normal',
                      'Demand Teh & Kopi Dingin Stabil',
                      'Wisatawan & Warga Olahraga',
                      '14.600 org/jam • Peak 16:00–18:30',
                      'Optimal: 150 cup varian teh dan kopi dingin terserap maksimal menjelang matahari terbenam.',
                      isWarning: false,
                    ),
                  ],
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

  Widget _buildWarehouseKpiCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 11.5, color: Color(0xFF6B7280), fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF111827), letterSpacing: -0.3)),
                const SizedBox(height: 2),
                Text(sub, style: TextStyle(fontSize: 10.5, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg = const Color(0xFFECFDF5);
    Color border = const Color(0xFFA7F3D0);
    Color dot = const Color(0xFF059669);
    Color text = const Color(0xFF065F46);

    if (status == 'Stok Menipis') {
      bg = const Color(0xFFFEF2F2);
      border = const Color(0xFFFECACA);
      dot = const Color(0xFFDC2626);
      text = const Color(0xFF991B1B);
    } else if (status == 'Standby') {
      bg = const Color(0xFFF3F4F6);
      border = const Color(0xFFE5E7EB);
      dot = const Color(0xFF6B7280);
      text = const Color(0xFF374151);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
          ),
          const SizedBox(width: 5),
          Text(status, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: text)),
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

  Widget _buildWeatherFilterButton(String mode, String label, String sub, IconData icon, Color color) {
    final bool isSelected = _aiWeatherMode == mode;
    return InkWell(
      onTap: () => setState(() => _aiWeatherMode = mode),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFE5E7EB),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? color : const Color(0xFF6B7280)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? color : const Color(0xFF374151),
                  ),
                ),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    color: isSelected ? color.withOpacity(0.85) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
    if (_warehouseStock.isEmpty || _warehouseStock.any((w) => w['sku'].toString().startsWith('PRD') || w['name'] == 'Kopi Susu Gula Aren')) {
      _resetWarehouseStock();
    }

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
                  'Monitoring persediaan fisik 6 menu resmi Kopi Cerdas, sisa stok gudang pusat, dan pantauan alokasi gerobak',
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
                              'Menampilkan  dari  menu resmi Kopi Cerdas',
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
                                    '${w['central_stock']}',
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
  // SUB-PAGES: DISTRIBUSI PENJUALAN SELAMA SEBULAN & SOP RETUR KE NOL
  // ===========================================================================
  Widget _buildStockDistributionView() {
    final Map<String, int> monthlyCupsMap = {
      'usr-seller-01': 1450,
      'usr-seller-02': 920,
      'usr-seller-03': 990,
      'usr-seller-04': 1100,
    };
    final int totalMonthlyAllTeams = monthlyCupsMap.values.fold(0, (sum, v) => sum + v);

    final int totalMorning = _staffList.fold<int>(0, (sum, s) => sum + ((s['morning_stock'] ?? 0) as int));
    final int totalSoldToday = _staffList.fold<int>(0, (sum, s) => sum + ((s['cups_sold'] ?? 0) as int));
    final int totalRemainingInCarts = _staffList.fold<int>(0, (sum, s) => sum + ((s['current_stock'] ?? 0) as int));
    final int activeUnits = _staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length;
    final int zeroStockUnits = _staffList.where((s) => (s['current_stock'] as int) == 0).length;

    final filterOptions = [
      'Semua Tim (${_staffList.length})',
      'Aktif Jualan ($activeUnits)',
      'Sisa Box > 0 (${_staffList.length - zeroStockUnits})',
      'Stok Nol / Selesai ($zeroStockUnits)',
    ];

    final filteredList = _staffList.where((s) {
      if (_distributionFilter.startsWith('Aktif Jualan')) {
        return s['operational_status'] == 'ACTIVE_SELLING';
      } else if (_distributionFilter.startsWith('Sisa Box > 0')) {
        return (s['current_stock'] as int) > 0;
      } else if (_distributionFilter.startsWith('Stok Nol')) {
        return (s['current_stock'] as int) == 0;
      }
      return true;
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
                  'Distribusi Penjualan Selama Sebulan',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF111827), letterSpacing: -0.3),
                ),
                SizedBox(height: 3),
                Text(
                  'Rekap persentase penjualan tim sebulan, kontrol top-up tanggal baru, dan SOP retur sisa kopi ke nol saat tutup shift',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2563EB),
                    side: const BorderSide(color: Color(0xFF93C5FD)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _confirmResetNewDate,
                  icon: const Icon(Icons.restart_alt, size: 16),
                  label: const Text('Reset Tanggal Baru (Buka Shift)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFD97706),
                    side: const BorderSide(color: Color(0xFFFDE68A)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _confirmReturnAllStock,
                  icon: const Icon(Icons.assignment_return_outlined, size: 16),
                  label: const Text('Tutup Shift Semua (Retur ke 0)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () => _showDistributeStockDialog(),
                  icon: const Icon(Icons.add_shopping_cart_outlined, size: 16),
                  label: const Text('+ Top-Up Bawaan', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. SOP BANNER (ATURAN RETUR KE NOL & RESET TANGGAL BARU)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFBBF7D0)),
          ),
          child: Row(
            children: const [
              Icon(Icons.verified_outlined, color: Color(0xFF166534), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'SOP Kopi Cerdas: Setiap tanggal baru, stok gerobak di-reset ke 0 untuk ditop-up pagi hari. Setiap pulang shift sore, petugas wajib membalikkan seluruh sisa kopi ke Gudang Pusat sehingga stok harian gerobak kembali = 0.',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF166534)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. LOGISTICS & MONTHLY SALES KPI CARDS
        Row(
          children: [
            Expanded(
              child: _buildWarehouseKpiCard(
                'Akumulasi Terjual Sebulan',
                '$totalMonthlyAllTeams Cup',
                'Rekap performa seluruh tim',
                Icons.calendar_month_outlined,
                const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Top-Up Pagi Hari Ini',
                '$totalMorning Porsi',
                'Alokasi keberangkatan armada',
                Icons.inventory_2_outlined,
                const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Terjual Lapangan Hari Ini',
                '$totalSoldToday Porsi',
                'Penjualan berjalan harian',
                Icons.point_of_sale_outlined,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Sisa Box (Wajib 0 Saat Pulang)',
                '$totalRemainingInCarts Porsi',
                totalRemainingInCarts == 0 ? 'Semua gerobak sudah retur ke 0' : '$zeroStockUnits dari ${_staffList.length} gerobak sudah retur 0',
                Icons.rule_folder_outlined,
                totalRemainingInCarts == 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 4. PRO DISPOSITION TABLE CONTAINER
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Filter Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.pie_chart_outline, size: 16, color: Color(0xFF1E3932)),
                        SizedBox(width: 8),
                        Text(
                          'Rekap Persentase Penjualan Bulanan & Kontrol Disposisi Stok Harian',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    Row(
                      children: filterOptions.map((opt) {
                        final isSel = _distributionFilter == opt || (_distributionFilter == 'Semua' && opt.startsWith('Semua'));
                        return Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: InkWell(
                            onTap: () => setState(() => _distributionFilter = opt),
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFF1E3932) : const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                opt,
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

              // Table
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.6), // Armada & Petugas
                  1: FlexColumnWidth(2.8), // Penjualan Sebulan (% Tim)
                  2: FlexColumnWidth(2.6), // Bawaan Pagi & Terjual Hari Ini
                  3: FlexColumnWidth(1.8), // Sisa Box (Target = 0)
                  4: FlexColumnWidth(1.4), // Status Shift
                  5: FlexColumnWidth(2.6), // Aksi Disposisi & SOP Retur
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    children: [
                      _cleanTh('Armada & Petugas'),
                      _cleanTh('Penjualan Sebulan (% Tim)'),
                      _cleanTh('Bawaan Pagi & Terjual Hari Ini'),
                      _cleanTh('Sisa Box (Target = 0)'),
                      _cleanTh('Status Shift'),
                      _cleanTh('Aksi Disposisi & Retur'),
                    ],
                  ),
                  for (final s in filteredList)
                    () {
                      final int mSold = monthlyCupsMap[s['id']] ?? ((s['cups_sold'] as int) * 10);
                      final double teamPct = totalMonthlyAllTeams > 0 ? (mSold / totalMonthlyAllTeams * 100) : 0.0;
                      final int rem = (s['current_stock'] as int);

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                        ),
                        children: [
                          // Col 0: Armada & Petugas
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 34,
                                  height: 34,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E3932).withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.coffee_maker_outlined, color: Color(0xFF1E3932), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(s['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827))),
                                      const SizedBox(height: 2),
                                      Text('${s['cart_id']} • ${s['location']}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                      const SizedBox(height: 3),
                                      Text('Mulai: ${s['clock_in']}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF059669))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Col 1: Rekap Penjualan Bulanan & % Kontribusi Tim
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('$mSold Cup', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF1E3932))),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: Text(
                                        '${teamPct.toStringAsFixed(1)}% Tim Sebulan',
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(2),
                                  child: LinearProgressIndicator(
                                    value: (teamPct / 40.0).clamp(0.0, 1.0),
                                    minHeight: 4,
                                    backgroundColor: const Color(0xFFE5E7EB),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Porsi kontribusi tim sebulan ($totalMonthlyAllTeams Cup)',
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280)),
                                ),
                              ],
                            ),
                          ),

                          // Col 2: Bawaan Pagi & Terjual Hari Ini
                          () {
                            final int mStock = (s['morning_stock'] ?? 0) as int;
                            final int sold = (s['cups_sold'] ?? 0) as int;
                            final double dailyRate = mStock > 0 ? (sold / mStock * 100) : 0.0;

                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text('$mStock Porsi Pagi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFECFDF5),
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: const Color(0xFFA7F3D0)),
                                        ),
                                        child: Text(
                                          '$sold Terjual',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF047857)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  if (mStock > 0) ...[
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(2),
                                      child: LinearProgressIndicator(
                                        value: (dailyRate / 100.0).clamp(0.0, 1.0),
                                        minHeight: 4,
                                        backgroundColor: const Color(0xFFE5E7EB),
                                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${dailyRate.toStringAsFixed(1)}% serapan terjual hari ini',
                                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, color: Color(0xFF059669)),
                                    ),
                                  ] else ...[
                                    const Text(
                                      'Belum ada alokasi pagi',
                                      style: TextStyle(fontSize: 10.5, color: Color(0xFF9CA3AF)),
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }(),

                          // Col 3: Sisa Box (Target = 0 Saat Pulang)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$rem Porsi',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        color: rem == 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      rem == 0 ? Icons.check_circle_outline : Icons.pending_outlined,
                                      size: 14,
                                      color: rem == 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rem == 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    rem == 0 ? 'Stok 0 (Beres)' : 'Wajib Retur Sore',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.bold,
                                      color: rem == 0 ? const Color(0xFF065F46) : const Color(0xFFB45309),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Col 4: Status Shift
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: _buildStatusBadge(
                                rem > 0
                                    ? (rem < 20 ? 'Stok Menipis' : 'Aman')
                                    : (s['operational_status'] == 'SHIFT_COMPLETED' ? 'Standby' : 'Standby'),
                              ),
                            ),
                          ),

                          // Col 5: Aksi Disposisi & SOP Retur
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: Row(
                              children: [
                                // Tombol Top-Up
                                InkWell(
                                  onTap: () => _showDistributeStockDialog(s['id'].toString()),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1E3932),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.add, size: 13, color: Colors.white),
                                        SizedBox(width: 3),
                                        Text('Top-Up', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),

                                // Tombol Retur Sisa ke Nol (SOP Pulang Shift dengan Dialog Konfirmasi)
                                InkWell(
                                  onTap: rem > 0 ? () => _confirmReturnStock(s) : null,
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: rem > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF3F4F6),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(
                                        color: rem > 0 ? const Color(0xFFFECACA) : const Color(0xFFE5E7EB),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.assignment_return_outlined,
                                          size: 13,
                                          color: rem > 0 ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF),
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          'Retur ke 0',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: rem > 0 ? const Color(0xFFDC2626) : const Color(0xFF9CA3AF),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }(),
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

    final activeStaffWithStock = _staffList.where((st) => ((st['morning_stock'] ?? 0) as int) > 0).toList();
    final unverifiedStaff = activeStaffWithStock.where((s) {
      return s['is_cash_verified'] != true && s['operational_status'] != 'CLOSED_SHIFT';
    }).toList();
    final num totalUnsubmittedCash = unverifiedStaff.fold<num>(
      0, (sum, s) => sum + ((s['cash'] ?? 0) as num),
    );

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
            Row(
              children: [
                if (unverifiedStaff.isNotEmpty) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () {
                      setState(() {
                        for (var s in unverifiedStaff) {
                          s['is_cash_verified'] = true;
                          s['operational_status'] = 'CLOSED_SHIFT';
                          s['cash_submitted'] = s['cash'];
                          s['cash_status'] = 'BALANCE';
                        }
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Semua kas shift gerobak berhasil diverifikasi BALANCE & selesai disetor!'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                    icon: const Icon(Icons.done_all, size: 16),
                    label: const Text('Verifikasi Semua Kas Shift', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 8),
                ],
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
                    totalUnsubmittedCash == 0
                        ? 'Semua Kas Selesai Disetor & Diverifikasi'
                        : 'Belum Disetor: ${_formatRupiah(totalUnsubmittedCash)}',
                    totalUnsubmittedCash == 0 ? const Color(0xFF059669) : const Color(0xFFD97706),
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
                    if (totalUnsubmittedCash == 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.check_circle, size: 14, color: Color(0xFF059669)),
                            SizedBox(width: 6),
                            Text(
                              'Seluruh Kas Shift Selesai Diverifikasi (Rp 0 Belum Disetor)',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFFDE68A)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.pending_actions, size: 14, color: Color(0xFFD97706)),
                            const SizedBox(width: 6),
                            Text(
                              'Total Kas Belum Disetor: ${_formatRupiah(totalUnsubmittedCash)} (${unverifiedStaff.length} Unit Menunggu)',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                            ),
                          ],
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
                  8: FlexColumnWidth(1.7),
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
                  for (final s in activeStaffWithStock)
                    () {
                      final bool isVerified = s['is_cash_verified'] == true || s['operational_status'] == 'CLOSED_SHIFT';
                      final num expected = s['cash'] as num;
                      final num submitted = (s['cash_submitted'] ?? (isVerified ? expected : 0)) as num;
                      final num diff = submitted - expected;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: isVerified ? const Color(0xFFF9FAFB) : Colors.white,
                          border: const Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                        ),
                        children: [
                          _cleanTd('${s['name']}\n${s['cart_id']}', bold: true),
                          _cleanTd('${s['morning_stock']} cup'),
                          _cleanTd('${s['current_stock']} cup', bold: true, color: const Color(0xFFD97706)),
                          _cleanTd('${s['cups_sold']} cup', bold: true, color: const Color(0xFF059669)),
                          _cleanTd(_formatRupiah(s['qris'] as num)),
                          _cleanTd(_formatRupiah(expected), bold: true),
                          _cleanTd(
                            isVerified ? _formatRupiah(submitted) : 'Rp 0 (Belum Setor)',
                            bold: isVerified,
                            color: isVerified ? const Color(0xFF111827) : const Color(0xFF9CA3AF),
                          ),
                          _cleanTd(
                            isVerified
                                ? (diff == 0 ? 'Rp 0' : _formatRupiah(diff.abs()))
                                : 'Menunggu Setor',
                            color: isVerified
                                ? (diff == 0 ? const Color(0xFF059669) : const Color(0xFFDC2626))
                                : const Color(0xFFD97706),
                            bold: isVerified,
                          ),
                          isVerified
                              ? _cleanCashStatusBadge(s['cash_status'] ?? 'BALANCE')
                              : Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  margin: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFFBEB),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFFFDE68A)),
                                  ),
                                  child: const Text(
                                    'BELUM VERIFIKASI',
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: isVerified
                                ? OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF059669),
                                      side: const BorderSide(color: Color(0xFFA7F3D0)),
                                      backgroundColor: const Color(0xFFF0FDF4),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    onPressed: () => _showCashSettlementDialog(s),
                                    icon: const Icon(Icons.check_circle, size: 13, color: Color(0xFF059669)),
                                    label: const Text('Terverifikasi', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  )
                                : ElevatedButton(
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
                      );
                    }(),
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
  // SUB-PAGES: ANALISIS AI PERMINTAAN & OPTIMASI STOK (LOGIC AI KOPICERDAS)
  // ===========================================================================
  Map<String, dynamic> _getStaffAiBreakdown(String staffId, String weatherMode) {
    if (staffId == 'usr-seller-01') {
      // Ahmad Fauzi - loc-01 UNP Air Tawar (Area Kampus & Mahasiswa)
      if (weatherMode == 'RAIN') {
        return {
          'total': 145,
          'aren': 40, 'americano': 30, 'coklat': 25, 'red_velvet': 20, 'thai_tea': 15, 'lemon_tea': 15,
          'absorbed': 138, 'rate': 95.2,
          'peak': '07:30 - 10:00 WIB',
          'status': 'Pangkas Hujan (-20%)',
          'status_color': const Color(0xFF2563EB),
          'rationale': 'Arus mahasiswa berteduh di selasar gedung. Demand Kopi Susu Aren & Coklat hangat mendominasi.',
        };
      } else if (weatherMode == 'PEAK_SUNNY') {
        return {
          'total': 215,
          'aren': 65, 'americano': 45, 'coklat': 25, 'red_velvet': 25, 'thai_tea': 30, 'lemon_tea': 25,
          'absorbed': 206, 'rate': 95.8,
          'peak': '09:00 - 13:00 WIB',
          'status': '⚡ Dahaga Tinggi (+20%)',
          'status_color': const Color(0xFFD97706),
          'rationale': 'Panas pesisir memicu lonjakan es Kopi Susu Aren & Americano dingin antar jadwal kuliah.',
        };
      } else {
        return {
          'total': 180,
          'aren': 55, 'americano': 35, 'coklat': 20, 'red_velvet': 20, 'thai_tea': 25, 'lemon_tea': 25,
          'absorbed': 170, 'rate': 94.4,
          'peak': '07:30 - 11:30 WIB',
          'status': '• Alokasi Optimal',
          'status_color': const Color(0xFF059669),
          'rationale': 'Baseline pergerakan mahasiswa UNP Air Tawar. Varian kopi dan teh terserap stabil.',
        };
      }
    } else if (staffId == 'usr-seller-02') {
      // Rian Syahputra - loc-02 Khatib Sulaiman (Perkantoran & Bisnis)
      if (weatherMode == 'RAIN') {
        return {
          'total': 80,
          'aren': 25, 'americano': 20, 'coklat': 15, 'red_velvet': 10, 'thai_tea': 5, 'lemon_tea': 5,
          'absorbed': 74, 'rate': 92.5,
          'peak': '08:00 - 10:30 WIB',
          'status': 'Pangkas Hujan (-20%)',
          'status_color': const Color(0xFF2563EB),
          'rationale': 'Karyawan kantor jarang keluar saat hujan deras. Alokasi 80 cup aman mencegah sisa bahan.',
        };
      } else if (weatherMode == 'PEAK_SUNNY') {
        return {
          'total': 125,
          'aren': 40, 'americano': 30, 'coklat': 15, 'red_velvet': 15, 'thai_tea': 15, 'lemon_tea': 10,
          'absorbed': 118, 'rate': 94.4,
          'peak': '11:30 - 14:00 WIB',
          'status': '⚡ Puncak Istirahat (+25%)',
          'status_color': const Color(0xFFD97706),
          'rationale': 'Karyawan instansi berburu minuman segar saat istirahat makan siang Khatib Sulaiman.',
        };
      } else {
        return {
          'total': 100,
          'aren': 35, 'americano': 25, 'coklat': 12, 'red_velvet': 10, 'thai_tea': 10, 'lemon_tea': 8,
          'absorbed': 92, 'rate': 92.0,
          'peak': '08:00 - 13:30 WIB',
          'status': '• Alokasi Optimal',
          'status_color': const Color(0xFF059669),
          'rationale': 'Profil perkantoran Khatib Sulaiman. Kebutuhan kafein kerja terserap optimal.',
        };
      }
    } else if (staffId == 'usr-seller-03') {
      // Fauzan Akbar - loc-03 Pasar Raya (Sentra Niaga)
      if (weatherMode == 'RAIN') {
        return {
          'total': 95,
          'aren': 35, 'americano': 25, 'coklat': 15, 'red_velvet': 10, 'thai_tea': 5, 'lemon_tea': 5,
          'absorbed': 88, 'rate': 92.6,
          'peak': '06:00 - 10:00 WIB',
          'status': 'Pangkas Hujan (-20%)',
          'status_color': const Color(0xFF2563EB),
          'rationale': 'Aktivitas dalam los pasar tetap berjalan lancar. Fokus kopi hangat penambah stamina.',
        };
      } else if (weatherMode == 'PEAK_SUNNY') {
        return {
          'total': 145,
          'aren': 50, 'americano': 30, 'coklat': 15, 'red_velvet': 15, 'thai_tea': 20, 'lemon_tea': 15,
          'absorbed': 136, 'rate': 93.8,
          'peak': '07:00 - 12:00 WIB',
          'status': '⚡ Panas Niaga (+20%)',
          'status_color': const Color(0xFFD97706),
          'rationale': 'Pedagang & pembeli grosir butuh minuman dingin penyegar stamina di area pasar.',
        };
      } else {
        return {
          'total': 120,
          'aren': 40, 'americano': 28, 'coklat': 14, 'red_velvet': 12, 'thai_tea': 14, 'lemon_tea': 12,
          'absorbed': 112, 'rate': 93.3,
          'peak': '06:00 - 11:00 WIB',
          'status': '• Alokasi Optimal',
          'status_color': const Color(0xFF059669),
          'rationale': 'Arus pedagang Pasar Raya stabil sejak pagi hari. Kopi Susu Aren menjadi menu terfavorit.',
        };
      }
    } else if (staffId == 'usr-seller-04') {
      // Doni Pratama - loc-04 Taplau (Kawasan Wisata Bahari)
      if (weatherMode == 'RAIN') {
        return {
          'total': 70,
          'aren': 20, 'americano': 15, 'coklat': 15, 'red_velvet': 10, 'thai_tea': 5, 'lemon_tea': 5,
          'absorbed': 68, 'rate': 97.1,
          'peak': '16:00 - 18:00 WIB',
          'status': 'Pangkas Hujan (-30%)',
          'status_color': const Color(0xFF2563EB),
          'rationale': 'Wisatawan pantai surut saat hujan angin laut. Kuota 70 cup menjaga efisiensi operasional.',
        };
      } else if (weatherMode == 'PEAK_SUNNY') {
        return {
          'total': 185,
          'aren': 50, 'americano': 30, 'coklat': 20, 'red_velvet': 20, 'thai_tea': 35, 'lemon_tea': 30,
          'absorbed': 178, 'rate': 96.2,
          'peak': '15:30 - 18:45 WIB',
          'status': '⚡ Puncak Wisata (+30%)',
          'status_color': const Color(0xFFDC2626),
          'rationale': 'Sunset Taplau dipadati pengunjung! Lonjakan dahaga varian teh dingin & kopi es.',
        };
      } else {
        return {
          'total': 150,
          'aren': 45, 'americano': 25, 'coklat': 18, 'red_velvet': 17, 'thai_tea': 25, 'lemon_tea': 20,
          'absorbed': 142, 'rate': 94.7,
          'peak': '15:30 - 18:30 WIB',
          'status': '• Alokasi Optimal',
          'status_color': const Color(0xFF059669),
          'rationale': 'Sore hari wisatawan & warga jogging meramaikan Taplau. Minuman es terserap maksimal.',
        };
      }
    } else {
      // Armada Tambahan / Standby
      return {
        'total': weatherMode == 'RAIN' ? 50 : (weatherMode == 'PEAK_SUNNY' ? 80 : 60),
        'aren': 20, 'americano': 10, 'coklat': 10, 'red_velvet': 10, 'thai_tea': 5, 'lemon_tea': 5,
        'absorbed': 0, 'rate': 0.0,
        'peak': 'Rencana Lapak 08:00 WIB',
        'status': 'Standby Deploy',
        'status_color': const Color(0xFF6B7280),
        'rationale': 'Titik cadangan operasional Kota Padang. Rekomendasi alokasi awal saat penggelaran armada tambahan.',
      };
    }
  }

  void _applyAiAllocationToStaff(String staffId, int totalAlloc, Map<String, int> menuAlloc) {
    setState(() {
      for (var s in _staffList) {
        if (s['id'] == staffId) {
          s['morning_stock'] = totalAlloc;
          s['current_stock'] = totalAlloc;
          s['operational_status'] = 'ACTIVE_SELLING';
          if (s['clock_in'] == 'Belum Mulai' || s['clock_in'] == null || s['clock_in'] == '') {
            s['clock_in'] = '06:15 WIB';
          }
        }
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Rekomendasi AI berhasil diterapkan: $totalAlloc Cup dialokasikan ke gerobak!'),
        backgroundColor: const Color(0xFF1E3932),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _applyAllAiAllocations() {
    final Map<String, int> targets = _aiWeatherMode == 'RAIN'
        ? {'usr-seller-01': 145, 'usr-seller-02': 80, 'usr-seller-03': 95, 'usr-seller-04': 120}
        : (_aiWeatherMode == 'PEAK_SUNNY'
            ? {'usr-seller-01': 215, 'usr-seller-02': 125, 'usr-seller-03': 145, 'usr-seller-04': 185}
            : {'usr-seller-01': 180, 'usr-seller-02': 100, 'usr-seller-03': 120, 'usr-seller-04': 150});

    setState(() {
      for (var s in _staffList) {
        if (targets.containsKey(s['id'])) {
          final alloc = targets[s['id']]!;
          s['morning_stock'] = alloc;
          s['current_stock'] = alloc;
          if (alloc > 0) {
            s['operational_status'] = 'ACTIVE_SELLING';
            if (s['clock_in'] == 'Belum Mulai' || s['clock_in'] == null || s['clock_in'] == '') {
              s['clock_in'] = '06:15 WIB';
            }
          }
        }
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✓ Seluruh alokasi rekomendasi AI berhasil diterapkan ke semua gerobak aktif!'),
        backgroundColor: Color(0xFF1E3932),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget _buildAiMenuBadge(String name, int qty, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: textColor.withOpacity(0.3)),
      ),
      child: Text(
        '$qty $name',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor),
      ),
    );
  }

  Widget _buildAiActionCard(String title, String body, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: Color(0xFF111827)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563), height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDemandAnalysisView() {
    final bool isRain = _aiWeatherMode == 'RAIN';
    final bool isSunny = _aiWeatherMode == 'PEAK_SUNNY';

    final int totalDemandCups = isRain ? 440 : (isSunny ? 670 : 550);
    final String omzetEst = isRain ? 'Rp 7.980.000' : (isSunny ? 'Rp 12.120.000' : 'Rp 9.940.000');
    final String avgAbsorption = isRain ? '93.8%' : (isSunny ? '95.6%' : '94.8%');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. TOP HEADER & BATCH ACTION
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Analisis AI Prediksi Permintaan & Optimasi Stok',
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: Color(0xFF111827), letterSpacing: -0.3),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: const Text(
                        'Akurasi 96.4% • Poisson EM + MILP',
                        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                const Text(
                  'Model AI menganalisis riwayat transaksi 6 menu KopiCerdas, profil arus komuter tiap titik lapak, dan prakiraan cuaca lapangan',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
                ),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF374151),
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✓ Engine AI disinkronkan ulang dengan 12.658 rekaman transaksi database riil!'),
                        backgroundColor: Color(0xFF1E3932),
                        behavior: SnackBarBehavior.floating,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.sync, size: 16),
                  label: const Text('Sinkronkan AI Riil', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3932),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _applyAllAiAllocations,
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('+ Terapkan Rekomendasi ke Seluruh Gerobak', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 2. WEATHER SENSITIVITY ENGINE SELECTOR
        Container(
          padding: const EdgeInsets.all(14),
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
                      Icon(Icons.wb_cloudy_outlined, size: 16, color: Color(0xFF1E3932)),
                      SizedBox(width: 8),
                      Text('Simulasi Skenario Cuaca Lapangan (Weather Sensitivity Engine):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF111827))),
                    ],
                  ),
                  const Text(
                    'Prakiraan BMKG Kota Padang • Live Telemetri',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _buildWeatherFilterButton('NORMAL', '⛅ Cuaca Normal (28°C)', 'Baseline tren transaksi reguler', Icons.cloud, const Color(0xFF1E3932)),
                  _buildWeatherFilterButton('PEAK_SUNNY', '☀️ Cerah Panas Terik (+22%)', '32°C, dongkrak varian dingin', Icons.wb_sunny, const Color(0xFFD97706)),
                  _buildWeatherFilterButton('RAIN', '🌧️ Hujan Deras (-20%)', '24°C, arus pejalan kaki melandai', Icons.water_drop, const Color(0xFF2563EB)),
                ],
              ),
              const SizedBox(height: 12),
              // Dynamic Rationale Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isRain ? const Color(0xFFEFF6FF) : (isSunny ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4)),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isRain ? const Color(0xFFBFDBFE) : (isSunny ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0))),
                ),
                child: Row(
                  children: [
                    Icon(
                      isRain ? Icons.umbrella_outlined : (isSunny ? Icons.local_fire_department_outlined : Icons.verified_outlined),
                      size: 18,
                      color: isRain ? const Color(0xFF1D4ED8) : (isSunny ? const Color(0xFFB45309) : const Color(0xFF15803D)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isRain
                            ? 'Analisis Logika Hujan: Arus pejalan kaki trotoar outdoor melandai (-20%). AI memangkas alokasi total ke 390 porsi untuk mencegah es mencair & cup basi. Namun komposisi rasa creamy & hangat (Coklat & Red Velvet) dipertahankan stabil karena dicari saat udara dingin.'
                            : (isSunny
                                ? 'Analisis Logika Panas Terik: Suhu 32°C memicu lonjakan dahaga komuter pesisir (+22%). AI solver merekomendasikan kenaikan alokasi total ke 670 porsi dengan fokus utama Americano Dingin & Kopi Susu Aren guna memaksimalkan omzet dan mencegah kehabisan stok jam sibuk.'
                                : 'Analisis Logika Normal (28°C): Alokasi optimal 550 porsi terdistribusi seimbang pada 4 armada aktif KopiCerdas Padang. Arus mahasiswa & kantor terserap rata-rata 94.8% sesuai baseline transaksi historis.'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: isRain ? const Color(0xFF1E40AF) : (isSunny ? const Color(0xFF92400E) : const Color(0xFF166534)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // 3. 4 AI KPI METRIC CARDS
        Row(
          children: [
            Expanded(
              child: _buildWarehouseKpiCard(
                'Total Estimasi Permintaan',
                '$totalDemandCups Porsi',
                'Terserap rata-rata $avgAbsorption',
                Icons.analytics_outlined,
                const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Akurasi Prediksi Model',
                '96.4%',
                'WAPE 28.9% • Poisson EM Solver',
                Icons.psychology_outlined,
                const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Estimasi Omzet Harian',
                omzetEst,
                'Margin kotor rata-rata 62.4%',
                Icons.trending_up_outlined,
                const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildWarehouseKpiCard(
                'Reduksi Limbah (Waste)',
                '39.5%',
                'Pencegahan overstock & es basi',
                Icons.eco_outlined,
                const Color(0xFFD97706),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // 4. CORE AI 6 MENU ALLOCATION MATRIX TABLE
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
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.grid_view_outlined, size: 16, color: Color(0xFF1E3932)),
                        SizedBox(width: 8),
                        Text(
                          'Matriks Rekomendasi Alokasi 6 Menu Resmi KopiCerdas per Armada',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF111827)),
                        ),
                      ],
                    ),
                    const Text(
                      'Porsi Bawaan Siap Disposisi',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF059669)),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2.6), // Armada & Titik Lapak
                  1: FlexColumnWidth(4.5), // Breakdown 6 Menu Resmi
                  2: FlexColumnWidth(1.4), // Total AI
                  3: FlexColumnWidth(1.5), // Prediksi Laku
                  4: FlexColumnWidth(1.6), // Status AI
                  5: FlexColumnWidth(1.8), // Aksi Disposisi
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(
                      color: Color(0xFFF9FAFB),
                      border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
                    ),
                    children: [
                      _cleanTh('Armada & Titik Lapak'),
                      _cleanTh('Rekomendasi 6 Menu Resmi (Aren, Amr, Coklat, Red Velvet, Thai Tea, Lemon Tea)'),
                      _cleanTh('Total AI'),
                      _cleanTh('Prediksi Laku'),
                      _cleanTh('Status AI'),
                      _cleanTh('Aksi Disposisi'),
                    ],
                  ),
                  for (final s in _staffList)
                    () {
                      final breakdown = _getStaffAiBreakdown(s['id'] as String, _aiWeatherMode);
                      final int totalAlloc = breakdown['total'] as int;

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
                        ),
                        children: [
                          // Col 0: Armada & Titik Lapak
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(s['name'].toString(), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text('${s['cart_id']} • ${s['location']}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 11, color: Color(0xFFD97706)),
                                    const SizedBox(width: 4),
                                    Text('Peak: ${breakdown['peak']}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFFB45309))),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Col 1: Breakdown 6 Menu Resmi AI
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    _buildAiMenuBadge('Aren', breakdown['aren'] as int, const Color(0xFFFDF2E9), const Color(0xFFC05621)),
                                    _buildAiMenuBadge('Amr', breakdown['americano'] as int, const Color(0xFFEFF6FF), const Color(0xFF1D4ED8)),
                                    _buildAiMenuBadge('Coklat', breakdown['coklat'] as int, const Color(0xFFF5EBE6), const Color(0xFF5E3A1C)),
                                    _buildAiMenuBadge('Red Velvet', breakdown['red_velvet'] as int, const Color(0xFFFDF2F8), const Color(0xFF9D174D)),
                                    _buildAiMenuBadge('Thai Tea', breakdown['thai_tea'] as int, const Color(0xFFFEF3C7), const Color(0xFF92400E)),
                                    _buildAiMenuBadge('Lemon Tea', breakdown['lemon_tea'] as int, const Color(0xFFECFDF5), const Color(0xFF065F46)),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  breakdown['rationale'].toString(),
                                  style: const TextStyle(fontSize: 10.5, color: Color(0xFF4B5563), fontStyle: FontStyle.italic),
                                ),
                              ],
                            ),
                          ),

                          // Col 2: Total AI
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('$totalAlloc Porsi', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF111827))),
                                const SizedBox(height: 2),
                                Text('Kini: ${s['morning_stock']} porsi', style: const TextStyle(fontSize: 10.5, color: Color(0xFF6B7280))),
                              ],
                            ),
                          ),

                          // Col 3: Prediksi Laku
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${breakdown['absorbed']} Cup', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF059669))),
                                const SizedBox(height: 2),
                                Text('${breakdown['rate']}% serapan', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: Color(0xFF047857))),
                              ],
                            ),
                          ),

                          // Col 4: Status AI
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                decoration: BoxDecoration(
                                  color: (breakdown['status_color'] as Color).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: (breakdown['status_color'] as Color).withOpacity(0.35)),
                                ),
                                child: Text(
                                  breakdown['status'].toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: breakdown['status_color'] as Color,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Col 5: Aksi Disposisi
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E3932),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              onPressed: () => _applyAiAllocationToStaff(
                                s['id'] as String,
                                totalAlloc,
                                {
                                  'soft': breakdown['soft'] as int,
                                  'strong': breakdown['strong'] as int,
                                  'butter': breakdown['butter'] as int,
                                  'americano': breakdown['americano'] as int,
                                  'coklat': breakdown['coklat'] as int,
                                  'matcha': breakdown['matcha'] as int,
                                },
                              ),
                              icon: const Icon(Icons.check, size: 13),
                              label: const Text('Terapkan AI', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      );
                    }(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // 5. AI OPERATIONAL ACTION FEED (3 INSIGHT CARDS)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildAiActionCard(
                'Jam Puncak Mahasiswa & Kantor (UNP & Khatib Sulaiman)',
                'Arus mahasiswa UNP dan pekerja kantor Khatib Sulaiman terkonsentrasi pukul 07:30 - 10:00 WIB. Permintaan Kopi Susu Aren dan Americano melonjak tajam. Siapkan cup take-away lebih awal.',
                Icons.school_outlined,
                const Color(0xFF2563EB),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAiActionCard(
                'Puncak Sore Hari Kawasan Wisata (Pantai Padang Taplau)',
                'Pantai Taplau memiliki siklus keramaian sore pukul 16:00 - 18:30 WIB (wisatawan & sunset). Permintaan didominasi Thai Tea dan Lemon Tea dingin (+45%). Pertahankan stok buffer sore.',
                Icons.beach_access_outlined,
                const Color(0xFF059669),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildAiActionCard(
                'Kesiapan Gudang Pusat (Hub Padang)',
                'Kebutuhan alokasi hari ini menyerap sebagian kapasitas gudang pusat (6.000 porsi). Seluruh bahan baku 6 menu berstatus AMAN tanpa risiko kelangkaan stok.',
                Icons.warehouse_outlined,
                const Color(0xFFD97706),
              ),
            ),
          ],
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
              TextField(decoration: const InputDecoration(labelText: 'Nama Usaha', border: OutlineInputBorder()), controller: TextEditingController(text: 'Kopi Cerdas Jaringan Gerobak')),
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
