import 'package:flutter/material.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  int _selectedNavIndex = 0;
  String _staffSearchQuery = '';
  String _warehouseSearchQuery = '';
  String _orderStatusFilter = 'ALL';

  // ===========================================================================
  // 1. DATA PETUGAS LAPANGAN & AKUN (ABSENSI, STATUS ON/OFF, KOMISI, GPS, STOK)
  // ===========================================================================
  final List<Map<String, dynamic>> _staffAccounts = [
    {
      'id': 'USR-SLR-01',
      'username': 'budi_sudirman',
      'name': 'Budi Santoso',
      'phone': '0812-8821-9901',
      'role': 'SELLER_LEAD',
      'cart_id': 'GRB-01 (Sudirman Core)',
      'selected_location': 'Halte Dukuh Atas Sudirman (Pintu Barat)',
      'coordinates': '-6.2088, 106.8227',
      'map_x': 180.0,
      'map_y': 160.0,
      'is_store_open': true,
      'attendance_time': '06:15 WIB (On-Time)',
      'morning_stock_picked': '120 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 142,
      'total_commission': 213000,
      'commission_paid': false,
      'cash_in_hand': 900000,
      'qris_collected': 1940000,
      'current_stock': 42,
      'max_capacity': 120,
      'active_orders_count': 3,
      'status': 'AKTIF JUALAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'id': 'USR-SLR-02',
      'username': 'ahmad_suropati',
      'name': 'Ahmad Fauzi',
      'phone': '0813-1102-4451',
      'role': 'SELLER_REGULER',
      'cart_id': 'GRB-02 (Suropati Lounge)',
      'selected_location': 'Taman Suropati & Taman Kodok Menteng',
      'coordinates': '-6.1994, 106.8326',
      'map_x': 320.0,
      'map_y': 120.0,
      'is_store_open': true,
      'attendance_time': '06:40 WIB (On-Time)',
      'morning_stock_picked': '100 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 68,
      'total_commission': 102000,
      'commission_paid': false,
      'cash_in_hand': 520000,
      'qris_collected': 900000,
      'current_stock': 28,
      'max_capacity': 100,
      'active_orders_count': 1,
      'status': 'AKTIF JUALAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'id': 'USR-SLR-03',
      'username': 'siti_senen',
      'name': 'Siti Rahmawati',
      'phone': '0857-4491-0023',
      'role': 'SELLER_REGULER',
      'cart_id': 'GRB-03 (Pasar Senen)',
      'selected_location': 'Pojok Blok III & Halte Senen Sentral',
      'coordinates': '-6.1744, 106.8432',
      'map_x': 460.0,
      'map_y': 80.0,
      'is_store_open': true,
      'attendance_time': '05:30 WIB (On-Time)',
      'morning_stock_picked': '120 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 95,
      'total_commission': 142500,
      'commission_paid': false,
      'cash_in_hand': 640000,
      'qris_collected': 1340000,
      'current_stock': 35,
      'max_capacity': 120,
      'active_orders_count': 2,
      'status': 'AKTIF JUALAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'id': 'USR-SLR-04',
      'username': 'hendra_juanda',
      'name': 'Hendra Wijaya',
      'phone': '0821-7781-3312',
      'role': 'SELLER_REGULER',
      'cart_id': 'GRB-04 (Juanda Transit)',
      'selected_location': 'Pintu Timur Stasiun Commuter Juanda',
      'coordinates': '-6.1668, 106.8312',
      'map_x': 270.0,
      'map_y': 50.0,
      'is_store_open': true,
      'attendance_time': '05:50 WIB (On-Time)',
      'morning_stock_picked': '110 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 118,
      'total_commission': 177000,
      'commission_paid': false,
      'cash_in_hand': 780000,
      'qris_collected': 1670000,
      'current_stock': 15,
      'max_capacity': 110,
      'active_orders_count': 4,
      'status': 'STOK MENIPIS',
      'status_color': const Color(0xFFEF4444),
    },
    {
      'id': 'USR-SLR-05',
      'username': 'rizky_kuningan',
      'name': 'Rizky Pratama',
      'phone': '0812-9900-1122',
      'role': 'SELLER_TRAINEE',
      'cart_id': 'GRB-05 (Standby)',
      'selected_location': 'Kuningan Madya (Dalam Persiapan)',
      'coordinates': '-6.2185, 106.8302',
      'map_x': 240.0,
      'map_y': 240.0,
      'is_store_open': false,
      'attendance_time': 'Belum Absen / Off',
      'morning_stock_picked': '0 Cup (Belum Ambil)',
      'commission_rate': 1200,
      'cups_sold_today': 0,
      'total_commission': 0,
      'commission_paid': false,
      'cash_in_hand': 0,
      'qris_collected': 0,
      'current_stock': 0,
      'max_capacity': 100,
      'active_orders_count': 0,
      'status': 'OFFLINE (TIDAK JUALAN)',
      'status_color': const Color(0xFF94A3B8),
    },
  ];

  // ===========================================================================
  // 2. DATA PERSEDIAAN GUDANG PUSAT (OWNER INPUT & KONTROL DISTRIBUSI)
  // ===========================================================================
  final List<Map<String, dynamic>> _warehouseStock = [
    {
      'sku': 'PRD-01',
      'name': 'Kopi Susu Gula Aren',
      'category': 'Signature Milk Coffee',
      'cost_price': 7500,
      'sell_price': 18000,
      'stock': 950,
      'reserved': 50,
      'avail': 900,
      'min_limit': 150,
      'status': 'AMAN',
      'color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-02',
      'name': 'Americano Double Shot',
      'category': 'Classic Espresso',
      'cost_price': 4500,
      'sell_price': 15000,
      'stock': 650,
      'reserved': 20,
      'avail': 630,
      'min_limit': 100,
      'status': 'AMAN',
      'color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-03',
      'name': 'Matcha Uji Latte Creamy',
      'category': 'Non-Coffee Premium',
      'cost_price': 9000,
      'sell_price': 22000,
      'stock': 430,
      'reserved': 30,
      'avail': 400,
      'min_limit': 80,
      'status': 'AMAN',
      'color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-04',
      'name': 'Cafe Latte Steam Velvet',
      'category': 'Signature Milk Coffee',
      'cost_price': 8000,
      'sell_price': 20000,
      'stock': 520,
      'reserved': 25,
      'avail': 495,
      'min_limit': 80,
      'status': 'AMAN',
      'color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-05',
      'name': 'Cold Brew Citrus Refresh',
      'category': 'Artisan Brew',
      'cost_price': 8500,
      'sell_price': 22000,
      'stock': 310,
      'reserved': 10,
      'avail': 300,
      'min_limit': 60,
      'status': 'AMAN',
      'color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-06',
      'name': 'Roti Bakar Kaya Butter',
      'category': 'Bakery & Bites',
      'cost_price': 6000,
      'sell_price': 15000,
      'stock': 140,
      'reserved': 20,
      'avail': 120,
      'min_limit': 150,
      'status': 'PERLU RESTOCK',
      'color': const Color(0xFFF59E0B),
    },
  ];

  // Riwayat audit input & pengiriman stok gudang
  final List<Map<String, dynamic>> _stockAuditLogs = [
    {'time': '07:15 WIB', 'action': 'DISTRIBUSI', 'detail': 'Bawaan Pagi GRB-01 (Budi) 120 Cup', 'actor': 'Owner Admin', 'type_color': const Color(0xFF0284C7)},
    {'time': '07:05 WIB', 'action': 'DISTRIBUSI', 'detail': 'Bawaan Pagi GRB-04 (Hendra) 110 Cup', 'actor': 'Owner Admin', 'type_color': const Color(0xFF0284C7)},
    {'time': '06:45 WIB', 'action': 'DISTRIBUSI', 'detail': 'Bawaan Pagi GRB-03 (Siti) 120 Cup', 'actor': 'Owner Admin', 'type_color': const Color(0xFF0284C7)},
    {'time': '06:20 WIB', 'action': 'DISTRIBUSI', 'detail': 'Bawaan Pagi GRB-02 (Ahmad) 100 Cup', 'actor': 'Owner Admin', 'type_color': const Color(0xFF0284C7)},
    {'time': 'Kemarin 21:00', 'action': 'RESTOCK GUDANG', 'detail': 'Roasting Biji Kopi Gayo 500 Porsi Masuk', 'actor': 'Owner Admin', 'type_color': const Color(0xFF10B981)},
  ];

  // ===========================================================================
  // 3. DATA TITIK LOKASI JUALAN & REKOMENDASI BAWAAN PAGI UNTUK TIM
  // ===========================================================================
  final List<Map<String, dynamic>> _availableSpots = [
    {
      'id': 'LOC-01',
      'name': 'Koridor Sudirman - Halte Dukuh Atas',
      'landmark': 'Depan Menara Astra & Akses MRT Dukuh Atas BNI',
      'seller_active': 'Budi Santoso (GRB-01)',
      'status': 'TERISI (ONLINE)',
      'is_occupied': true,
      'morning_stock_quota': '120 Cup (Susu Aren 60, Americano 40, Latte 20)',
      'pedestrian_density': '1.450 org/jam',
      'score': 96.8,
      'weather_note': 'Cerah 31°C (Es Kopi Favorit)',
      'lat_long': '-6.2088, 106.8227',
      'map_x': 180.0,
      'map_y': 160.0,
    },
    {
      'id': 'LOC-02',
      'name': 'Taman Suropati & Taman Kodok Menteng',
      'landmark': 'Ring Lingkar Taman & Komunitas Olahraga Menteng',
      'seller_active': 'Ahmad Fauzi (GRB-02)',
      'status': 'TERISI (ONLINE)',
      'is_occupied': true,
      'morning_stock_quota': '100 Cup (Matcha 40, Susu Aren 30, Roti 30)',
      'pedestrian_density': '480 org/jam',
      'score': 88.5,
      'weather_note': 'Teduh 29°C (Artisan Brew Laris)',
      'lat_long': '-6.1994, 106.8326',
      'map_x': 320.0,
      'map_y': 120.0,
    },
    {
      'id': 'LOC-03',
      'name': 'Pintu Timur Stasiun Juanda Commuter',
      'landmark': 'Keluar Gate Tiket Commuter Line & Halte TransJ',
      'seller_active': 'Hendra Wijaya (GRB-04)',
      'status': 'TERISI (ONLINE)',
      'is_occupied': true,
      'morning_stock_quota': '110 Cup (Americano 50, Susu Aren 40, Cold Brew 20)',
      'pedestrian_density': '1.980 org/jam',
      'score': 93.2,
      'weather_note': 'Padat Komuter Kerja',
      'lat_long': '-6.1668, 106.8312',
      'map_x': 270.0,
      'map_y': 50.0,
    },
    {
      'id': 'LOC-04',
      'name': 'Pasar Senen Blok III & Halte Senen Sentral',
      'landmark': 'Koridor Pintu Masuk Pasar Grosir Blok 3',
      'seller_active': 'Siti Rahmawati (GRB-03)',
      'status': 'TERISI (ONLINE)',
      'is_occupied': true,
      'morning_stock_quota': '120 Cup (Susu Aren 70, Roti 30, Kopi Hitam 20)',
      'pedestrian_density': '850 org/jam',
      'score': 90.0,
      'weather_note': 'Tinggi Belanja Pagi',
      'lat_long': '-6.1744, 106.8432',
      'map_x': 460.0,
      'map_y': 80.0,
    },
    {
      'id': 'LOC-05',
      'name': 'Area Kampus UI Salemba - Gedung Rektorat',
      'landmark': 'Depan Perpustakaan Salemba & Rumah Sakit Cipto',
      'seller_active': 'KOSONG (SIAP DIPILIH)',
      'status': 'TERSEDIA UNTUK TIM',
      'is_occupied': false,
      'morning_stock_quota': '90 Cup (Matcha 35, Aren 35, Cold Brew 20)',
      'pedestrian_density': '720 mhs/jam',
      'score': 87.4,
      'weather_note': 'Potensi Mahasiswa & Dokter',
      'lat_long': '-6.1951, 106.8504',
      'map_x': 490.0,
      'map_y': 150.0,
    },
    {
      'id': 'LOC-06',
      'name': 'Kawasan Perkantoran Kuningan Madya',
      'landmark': 'Plaza Kuningan & Koridor Rasuna Said',
      'seller_active': 'KOSONG (SIAP DIPILIH)',
      'status': 'TERSEDIA UNTUK TIM',
      'is_occupied': false,
      'morning_stock_quota': '100 Cup (Americano 50, Aren 30, Latte 20)',
      'pedestrian_density': '640 kry/jam',
      'score': 84.1,
      'weather_note': 'Jam Istirahat Padat',
      'lat_long': '-6.2185, 106.8302',
      'map_x': 240.0,
      'map_y': 240.0,
    },
  ];

  // ===========================================================================
  // 4. DATA ORDERAN REALTIME & VERIFIKASI QRIS PJP ACQUIRER
  // ===========================================================================
  final List<Map<String, dynamic>> _liveOrders = [
    {
      'id': 'ORD-9042',
      'customer': 'Farhan Maulana',
      'seller': 'Budi Santoso (Sudirman)',
      'items': '1x Cafe Latte + 1x Roti Bakar Kaya',
      'total': 35000,
      'order_status': 'DIPROSES',
      'pay_status': 'LUNAS (QRIS PJP)',
      'pjp_ref': 'QRIS-BCA-920145',
      'time': '13:34 WIB',
      'is_paid': true,
    },
    {
      'id': 'ORD-9041',
      'customer': 'Rani Anggraini',
      'seller': 'Budi Santoso (Sudirman)',
      'items': '2x Kopi Susu Aren (Less Sugar)',
      'total': 36000,
      'order_status': 'SIAP DIAMBIL',
      'pay_status': 'LUNAS (QRIS PJP)',
      'pjp_ref': 'QRIS-GOPAY-849102',
      'time': '13:28 WIB',
      'is_paid': true,
    },
    {
      'id': 'ORD-9040',
      'customer': 'Bagus Prasetyo',
      'seller': 'Hendra Wijaya (Juanda)',
      'items': '1x Americano Double Shot',
      'total': 15000,
      'order_status': 'SELESAI',
      'pay_status': 'LUNAS (CASH KASIR)',
      'pjp_ref': 'CASH-POS-OFFLINE',
      'time': '13:10 WIB',
      'is_paid': true,
    },
    {
      'id': 'ORD-9039',
      'customer': 'Clarissa Olivia',
      'seller': 'Siti Rahmawati (Senen)',
      'items': '2x Matcha Uji Latte Creamy',
      'total': 44000,
      'order_status': 'MENUNGGU BAYAR',
      'pay_status': 'PENDING ACQUIRER',
      'pjp_ref': 'WAITING-WEBHOOK',
      'time': '13:31 WIB',
      'is_paid': false,
    },
    {
      'id': 'ORD-9038',
      'customer': 'Dimas Nugraha',
      'seller': 'Ahmad Fauzi (Suropati)',
      'items': '1x Cold Brew Citrus + 1x Roti Bakar',
      'total': 37000,
      'order_status': 'SELESAI',
      'pay_status': 'LUNAS (QRIS PJP)',
      'pjp_ref': 'QRIS-SHOPEE-554199',
      'time': '12:54 WIB',
      'is_paid': true,
    },
  ];

  // ===========================================================================
  // INTERACTIVE MODAL DIALOGS
  // ===========================================================================

  // MODAL 1: Tambah Akun Petugas Lapangan Baru
  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cartCtrl = TextEditingController(text: 'GRB-0${_staffAccounts.length + 1}');
    final rateCtrl = TextEditingController(text: '1500');
    String selectedRole = 'SELLER_REGULER';
    String defaultSpot = _availableSpots.firstWhere((s) => s['is_occupied'] == false, orElse: () => _availableSpots.first)['name'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 580,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.person_add_alt_1, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tambah Akun Petugas Lapangan Baru', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                          Text('Buat kredensial login & setting komisi tim penjual gerobak', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  const Text('1. Data Pribadi & Kontak Tim:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 10),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Petugas', hintText: 'Contoh: Joko Widodo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline, size: 20))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username Login Aplikasi', hintText: 'Contoh: joko_sudirman', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined, size: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor WhatsApp Aktif', hintText: '0812-xxxx-xxxx', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined, size: 20))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  const Text('2. Penugasan Gerobak, Peran & Komisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: cartCtrl, decoration: const InputDecoration(labelText: 'ID Gerobak Keliling', border: OutlineInputBorder(), prefixIcon: Icon(Icons.storefront_outlined, size: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration: const InputDecoration(labelText: 'Tingkatan / Peran', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'SELLER_LEAD', child: Text('Seller Lead (Senior)')),
                            DropdownMenuItem(value: 'SELLER_REGULER', child: Text('Seller Reguler')),
                            DropdownMenuItem(value: 'SELLER_TRAINEE', child: Text('Seller Trainee (Baru)')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedRole = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: rateCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Rate Komisi Penjualan', prefixText: 'Rp ', suffixText: '/ cup', border: OutlineInputBorder(), helperText: 'Standar Rp 1.500 per cup terjual'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: defaultSpot,
                          decoration: const InputDecoration(labelText: 'Rencana Titik Pagi', border: OutlineInputBorder()),
                          items: _availableSpots.map((s) => DropdownMenuItem(value: s['name'].toString(), child: Text(s['name'].toString(), overflow: TextOverflow.ellipsis))).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => defaultSpot = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 20),
                        SizedBox(width: 10),
                        Expanded(child: Text('Akun yang dibuat akan langsung tersinkron ke aplikasi mobile seller. Petugas login, absen, dan menekan tombol "Buka Jualan" saat siap melayani.', style: TextStyle(fontSize: 11, color: Color(0xFF334155)))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          if (nameCtrl.text.isEmpty) return;
                          final parsedRate = int.tryParse(rateCtrl.text) ?? 1500;
                          setState(() {
                            _staffAccounts.add({
                              'id': 'USR-SLR-0${_staffAccounts.length + 1}',
                              'username': userCtrl.text.isNotEmpty ? userCtrl.text : 'seller_${_staffAccounts.length + 1}',
                              'name': nameCtrl.text,
                              'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '0812-0000-0000',
                              'role': selectedRole,
                              'cart_id': cartCtrl.text,
                              'selected_location': defaultSpot,
                              'coordinates': '-6.2000, 106.8200',
                              'map_x': 200.0 + (_staffAccounts.length * 30),
                              'map_y': 150.0,
                              'is_store_open': false,
                              'attendance_time': 'Belum Absen',
                              'morning_stock_picked': '0 Cup',
                              'commission_rate': parsedRate,
                              'cups_sold_today': 0,
                              'total_commission': 0,
                              'commission_paid': false,
                              'cash_in_hand': 0,
                              'qris_collected': 0,
                              'current_stock': 0,
                              'max_capacity': 100,
                              'active_orders_count': 0,
                              'status': 'OFFLINE (MENUNGGU AKTIVASI)',
                              'status_color': const Color(0xFFF59E0B),
                            });
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF10B981), content: Text('Akun petugas "${nameCtrl.text}" berhasil dibuat!')));
                        },
                        child: const Text('Simpan & Terbitkan Akun', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MODAL 2: Input Stok Masuk Gudang Pusat oleh Owner/Admin
  void _showAddWarehouseStockModal() {
    String selectedSku = _warehouseStock.first['sku'];
    final qtyCtrl = TextEditingController(text: '100');
    final batchCtrl = TextEditingController(text: 'BATCH-${DateTime.now().month}${DateTime.now().day}-GAYO');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.add_business, color: Color(0xFF10B981), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Input Stok Baru Gudang Pusat', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                          Text('Catat pasokan roasting biji kopi & bahan baku baru masuk', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  const Text('Pilih Produk Kopi / Bahan Baku:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSku,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _warehouseStock.map((w) {
                      return DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['sku']} • ${w['name']} (Sisa Fisik: ${w['avail']} cup)'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSku = val);
                    },
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Jumlah Cup / Porsi Masuk', hintText: '100', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2_outlined, size: 20)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: batchCtrl,
                          decoration: const InputDecoration(labelText: 'Nomor Batch / Roasting', border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code, size: 20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Text('💡 Stok yang diinput langsung menambah kapasitas siap alokasi gudang pusat dan dapat segera dibagikan ke gerobak seller.', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          final addQty = int.tryParse(qtyCtrl.text) ?? 0;
                          if (addQty <= 0) return;
                          setState(() {
                            for (var item in _warehouseStock) {
                              if (item['sku'] == selectedSku) {
                                item['stock'] = (item['stock'] as int) + addQty;
                                item['avail'] = (item['avail'] as int) + addQty;
                                item['status'] = 'AMAN';
                                item['color'] = const Color(0xFF10B981);
                                _stockAuditLogs.insert(0, {
                                  'time': 'Baru Saja',
                                  'action': 'RESTOCK GUDANG',
                                  'detail': '+ $addQty Cup ${item['name']} (${batchCtrl.text})',
                                  'actor': 'Owner Admin',
                                  'type_color': const Color(0xFF10B981),
                                });
                              }
                            }
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF10B981), content: Text('Berhasil menambahkan $addQty cup ke stok gudang pusat!')));
                        },
                        child: const Text('Simpan Stok Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MODAL 3: Bagi Stok Bawaan Pagi ke Gerobak Petugas
  void _showDistributeMorningStockModal() {
    String selectedSellerId = _staffAccounts.first['id'];
    String selectedSku = _warehouseStock.first['sku'];
    final qtyCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(28),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF0284C7), size: 24),
                      ),
                      const SizedBox(width: 14),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Distribusi / Bagi Stok Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                          Text('Kirim porsi kopi dari gudang pusat ke gerobak seller', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 18),

                  const Text('Pilih Gerobak & Petugas Penerima:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSellerId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _staffAccounts.map((s) {
                      return DropdownMenuItem(value: s['id'].toString(), child: Text('${s['name']} • ${s['cart_id']} (Sisa: ${s['current_stock']} cup)'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSellerId = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Pilih Menu Produk dari Gudang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSku,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _warehouseStock.map((w) {
                      return DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['name']} (Sedia Gudang: ${w['avail']} cup)'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSku = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Cup yang Dibawa', hintText: 'Contoh: 30', border: OutlineInputBorder(), prefixIcon: Icon(Icons.coffee, size: 20)),
                  ),
                  const SizedBox(height: 22),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          final qty = int.tryParse(qtyCtrl.text) ?? 0;
                          if (qty <= 0) return;

                          setState(() {
                            // Potong stok gudang
                            for (var w in _warehouseStock) {
                              if (w['sku'] == selectedSku) {
                                if ((w['avail'] as int) < qty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Stok gudang tidak mencukupi!')));
                                  return;
                                }
                                w['avail'] = (w['avail'] as int) - qty;
                              }
                            }
                            // Tambah stok ke gerobak seller
                            for (var s in _staffAccounts) {
                              if (s['id'] == selectedSellerId) {
                                s['current_stock'] = (s['current_stock'] as int) + qty;
                                s['morning_stock_picked'] = '${s['current_stock']} Cup (Telah Diupdate)';
                                if (s['status'] == 'STOK MENIPIS') {
                                  s['status'] = 'AKTIF JUALAN';
                                  s['status_color'] = const Color(0xFF10B981);
                                }
                                _stockAuditLogs.insert(0, {
                                  'time': 'Baru Saja',
                                  'action': 'DISTRIBUSI',
                                  'detail': 'Kirim $qty Cup ke ${s['name']} (${s['cart_id']})',
                                  'actor': 'Owner Admin',
                                  'type_color': const Color(0xFF0284C7),
                                });
                              }
                            }
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Alokasi stok berhasil dikirim ke gerobak petugas!')));
                        },
                        child: const Text('Kirim ke Gerobak', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // MODAL 4: Pencairan Komisi Petugas
  void _showDisburseCommissionModal(Map<String, dynamic> staff) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.payments_outlined, color: Color(0xFF10B981)),
            const SizedBox(width: 10),
            Text('Pencairan Komisi: ${staff['name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Penjualan Hari Ini: ${staff['cups_sold_today']} Cup', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Rate Komisi: Rp ${staff['commission_rate']} / cup', style: const TextStyle(color: Color(0xFF64748B))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Hak Komisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Text(_formatRupiah(staff['total_commission'] as num), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF047857))),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text('Metode Pencairan: Potong dari Cash Kasir Lapangan atau Transfer Bank.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                staff['commission_paid'] = true;
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF10B981), content: Text('Komisi ${_formatRupiah(staff['total_commission'] as num)} untuk ${staff['name']} telah dicairkan!')));
            },
            child: const Text('Konfirmasi & Cairkan'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // ROOT BUILD METHOD
  // ===========================================================================
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F5F9), // Slate 100 soft canvas
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sleek Enterprise Sidebar
          _buildSidebar(),

          // 2. Main Executive Workspace
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(28),
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

  // ===========================================================================
  // SIDEBAR NAVIGATION
  // ===========================================================================
  Widget _buildSidebar() {
    final activeCount = _staffAccounts.where((s) => s['is_store_open'] == true).length;
    final totalCups = _staffAccounts.fold(0, (acc, s) => acc + (s['cups_sold_today'] as int));

    return Container(
      width: 285,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.2)),
      ),
      child: Column(
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFD97706), Color(0xFFF59E0B)]),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: const Color(0xFFD97706).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: const Icon(Icons.coffee_maker, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KopiCerdas AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 0.3)),
                      Text('OWNER EXECUTIVE HQ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),

          // Navigation Links
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 14),
              children: [
                _sidebarCategoryHeader('MONITORING ARMADA & TIM'),
                _sidebarNavItem(0, Icons.dashboard_outlined, 'Executive Dashboard'),
                _sidebarNavItem(1, Icons.badge_outlined, 'Petugas & Akun Lapangan', badge: '$activeCount Aktif', badgeColor: const Color(0xFF10B981)),
                _sidebarNavItem(2, Icons.map_outlined, 'Peta GPS & Lapak Titik', badge: 'Live GPS', badgeColor: const Color(0xFF0284C7)),
                _sidebarNavItem(3, Icons.monetization_on_outlined, 'Sistem Komisi Penjualan', badge: 'Rp/Cup', badgeColor: const Color(0xFF8B5CF6)),

                const SizedBox(height: 14),
                _sidebarCategoryHeader('GUDANG & LOGISTIK PUSAT'),
                _sidebarNavItem(4, Icons.warehouse_outlined, 'Stok Gudang Pusat (Owner)'),
                _sidebarNavItem(5, Icons.auto_awesome_outlined, 'AI Demand & Alokasi (MILP)', badge: 'Optimal', badgeColor: const Color(0xFFF59E0B)),
                _sidebarNavItem(6, Icons.receipt_long_outlined, 'Live Orders & QRIS PJP', badge: '${_liveOrders.length} Trx', badgeColor: const Color(0xFF38BDF8)),
              ],
            ),
          ),

          // Mini Fleet Status Quick Card in Sidebar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text('Jaringan Gerobak Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('$activeCount dari ${_staffAccounts.length} Gerobak Online Jualan\n$totalCups Cup Telah Terjual Hari Ini', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, height: 1.4)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD97706),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _showDistributeMorningStockModal,
                          child: const Text('Bagi Stok', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE2E8F0),
                            side: const BorderSide(color: Color(0xFF475569)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _showAddStaffModal,
                          child: const Text('+ Akun', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
    );
  }

  Widget _sidebarNavItem(int index, IconData icon, String title, {String? badge, Color? badgeColor}) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: const Color(0xFF38BDF8).withOpacity(0.35)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8)),
              const SizedBox(width: 12),
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
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? const Color(0xFF38BDF8)).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge, style: TextStyle(color: badgeColor ?? const Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TOP BAR HEADER
  // ===========================================================================
  Widget _buildTopHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_getModuleTitle(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(_getModuleSubtitle(), style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            ],
          ),
          const Spacer(),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF0F172A), content: Text('Sinkronisasi realtime: Posisi GPS, Penjualan Kasir & Orderan diperbarui.')));
            },
            icon: const Icon(Icons.sync, size: 16),
            label: const Text('Refresh Realtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Color(0xFFD97706),
                  child: Text('OW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                ),
                SizedBox(width: 8),
                Text('Owner Pusat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
              ],
            ),
          )
        ],
      ),
    );
  }

  String _getModuleTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Executive Dashboard & Omzet Konsolidasi';
      case 1: return 'Manajemen Akun Petugas Lapangan & Kontrol Absensi';
      case 2: return 'Peta Geospasial Realtime Posisi Tim & Pilihan Lapak';
      case 3: return 'Sistem Komisi Penjualan Tim Lapangan';
      case 4: return 'Input Stok Gudang Pusat (Owner) & Pembagian Bawaan Pagi';
      case 5: return 'AI Demand Forecasting & Optimasi Alokasi (MILP Solver)';
      case 6: return 'Monitoring Live Order & Verifikasi QRIS PJP';
      default: return 'KopiCerdas AI Owner Suite';
    }
  }

  String _getModuleSubtitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Ringkasan total pendapatan, margin laba bersih, dan performa seluruh gerobak';
      case 1: return 'Atur kredensial login, nomor HP, status buka toko, absensi, dan rate komisi petugas';
      case 2: return 'Pantau titik GPS realtime tim keliling dan kuota bawaan pagi lokasi tujuan';
      case 3: return 'Rekap komisi per cup kopi terjual, omzet dihasilkan, dan status pencairan dana';
      case 4: return 'Owner menginput pasokan masuk dan mendistribusikan kuota stok ke gerobak';
      case 5: return 'Rekomendasi alokasi kuota cerdas untuk mencegah stock-out dan maksimalkan profit';
      case 6: return 'Validasi transaksi pre-order pelanggan & penyelesaian pembayaran QRIS resmi';
      default: return 'Portal Kendali Pemilik Usaha Jaringan Gerobak Kopi';
    }
  }

  Widget _buildCurrentModuleView() {
    switch (_selectedNavIndex) {
      case 0: return _buildExecutiveDashboard();
      case 1: return _buildStaffAccountManagementView();
      case 2: return _buildLiveMapGeospatialView();
      case 3: return _buildCommissionSystemView();
      case 4: return _buildWarehouseManagementView();
      case 5: return _buildAiOptimizationView();
      case 6: return _buildLiveTransactionsOrdersView();
      default: return _buildExecutiveDashboard();
    }
  }

  // ===========================================================================
  // MODULE 0: EXECUTIVE DASHBOARD
  // ===========================================================================
  Widget _buildExecutiveDashboard() {
    final num totalCash = _staffAccounts.fold(0, (acc, s) => acc + (s['cash_in_hand'] as num));
    final num totalQris = _staffAccounts.fold(0, (acc, s) => acc + (s['qris_collected'] as num));
    final num totalOmzet = totalCash + totalQris;
    final num totalCups = _staffAccounts.fold(0, (acc, s) => acc + (s['cups_sold_today'] as num));
    final num totalKomisi = _staffAccounts.fold(0, (acc, s) => acc + (s['total_commission'] as num));
    final num netProfit = (totalOmzet * 0.58).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. KPI Metric Cards
        Row(
          children: [
            Expanded(child: _kpiCard('Omzet Konsolidasi Hari Ini', _formatRupiah(totalOmzet), '+24.5% vs Kemarin', Icons.trending_up, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Estimasi Laba Bersih', _formatRupiah(netProfit), 'Margin Bersih 58.0%', Icons.account_balance_wallet_outlined, const Color(0xFF0284C7))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Cup Terjual', '$totalCups Cup', '${_staffAccounts.where((s) => s['is_store_open'] == true).length} Gerobak Aktif', Icons.coffee, const Color(0xFFD97706))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Komisi Petugas', _formatRupiah(totalKomisi), 'Insentif Siap Dicairkan', Icons.military_tech_outlined, const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 24),

        // 2. Urgent Realtime Alert Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 26),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERINGATAN STOK MENIPIS: Gerobak 04 (Hendra - Stasiun Juanda) Sisa 15 Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF92400E))),
                    SizedBox(height: 4),
                    Text('Arus komuter jam siang sangat tinggi. Estimasi habis dalam 25 menit. Segera alokasikan stok tambahan dari gudang pusat.', style: TextStyle(color: Color(0xFFB45309), fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _showDistributeMorningStockModal,
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Kirim Stok Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 3. Mini Analytics Graph & Split Breakdown
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Penjualan per Gerobak Visual Bar
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Performa Penjualan Tiap Gerobak Hari Ini', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                        Text('Target: 100 cup/gerobak', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    for (final staff in _staffAccounts) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${staff['name']} (${staff['cart_id']})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF334155))),
                                Text('${staff['cups_sold_today']} Cup (${((staff['cups_sold_today'] as int) / (staff['max_capacity'] as int) * 100).toStringAsFixed(0)}%)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: staff['status_color'])),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ((staff['cups_sold_today'] as int) / (staff['max_capacity'] as int)).clamp(0.0, 1.0),
                                minHeight: 8,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>(staff['status_color']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 20),

            // Kas Masuk: Cash Fisik vs QRIS Digital
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Komposisi Kas Masuk Lapangan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_2, color: Color(0xFF0284C7), size: 18),
                              SizedBox(width: 6),
                              Text('QRIS PJP Acquirer (Non-Tunai)', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(_formatRupiah(totalQris), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('${((totalQris / (totalOmzet == 0 ? 1 : totalOmzet)) * 100).toStringAsFixed(1)}% dari total omzet • Langsung masuk rekening pusat', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 6),
                              Text('Uang Tunai Kasir (CASH Fisik)', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(_formatRupiah(totalCash), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          const Text('Disetor oleh petugas saat tutup toko di akhir shift', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 4. Live Staff Summary Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Status Petugas Lapangan Yang Sedang Aktif Jualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('Petugas yang sudah absen dan menekan "Buka Toko" akan muncul online di peta & kasir POS.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => setState(() => _selectedNavIndex = 1),
                    icon: const Icon(Icons.manage_accounts, size: 16),
                    label: const Text('Kelola Semua Akun Petugas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _buildStaffTableSummary(),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MODULE 1: MANAJEMEN AKUN PETUGAS LAPANGAN & KONTROL ABSENSI
  // ===========================================================================
  Widget _buildStaffAccountManagementView() {
    final filteredStaff = _staffAccounts.where((s) {
      if (_staffSearchQuery.isEmpty) return true;
      final q = _staffSearchQuery.toLowerCase();
      return s['name'].toString().toLowerCase().contains(q) ||
          s['username'].toString().toLowerCase().contains(q) ||
          s['cart_id'].toString().toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar & Search
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari nama, user, atau gerobak...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (val) => setState(() => _staffSearchQuery = val),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: _showAddStaffModal,
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Tambah Akun Petugas Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 22),

        // Cards Grid of Staff Accounts
        Wrap(
          spacing: 18,
          runSpacing: 18,
          children: [
            for (final s in filteredStaff) ...[
              Builder(builder: (context) {
                final bool isOpen = s['is_store_open'] == true;
                return Container(
                  width: 380,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isOpen ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1), width: isOpen ? 1.2 : 1.5),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Card: Avatar & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: isOpen ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                child: Text(s['name'].toString().substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                  Text('@${s['username']} • ${s['role']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          _statusBadge(isOpen ? 'AKTIF JUALAN' : 'OFFLINE', isOpen ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1),
                      const SizedBox(height: 12),

                      _infoRow(Icons.phone_outlined, 'Kontak WhatsApp', s['phone']),
                      _infoRow(Icons.storefront_outlined, 'Unit Gerobak', s['cart_id']),
                      _infoRow(Icons.location_on_outlined, 'Lapak Terpilih', s['selected_location']),
                      _infoRow(Icons.access_time_outlined, 'Absen & Buka Toko', s['attendance_time']),
                      _infoRow(Icons.inventory_2_outlined, 'Bawaan Pagi', s['morning_stock_picked']),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sisa Stok Gerobak:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Text('${s['current_stock']} / ${s['max_capacity']} Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: s['status_color'])),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Terjual Hari Ini:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Text('${s['cups_sold_today']} Cup', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF10B981))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Akumulasi Komisi:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Text('${_formatRupiah(s['total_commission'] as num)} (@Rp ${s['commission_rate']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5CF6))),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Uang Fisik Kasir (CASH):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                                Text(_formatRupiah(s['cash_in_hand'] as num), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Interactive Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isOpen ? Colors.red.shade300 : Colors.green.shade400),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 10),
                              ),
                              onPressed: () {
                                setState(() {
                                  s['is_store_open'] = !isOpen;
                                  s['status'] = s['is_store_open'] ? 'AKTIF JUALAN' : 'OFFLINE (TIDAK JUALAN)';
                                  s['status_color'] = s['is_store_open'] ? const Color(0xFF10B981) : const Color(0xFF94A3B8);
                                  if (s['is_store_open']) {
                                    s['attendance_time'] = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} WIB (Manual On)';
                                  }
                                });
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status ${s['name']} diubah menjadi ${s['is_store_open'] ? 'ONLINE (BUKA)' : 'OFFLINE (TUTUP)'}')));
                              },
                              child: Text(isOpen ? 'Set Toko Tutup' : 'Set Buka Jualan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOpen ? Colors.red : Colors.green)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                              onPressed: _showDistributeMorningStockModal,
                              child: const Text('Beri Stok', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ],
    );
  }

  // ===========================================================================
  // MODULE 2: PETA GEOSPASIAL REALTIME POSISI TIM & LOKASI
  // ===========================================================================
  Widget _buildLiveMapGeospatialView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subheader Info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Radar Geospasial Gerobak & Lapak Titik Strategis', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Petugas yang telah menekan "Buka Toko" memancarkan sinyal GPS aktif realtime di peta Jabodetabek.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, size: 16, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text('4 Sinyal GPS Aktif Terpantau', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Visual Stylized Map Frame
        Container(
          width: double.infinity,
          height: 420,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Dark map base
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              // Map Gridlines & Road Aesthetics
              Positioned.fill(
                child: CustomPaint(
                  painter: _StylizedMapBackgroundPainter(),
                ),
              ),

              // Interactive GPS Pins for Staff
              for (final staff in _staffAccounts) ...[
                if (staff['is_store_open'] == true) ...[
                  Positioned(
                    left: staff['map_x'] as double,
                    top: staff['map_y'] as double,
                    child: _liveGpsMarker(
                      title: staff['name'],
                      subtitle: '${staff['cart_id']} • Sisa: ${staff['current_stock']} Cup',
                      statusColor: staff['status_color'],
                      isAlert: (staff['current_stock'] as int) < 20,
                    ),
                  ),
                ],
              ],

              // Empty Spot Candidates ready to be picked
              for (final spot in _availableSpots) ...[
                if (spot['is_occupied'] == false) ...[
                  Positioned(
                    left: spot['map_x'] as double,
                    top: spot['map_y'] as double,
                    child: _emptySpotMarker(
                      title: 'Lapak Kosong: ${spot['name']}',
                      subtitle: 'Kuota: ${spot['morning_stock_quota']}',
                      score: spot['score'].toString(),
                    ),
                  ),
                ],
              ],

              // Map Overlay Controls & Legend
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                      SizedBox(width: 6),
                      Text('Gerobak Aktif Jualan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFFEF4444), size: 10),
                      SizedBox(width: 6),
                      Text('Stok Kritis (<20 cup)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFFF59E0B), size: 10),
                      SizedBox(width: 6),
                      Text('Lapak Kosong Bisa Dipilih Tim', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF334155))),
                  child: const Text('KORIDOR TRANSIT JABODETABEK', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.1)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Catalog of Spots & Morning Stock Quotas
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Katalog Lapak Jualan & Panduan Kuota Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              const Text('Petugas memilih lapak ini di aplikasi kasir. Sistem menampilkan panduan berapa porsi dan varian yang harus diambil dari gudang pusat.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              const SizedBox(height: 16),

              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(3),
                  4: FlexColumnWidth(1.5),
                  5: FlexColumnWidth(1.2),
                  6: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('ID Lapak'),
                      _th('Area & Landmark Strategis'),
                      _th('Petugas Menempati'),
                      _th('Rekomendasi Bawaan Pagi (Porsi)'),
                      _th('Kepadatan Pejalan'),
                      _th('Skor AI'),
                      _th('Status'),
                    ],
                  ),
                  for (final spot in _availableSpots)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(spot['id']),
                        _td('${spot['name']}\n${spot['landmark']}', bold: true),
                        _td(spot['seller_active']),
                        _td(spot['morning_stock_quota'], color: const Color(0xFF0284C7), bold: true),
                        _td('${spot['pedestrian_density']}\n${spot['weather_note']}'),
                        _td('${spot['score']} / 100', bold: true),
                        _statusBadge(spot['is_occupied'] ? 'TERISI' : 'BISA DIPILIH', spot['is_occupied'] ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
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

  Widget _liveGpsMarker({required String title, required String subtitle, required Color statusColor, bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.coffee, color: isAlert ? Colors.white : statusColor, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
              Text(subtitle, style: TextStyle(color: isAlert ? Colors.white70 : const Color(0xFF94A3B8), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptySpotMarker({required String title, required String subtitle, required String score}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_location_alt_outlined, color: Color(0xFFD97706), size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11)),
              Text('$subtitle • Skor: $score', style: const TextStyle(color: Color(0xFF64748B), fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // MODULE 3: SISTEM KOMISI PENJUALAN TIM LAPANGAN
  // ===========================================================================
  Widget _buildCommissionSystemView() {
    final num totalKomisi = _staffAccounts.fold(0, (acc, s) => acc + (s['total_commission'] as num));
    final num totalCups = _staffAccounts.fold(0, (acc, s) => acc + (s['cups_sold_today'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Highlight Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekap & Pencairan Komisi Penjualan Per Cup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Sistem komisi otomatis: Total komisi dihitung dari jumlah cup terjual dikalikan rate per cup masing-masing seller.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
              child: Text('Total Insentif Hari Ini: ${_formatRupiah(totalKomisi)} ($totalCups Cup)', style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.6),
              5: FlexColumnWidth(2.2),
              6: FlexColumnWidth(1.5),
              7: FlexColumnWidth(1.3),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Petugas'),
                  _th('Nama Petugas Lapangan'),
                  _th('Cup Terjual'),
                  _th('Rate / Cup'),
                  _th('Total Komisi'),
                  _th('Omzet Dihasilkan (Cash / QRIS)'),
                  _th('Status Pencairan'),
                  _th('Aksi Owner'),
                ],
              ),
              for (final s in _staffAccounts)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(s['id']),
                    _td('${s['name']}\n${s['cart_id']}', bold: true),
                    _td('${s['cups_sold_today']} Cup', bold: true),
                    _td('Rp ${s['commission_rate']} / cup'),
                    _td(_formatRupiah(s['total_commission'] as num), bold: true, color: const Color(0xFF10B981)),
                    _td('Cash: ${_formatRupiah(s['cash_in_hand'] as num)}\nQRIS: ${_formatRupiah(s['qris_collected'] as num)}'),
                    _statusBadge(
                      s['commission_paid'] == true
                          ? 'SUDAH DICAIRKAN'
                          : ((s['cups_sold_today'] as int) > 0 ? 'SIAP DICAIRKAN' : 'BELUM ADA PENJUALAN'),
                      s['commission_paid'] == true
                          ? const Color(0xFF0284C7)
                          : ((s['cups_sold_today'] as int) > 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: s['commission_paid'] == true ? const Color(0xFF94A3B8) : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        onPressed: s['commission_paid'] == true ? null : () => _showDisburseCommissionModal(s),
                        child: Text(s['commission_paid'] == true ? 'Selesai' : 'Cairkan', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
  // MODULE 4: INPUT STOK GUDANG PUSAT (OWNER) & PEMBAGIAN BAWAAN PAGI
  // ===========================================================================
  Widget _buildWarehouseManagementView() {
    final filteredWarehouse = _warehouseStock.where((w) {
      if (_warehouseSearchQuery.isEmpty) return true;
      final q = _warehouseSearchQuery.toLowerCase();
      return w['name'].toString().toLowerCase().contains(q) || w['sku'].toString().toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Action Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 300,
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Cari SKU atau nama menu...',
                  prefixIcon: Icon(Icons.search, size: 20),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
                  fillColor: Colors.white,
                  filled: true,
                ),
                onChanged: (val) => setState(() => _warehouseSearchQuery = val),
              ),
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _showAddWarehouseStockModal,
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: const Text('Input Stok Baru Gudang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  onPressed: _showDistributeMorningStockModal,
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Bagi Stok ke Gerobak', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Warehouse Catalog Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Katalog Persediaan Gudang Pusat (Owner/Admin)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.8),
                  3: FlexColumnWidth(1.5),
                  4: FlexColumnWidth(1.5),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.3),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('SKU'),
                      _th('Nama Menu Kopi / Bahan'),
                      _th('Kategori'),
                      _th('Stok Fisik Total'),
                      _th('Reservasi Pre-Order'),
                      _th('Siap Dibagikan Pagi'),
                      _th('Status'),
                    ],
                  ),
                  for (final w in filteredWarehouse)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(w['sku']),
                        _td('${w['name']}\nHarga: ${_formatRupiah(w['sell_price'] as num)}', bold: true),
                        _td(w['category']),
                        _td('${w['stock']} Cup'),
                        _td('${w['reserved']} Cup (Tahan)'),
                        _td('${w['avail']} Cup', bold: true, color: const Color(0xFF0284C7)),
                        _statusBadge(w['status'], w['color']),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Audit Trail Riwayat Distribusi
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF0F172A), size: 20),
                  SizedBox(width: 8),
                  Text('Log Audit Mutasi Stok Gudang Pusat', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 14),
              for (final log in _stockAuditLogs) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: (log['type_color'] as Color).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
                        child: Text(log['action'], style: TextStyle(color: log['type_color'] as Color, fontWeight: FontWeight.bold, fontSize: 10)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(log['detail'], style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF334155)))),
                      Text(log['actor'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(width: 14),
                      Text(log['time'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F172A))),
                    ],
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MODULE 5: AI DEMAND & ALOKASI OPTIMASI (MILP)
  // ===========================================================================
  Widget _buildAiOptimizationView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Demand Forecasting & Mixed-Integer Linear Programming (MILP)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Optimalisasi matematis alokasi stok bawaan pagi gerobak berdasarkan histori penjualan, cuaca, dan batasan kapasitas.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
              child: const Text('Solver: OR-Tools MILP_OPTIMAL', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Dark Luxury Projection Banner
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 14)],
          ),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROYEKSI LABA BERSIH MAKSIMAL DENGAN ALOKASI AI', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    SizedBox(height: 8),
                    Text('Rp 24.850.000 / Hari', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Menghindari kerugian stock-out senilai Rp 3.200.000 pada jam sibuk perkantoran (07.30 - 09.30 WIB)', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: const Color(0xFF0F172A), padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menjalankan kembali solver matematis MILP dengan parameter cuaca & trafik terbaru...')));
                },
                icon: const Icon(Icons.bolt, size: 18),
                label: const Text('Re-Calculate Optimization', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // AI Recommendation Action Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.6),
              5: FlexColumnWidth(3),
              6: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Prioritas'),
                  _th('Titik Gerobak Seller'),
                  _th('Varian Menu Kopi'),
                  _th('Stok Sekarang'),
                  _th('Saran AI (Bawaan)'),
                  _th('Rasionalisasi Keputusan AI'),
                  _th('Aksi Owner'),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                children: [
                  _statusBadge('URGENT', const Color(0xFFEF4444)),
                  _td('Koridor Sudirman (Budi Santoso)', bold: true),
                  _td('Kopi Susu Gula Aren'),
                  _td('42 Cup'),
                  _td('80 Cup (+38 Cup)', bold: true, color: const Color(0xFF10B981)),
                  _td('Lonjakan komuter jam makan siang (11.45 - 13.30). Stok saat ini berisiko stock-out pukul 12.15.', italic: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      onPressed: _showDistributeMorningStockModal,
                      child: const Text('Terapkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                children: [
                  _statusBadge('HIGH', const Color(0xFFF59E0B)),
                  _td('Stasiun Juanda (Hendra Wijaya)', bold: true),
                  _td('Americano Double Shot'),
                  _td('15 Cup'),
                  _td('50 Cup (+35 Cup)', bold: true, color: const Color(0xFF10B981)),
                  _td('Pekerja komuter kereta sore membutuhkan kafein segar. Margin kotor tinggi Rp 10.500/cup.', italic: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      onPressed: _showDistributeMorningStockModal,
                      child: const Text('Terapkan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
  // MODULE 6: MONITORING LIVE ORDER & VERIFIKASI QRIS PJP
  // ===========================================================================
  Widget _buildLiveTransactionsOrdersView() {
    final filteredOrders = _liveOrders.where((o) {
      if (_orderStatusFilter == 'ALL') return true;
      if (_orderStatusFilter == 'PAID') return o['is_paid'] == true;
      if (_orderStatusFilter == 'PENDING') return o['is_paid'] == false;
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _filterChip('Semua Order (${_liveOrders.length})', 'ALL'),
                const SizedBox(width: 8),
                _filterChip('Lunas Terverifikasi', 'PAID'),
                const SizedBox(width: 8),
                _filterChip('Pending Pembayaran', 'PENDING'),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 6),
                  Text('Webhook PJP Terhubung', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2.2),
              3: FlexColumnWidth(2.8),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.6),
              7: FlexColumnWidth(1.8),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Order ID'),
                  _th('Nama Pelanggan'),
                  _th('Gerobak Tujuan'),
                  _th('Detail Item Pesanan'),
                  _th('Nominal'),
                  _th('Status Order'),
                  _th('Status Bayar'),
                  _th('PJP Reference'),
                ],
              ),
              for (final o in filteredOrders)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(o['id']),
                    _td('${o['customer']}\n${o['time']}', bold: true),
                    _td(o['seller']),
                    _td(o['items']),
                    _td(_formatRupiah(o['total'] as num), bold: true),
                    _statusBadge(o['order_status'], const Color(0xFF0284C7)),
                    _statusBadge(o['pay_status'], o['is_paid'] == true ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    _td(o['pjp_ref'], italic: true),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String value) {
    final isSelected = _orderStatusFilter == value;
    return InkWell(
      onTap: () => setState(() => _orderStatusFilter = value),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFCBD5E1)),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF475569), fontWeight: FontWeight.bold, fontSize: 12)),
      ),
    );
  }

  // ===========================================================================
  // SUB WIDGET HELPERS
  // ===========================================================================
  Widget _buildStaffTableSummary() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.6),
        2: FlexColumnWidth(1.6),
        3: FlexColumnWidth(1.4),
        4: FlexColumnWidth(1.6),
        5: FlexColumnWidth(1.6),
        6: FlexColumnWidth(1.3),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
          children: [
            _th('Petugas Seller'),
            _th('Titik Gerobak & Lapak'),
            _th('Absensi Masuk'),
            _th('Terjual'),
            _th('Sisa Stok'),
            _th('Komisi Akumulasi'),
            _th('Status Toko'),
          ],
        ),
        for (final s in _staffAccounts)
          TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
            children: [
              _td('${s['name']}\n@${s['username']}', bold: true),
              _td('${s['cart_id']}\n${s['selected_location']}'),
              _td(s['attendance_time']),
              _td('${s['cups_sold_today']} Cup', bold: true),
              _td('${s['current_stock']} / ${s['max_capacity']} Cup', bold: true, color: s['status_color']),
              _td(_formatRupiah(s['total_commission'] as num), bold: true, color: const Color(0xFF8B5CF6)),
              _statusBadge(s['is_store_open'] == true ? 'BUKA' : 'TUTUP', s['status_color']),
            ],
          ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _kpiCard(String title, String value, String subtext, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
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

  Widget _th(String text) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF475569))));
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
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
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
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }
}

// =============================================================================
// STYLIZED VECTOR MAP PAINTER (DARK TRANSIT GRIDLINES & ROADS)
// =============================================================================
class _StylizedMapBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintGrid = Paint()
      ..color = const Color(0xFF1E293B).withOpacity(0.4)
      ..strokeWidth = 1.0;

    // Draw coordinate gridlines
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paintGrid);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paintGrid);
    }

    // Draw stylized transit highways/avenues
    final roadPaint = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.7)
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round;

    final roadSecondary = Paint()
      ..color = const Color(0xFF334155).withOpacity(0.5)
      ..strokeWidth = 4.0;

    // Sudirman - Thamrin main avenue
    canvas.drawLine(const Offset(160, 0), const Offset(200, 420), roadPaint);
    // Rasuna Said Kuningan
    canvas.drawLine(const Offset(240, 60), const Offset(250, 420), roadSecondary);
    // Menteng - Salemba crossing
    canvas.drawLine(const Offset(60, 160), const Offset(700, 150), roadPaint);
    // Juanda - Senen commuter rail route
    canvas.drawLine(const Offset(180, 50), const Offset(580, 90), roadSecondary);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
