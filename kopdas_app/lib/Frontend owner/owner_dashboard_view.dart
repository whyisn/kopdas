import 'package:flutter/material.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  int _selectedNavIndex = 0;

  // --- 1. DATA PETUGAS LAPANGAN & AKUN (LENGKAP DENGAN ABSENSI, STATUS ON/OFF, KOMISI, TITIK LOKASI) ---
  final List<Map<String, dynamic>> _staffAccounts = [
    {
      'id': 'USR-SLR-01',
      'username': 'budi_sudirman',
      'name': 'Budi Santoso',
      'phone': '0812-8821-9901',
      'role': 'SELLER_LEAD',
      'cart_id': 'GRB-01 (Sudirman)',
      'selected_location': 'Halte Dukuh Atas Sudirman (Pintu Barat)',
      'coordinates': '-6.2088, 106.8227',
      'is_store_open': true, // Petugas sudah klik 'Buka Jualan' di app seller
      'attendance_time': '06:15 WIB (On-Time)',
      'morning_stock_picked': '120 Cup (Lengkap)',
      'commission_rate': 1500, // Rp 1.500 per cup terjual
      'cups_sold_today': 142,
      'total_commission': 'Rp 213.000',
      'cash_in_hand': 'Rp 900.000',
      'qris_collected': 'Rp 1.940.000',
      'current_stock': '42 / 120 Cup',
      'active_orders_count': 3,
      'status': 'AKTIF JUALAN',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'USR-SLR-02',
      'username': 'ahmad_suropati',
      'name': 'Ahmad Fauzi',
      'phone': '0813-1102-4451',
      'role': 'SELLER_REGULER',
      'cart_id': 'GRB-02 (Suropati)',
      'selected_location': 'Taman Suropati & Taman Kodok Menteng',
      'coordinates': '-6.1994, 106.8326',
      'is_store_open': true,
      'attendance_time': '13:45 WIB (On-Time)',
      'morning_stock_picked': '100 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 68,
      'total_commission': 'Rp 102.000',
      'cash_in_hand': 'Rp 520.000',
      'qris_collected': 'Rp 900.000',
      'current_stock': '28 / 100 Cup',
      'active_orders_count': 1,
      'status': 'AKTIF JUALAN',
      'color': const Color(0xFF10B981),
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
      'is_store_open': true,
      'attendance_time': '05:20 WIB (On-Time)',
      'morning_stock_picked': '120 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 95,
      'total_commission': 'Rp 142.500',
      'cash_in_hand': 'Rp 640.000',
      'qris_collected': 'Rp 1.340.000',
      'current_stock': '35 / 120 Cup',
      'active_orders_count': 2,
      'status': 'AKTIF JUALAN',
      'color': const Color(0xFF10B981),
    },
    {
      'id': 'USR-SLR-04',
      'username': 'hendra_juanda',
      'name': 'Hendra Wijaya',
      'phone': '0821-7781-3312',
      'role': 'SELLER_REGULER',
      'cart_id': 'GRB-04 (Juanda)',
      'selected_location': 'Pintu Timur Stasiun Commuter Juanda',
      'coordinates': '-6.1668, 106.8312',
      'is_store_open': true,
      'attendance_time': '05:50 WIB (On-Time)',
      'morning_stock_picked': '110 Cup (Lengkap)',
      'commission_rate': 1500,
      'cups_sold_today': 118,
      'total_commission': 'Rp 177.000',
      'cash_in_hand': 'Rp 780.000',
      'qris_collected': 'Rp 1.670.000',
      'current_stock': '15 / 110 Cup',
      'active_orders_count': 4,
      'status': 'PERLU RESTOCK',
      'color': const Color(0xFFEF4444),
    },
    {
      'id': 'USR-SLR-05',
      'username': 'rizky_kuningan',
      'name': 'Rizky Pratama',
      'phone': '0812-9900-1122',
      'role': 'SELLER_TRAINEE',
      'cart_id': 'GRB-05 (Standby)',
      'selected_location': 'Area Kampus UI Salemba (Rencana)',
      'coordinates': '-6.1951, 106.8504',
      'is_store_open': false, // Petugas belum buka toko / absen libur
      'attendance_time': 'Belum Absen / Off',
      'morning_stock_picked': '0 Cup (Belum Ambil)',
      'commission_rate': 1200,
      'cups_sold_today': 0,
      'total_commission': 'Rp 0',
      'cash_in_hand': 'Rp 0',
      'qris_collected': 'Rp 0',
      'current_stock': '0 Cup',
      'active_orders_count': 0,
      'status': 'OFFLINE (TIDAK JUALAN)',
      'color': const Color(0xFF94A3B8),
    },
  ];

  // --- 2. DATA PERSEDIAAN GUDANG PUSAT (BISA DIINPUT & DITAMBAH OWNER) ---
  final List<Map<String, dynamic>> _warehouseStock = [
    {'sku': 'PRD-01', 'name': 'Kopi Susu Gula Aren', 'cat': 'Signature', 'stock': 850, 'reserved': 40, 'avail': 810, 'status': 'AMAN', 'color': const Color(0xFF10B981)},
    {'sku': 'PRD-02', 'name': 'Americano Double Shot', 'cat': 'Classic Espresso', 'stock': 620, 'reserved': 15, 'avail': 605, 'status': 'AMAN', 'color': const Color(0xFF10B981)},
    {'sku': 'PRD-03', 'name': 'Matcha Uji Latte Creamy', 'cat': 'Non-Coffee', 'stock': 420, 'reserved': 20, 'avail': 400, 'status': 'AMAN', 'color': const Color(0xFF10B981)},
    {'sku': 'PRD-04', 'name': 'Cafe Latte Steam Velvet', 'cat': 'Signature', 'stock': 510, 'reserved': 30, 'avail': 480, 'status': 'AMAN', 'color': const Color(0xFF10B981)},
    {'sku': 'PRD-05', 'name': 'Roti Bakar Cokelat Keju', 'cat': 'Camilan', 'stock': 250, 'reserved': 10, 'avail': 240, 'status': 'PERHATIAN', 'color': const Color(0xFFF59E0B)},
    {'sku': 'PRD-06', 'name': 'Cold Brew Citrus Signature', 'cat': 'Classic Espresso', 'stock': 380, 'reserved': 5, 'avail': 375, 'status': 'AMAN', 'color': const Color(0xFF10B981)},
  ];

  // --- 3. DATA TITIK LOKASI JUALAN & REKOMENDASI AI UNTUK DIPILIH PETUGAS ---
  final List<Map<String, dynamic>> _availableSpots = [
    {
      'id': 'LOC-01',
      'name': 'Koridor Sudirman - Halte Dukuh Atas',
      'seller_active': 'Budi Santoso (GRB-01)',
      'status': 'TERISI (ONLINE)',
      'morning_stock_quota': '120 Cup (Susu Aren 60, Americano 40, Latte 20)',
      'pedestrian_density': '1.450 org/jam',
      'lat_long': '-6.2088, 106.8227',
      'score': '96.8 / 100',
      'is_occupied': true,
    },
    {
      'id': 'LOC-02',
      'name': 'Taman Suropati & Taman Kodok Menteng',
      'seller_active': 'Ahmad Fauzi (GRB-02)',
      'status': 'TERISI (ONLINE)',
      'morning_stock_quota': '100 Cup (Matcha 40, Susu Aren 30, Roti 30)',
      'pedestrian_density': '480 org/jam',
      'lat_long': '-6.1994, 106.8326',
      'score': '88.5 / 100',
      'is_occupied': true,
    },
    {
      'id': 'LOC-03',
      'name': 'Pintu Timur Stasiun Juanda Commuter',
      'seller_active': 'Hendra Wijaya (GRB-04)',
      'status': 'TERISI (ONLINE)',
      'morning_stock_quota': '110 Cup (Americano 50, Susu Aren 40, Cold Brew 20)',
      'pedestrian_density': '980 org/jam',
      'lat_long': '-6.1668, 106.8312',
      'score': '93.2 / 100',
      'is_occupied': true,
    },
    {
      'id': 'LOC-04',
      'name': 'Pasar Senen Blok III & Halte Senen',
      'seller_active': 'Siti Rahmawati (GRB-03)',
      'status': 'TERISI (ONLINE)',
      'morning_stock_quota': '120 Cup (Susu Aren 70, Roti Bakar 30, Kopi Hitam 20)',
      'pedestrian_density': '850 org/jam',
      'lat_long': '-6.1744, 106.8432',
      'score': '90.0 / 100',
      'is_occupied': true,
    },
    {
      'id': 'LOC-05',
      'name': 'Area Kampus UI Salemba - Gedung Rektorat',
      'seller_active': 'KOSONG (BISA DIPILIH)',
      'status': 'SIAP DIPILIH PETUGAS',
      'morning_stock_quota': '90 Cup (Matcha 35, Aren 35, Cold Brew 20)',
      'pedestrian_density': '720 mhs/jam',
      'lat_long': '-6.1951, 106.8504',
      'score': '87.4 / 100',
      'is_occupied': false,
    },
    {
      'id': 'LOC-06',
      'name': 'Kawasan Perkantoran Kuningan Madya',
      'seller_active': 'KOSONG (BISA DIPILIH)',
      'status': 'SIAP DIPILIH PETUGAS',
      'morning_stock_quota': '100 Cup (Americano 50, Aren 30, Latte 20)',
      'pedestrian_density': '640 kry/jam',
      'lat_long': '-6.2185, 106.8302',
      'score': '84.1 / 100',
      'is_occupied': false,
    },
  ];

  // --- 4. DATA PRE-ORDER REALTIME & KASIR WALK-IN ---
  final List<Map<String, dynamic>> _liveOrders = [
    {'id': 'PO-9041', 'customer': 'Rani Anggraini', 'seller': 'Budi Santoso (Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 'Rp 37.000', 'status': 'CONFIRMED', 'pay': 'PAID (QRIS)', 'pjp_ref': 'QRIS-GOPAY-849102', 'time': '13:18 WIB'},
    {'id': 'PO-9040', 'customer': 'Bagus Prasetyo', 'seller': 'Hendra (Juanda)', 'items': '1x Americano Double Shot', 'total': 'Rp 16.000', 'status': 'READY_FOR_PICKUP', 'pay': 'PAID (QRIS)', 'pjp_ref': 'QRIS-BCA-920145', 'time': '13:10 WIB'},
    {'id': 'PO-9039', 'customer': 'Clarissa Olivia', 'seller': 'Siti Rahma (Senen)', 'items': '2x Matcha Latte', 'total': 'Rp 49.000', 'status': 'PENDING_PAYMENT', 'pay': 'PENDING', 'pjp_ref': 'MENUNGGU WEBHOOK', 'time': '13:22 WIB'},
    {'id': 'PO-9038', 'customer': 'Farhan Maulana', 'seller': 'Budi Santoso (Sudirman)', 'items': '1x Cafe Latte + 1x Roti Bakar', 'total': 'Rp 38.000', 'status': 'CONFIRMED', 'pay': 'PAID (QRIS)', 'pjp_ref': 'QRIS-SHOPEE-119402', 'time': '13:24 WIB'},
  ];

  // --- MODAL 1: TAMBAH / SETTING AKUN PETUGAS LAPANGAN ---
  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final usernameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final cartCtrl = TextEditingController(text: 'GRB-06');
    final commissionCtrl = TextEditingController(text: '1500');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.person_add_alt_1, color: Color(0xFF0F172A)),
            SizedBox(width: 10),
            Text('Tambah & Atur Akun Petugas Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Data Petugas & Kredensial Login:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Petugas', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: usernameCtrl, decoration: const InputDecoration(labelText: 'Username Login Aplikasi Seller', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Nomor WhatsApp / HP Aktif', border: OutlineInputBorder())),
                const SizedBox(height: 14),

                const Text('Alokasi Unit Gerobak & Sistem Komisi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 8),
                TextField(controller: cartCtrl, decoration: const InputDecoration(labelText: 'ID Gerobak Keliling', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                  controller: commissionCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Besaran Komisi per Cup (Rp)', prefixText: 'Rp ', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                  child: const Text('ℹ️ Setelah akun dibuat, petugas dapat login di HP masing-masing, memilih titik jualan, mengambil kuota stok pagi, dan menekan "Buka Toko" untuk mulai aktif jualan.', style: TextStyle(fontSize: 12, color: Color(0xFF475569))),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white),
            onPressed: () {
              if (nameCtrl.text.isEmpty) return;
              setState(() {
                _staffAccounts.add({
                  'id': 'USR-SLR-0${_staffAccounts.length + 1}',
                  'username': usernameCtrl.text.isNotEmpty ? usernameCtrl.text : 'seller_baru',
                  'name': nameCtrl.text,
                  'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '0812-0000-0000',
                  'role': 'SELLER_REGULER',
                  'cart_id': cartCtrl.text,
                  'selected_location': 'Belum Memilih Lokasi',
                  'coordinates': '-6.2000, 106.8200',
                  'is_store_open': false,
                  'attendance_time': 'Belum Absen',
                  'morning_stock_picked': '0 Cup',
                  'commission_rate': int.tryParse(commissionCtrl.text) ?? 1500,
                  'cups_sold_today': 0,
                  'total_commission': 'Rp 0',
                  'cash_in_hand': 'Rp 0',
                  'qris_collected': 'Rp 0',
                  'current_stock': '0 Cup',
                  'active_orders_count': 0,
                  'status': 'MENUNGGU AKTIVASI',
                  'color': const Color(0xFFF59E0B),
                });
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Akun petugas lapangan berhasil ditambahkan!')));
            },
            child: const Text('Simpan Akun Petugas'),
          ),
        ],
      ),
    );
  }

  // --- MODAL 2: INPUT / TAMBAH STOK GUDANG PUSAT OLEH OWNER ---
  void _showAddWarehouseStockModal() {
    String selectedSku = 'PRD-01';
    final qtyCtrl = TextEditingController(text: '100');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.add_box_outlined, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Input / Restock Persediaan Gudang Pusat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 460,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Menu / Bahan Baku Kopi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSku,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _warehouseStock.map((w) => DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['sku']} • ${w['name']} (Sisa: ${w['avail']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSku = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Jumlah Stok Masuk (Cup / Porsi):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Contoh: 150', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
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
                  for (var item in _warehouseStock) {
                    if (item['sku'] == selectedSku) {
                      item['stock'] = (item['stock'] as int) + addQty;
                      item['avail'] = (item['avail'] as int) + addQty;
                    }
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Stok gudang pusat berhasil ditambahkan!')));
              },
              child: const Text('Tambah ke Gudang'),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODAL 3: DISTRIBUSI ALOKASI STOK PAGI DARI GUDANG KE GEROBAK ---
  void _showDistributeMorningStockModal() {
    String selectedSeller = _staffAccounts.first['id'];
    String selectedProduct = 'PRD-01';
    final qtyCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.local_shipping_outlined, color: Color(0xFF0F172A)),
              SizedBox(width: 10),
              Text('Alokasi Stok Bawaan ke Petugas Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Petugas Lapangan Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSeller,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _staffAccounts.map((s) => DropdownMenuItem(value: s['id'].toString(), child: Text('${s['name']} • ${s['cart_id']} (${s['status']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedSeller = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Pilih Menu Produk Gudang:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedProduct,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: _warehouseStock.map((w) => DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['name']} (Sedia Gudang: ${w['avail']})'))).toList(),
                  onChanged: (val) {
                    if (val != null) setModalState(() => selectedProduct = val);
                  },
                ),
                const SizedBox(height: 14),
                const Text('Jumlah Stok yang Dibawa (Cup / Porsi):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(hintText: 'Contoh: 30', border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                ),
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
                  // Kurangi stok gudang
                  for (var w in _warehouseStock) {
                    if (w['sku'] == selectedProduct && (w['avail'] as int) >= qty) {
                      w['avail'] = (w['avail'] as int) - qty;
                    }
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Alokasi stok berhasil dicatat dan dikirim ke gerobak petugas!')));
              },
              child: const Text('Kirim Alokasi Stok'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Enterprise Sidebar Navigation
          _buildSidebar(),

          // 2. Main Executive Screen
          Expanded(
            child: Column(
              children: [
                _buildTopHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(26),
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

  Widget _buildSidebar() {
    int activeStaffCount = _staffAccounts.where((s) => s['is_store_open'] == true).length;

    return Container(
      width: 275,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(22),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: const Color(0xFF38BDF8).withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
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

            const SizedBox(height: 14),
            _sidebarCategory('MONITORING ARMADA & TIM'),
            _sidebarItem(0, Icons.grid_view_outlined, 'Executive Dashboard'),
            _sidebarItem(1, Icons.badge_outlined, 'Petugas & Akun Lapangan', badge: '$activeStaffCount Aktif Jualan'),
            _sidebarItem(2, Icons.map_outlined, 'Peta Live Posisi & Lapak', badge: 'Live GPS'),
            _sidebarItem(3, Icons.monetization_on_outlined, 'Sistem Komisi Penjualan', badge: 'Rp/Cup'),

            const SizedBox(height: 14),
            _sidebarCategory('LOGISTIK & KONTROL STOK'),
            _sidebarItem(4, Icons.warehouse_outlined, 'Stok Gudang Pusat (Owner)'),
            _sidebarItem(5, Icons.psychology_outlined, 'AI Demand & Alokasi (MILP)', badge: 'Optimal'),
            _sidebarItem(6, Icons.receipt_long_outlined, 'Live Order & QRIS PJP', badge: '${_liveOrders.length} Trx'),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Sinkronisasi Realtime', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('$activeStaffCount Gerobak Sedang Online Jualan', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: const Color(0xFF0F172A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 9)),
                            onPressed: _showDistributeMorningStockModal,
                            child: const Text('Bagi Stok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF475569)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 9)),
                            onPressed: _showAddStaffModal,
                            child: const Text('+ Akun', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sidebarCategory(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
      child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _sidebarItem(int index, IconData icon, String title, {String? badge}) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected ? Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF38BDF8).withOpacity(0.2) : const Color(0xFF334155),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge, style: TextStyle(color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold)),
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
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1))),
      child: Row(
        children: [
          Text(
            _getModuleTitle(),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyinkronkan GPS gerobak, orderan masuk, dan kas lapangan realtime...')));
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Refresh Realtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          const SizedBox(width: 14),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0F172A),
            child: Text('OW', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _getModuleTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Executive Dashboard & Omzet Konsolidasi';
      case 1: return 'Pengaturan Akun Petugas Lapangan & Kontrol Absensi';
      case 2: return 'Peta Geospasial Realtime Posisi Tim & Pilihan Titik Jualan';
      case 3: return 'Sistem Rekap Komisi Penjualan Tim Lapangan';
      case 4: return 'Input Stok Gudang Pusat (Owner) & Pembagian Bawaan Pagi';
      case 5: return 'AI Demand Forecasting & Optimasi Alokasi (MILP)';
      case 6: return 'Monitoring Live Order & Pembayaran QRIS PJP';
      default: return 'KopiCerdas AI Owner Suite';
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

  // ==========================================
  // MODULE 0: EXECUTIVE DASHBOARD
  // ==========================================
  Widget _buildExecutiveDashboard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Cards Row
        Row(
          children: [
            Expanded(child: _kpiCard('Omzet Konsolidasi Hari Ini', 'Rp 14.250.000', '+18.4% vs kemarin', Icons.monetization_on_outlined, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Laba Bersih Operasional', 'Rp 8.120.000', 'Margin Sehat 57.0%', Icons.account_balance_wallet_outlined, const Color(0xFF0284C7))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Cup Terjual', '748 Cup', '4 Gerobak Aktif Jualan', Icons.local_cafe_outlined, const Color(0xFFF59E0B))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Komisi Petugas', 'Rp 634.500', 'Insentif Terakumulasi', Icons.military_tech_outlined, const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 24),

        // Urgent Alert Box
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 28)),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERINGATAN STOK: Gerobak 04 (Hendra - Stasiun Juanda) Sisa 15 Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF92400E))),
                    SizedBox(height: 4),
                    Text('Laju pembelian tinggi di stasiun kereta. Diprediksi habis pukul 13.50 WIB. Segera kirimkan stok tambahan dari gudang.', style: TextStyle(color: Color(0xFFB45309), fontSize: 13)),
                  ],
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _showDistributeMorningStockModal,
                child: const Text('Kirim Stok Darurat'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Ringkasan Cepat Petugas & Lokasi
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
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
                      Text('Hanya petugas yang sudah absen dan membuka toko yang statusnya ONLINE di peta dan sistem.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => setState(() => _selectedNavIndex = 1),
                    icon: const Icon(Icons.settings, size: 16),
                    label: const Text('Kelola Semua Akun'),
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

  // ==========================================
  // MODULE 1: SETTING & PENGATURAN AKUN TIM LAPANGAN + ABSENSI
  // ==========================================
  Widget _buildStaffAccountManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen Akun Tim Lapangan & Kontrol Operasional', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Atur akun login, nomor HP, peran, unit gerobak, status toko buka/tutup, dan rekonsiliasi kas.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _showAddStaffModal,
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Tambah Akun Petugas Baru'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Grid Kartu Akun Petugas
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _staffAccounts.map((s) {
            bool isOpen = s['is_store_open'] == true;

            return Container(
              width: 380,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isOpen ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1), width: isOpen ? 1 : 1.5),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
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
                            radius: 20,
                            backgroundColor: isOpen ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                            child: Text(s['name'].toString().substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                              Text('User: @${s['username']} • ID: ${s['id']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      _statusBadge(isOpen ? 'AKTIF JUALAN' : 'OFFLINE / TUTUP', isOpen ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  _infoRow(Icons.phone_outlined, 'Kontak Petugas', s['phone']),
                  _infoRow(Icons.storefront, 'Gerobak Unit', s['cart_id']),
                  _infoRow(Icons.location_on_outlined, 'Lokasi Terpilih', s['selected_location']),
                  _infoRow(Icons.access_time, 'Status Absensi Pagi', s['attendance_time']),
                  _infoRow(Icons.inventory_outlined, 'Stok Bawaan Pagi', s['morning_stock_picked']),

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
                            Text(s['current_stock'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
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
                            const Text('Komisi Petugas:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text('${s['total_commission']} (@Rp ${s['commission_rate']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5CF6))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Uang Fisik Kasir (CASH):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(s['cash_in_hand'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0F172A))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: () {
                            setState(() {
                              s['is_store_open'] = !s['is_store_open'];
                              s['status'] = s['is_store_open'] ? 'AKTIF JUALAN' : 'OFFLINE (TIDAK JUALAN)';
                            });
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Status operasional ${s['name']} diubah menjadi ${s['is_store_open'] ? 'ONLINE' : 'OFFLINE'}')));
                          },
                          child: Text(isOpen ? 'Set Tutup' : 'Set Buka Jualan', style: TextStyle(fontSize: 12, color: isOpen ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          onPressed: _showDistributeMorningStockModal,
                          child: const Text('Beri Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ==========================================
  // MODULE 2: PETA GEOSPASIAL LIVE POSISI TIM & TITIK PILIHAN
  // ==========================================
  Widget _buildLiveMapGeospatialView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peta Geospasial Realtime Posisi Armada & Pilihan Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Memantau koordinat GPS aktif seluruh petugas, titik jualan yang sudah terisi, dan titik potensial kosong yang siap dipilih.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, size: 16, color: Color(0xFF10B981)),
                  SizedBox(width: 6),
                  Text('GPS & Telemetri Active', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Visual Interactive Map Frame
        Container(
          width: double.infinity,
          height: 380,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 68, color: Colors.blueGrey.shade200),
                        const SizedBox(height: 8),
                        Text('PETA DIGITAL WILAYAH OPERASIONAL KOPICERDAS (JABODETABEK)', style: TextStyle(color: Colors.blueGrey.shade500, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                        Text('Titik Gerobak Aktif memancarkan sinyal GPS realtime saat petugas menekan "Buka Toko"', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),

              // Markers for Active Sellers
              _liveMapPin(90, 70, 'Budi (GRB-01)', 'Sudirman • Sisa 42 Cup', isOnline: true),
              _liveMapPin(260, 160, 'Ahmad (GRB-02)', 'Suropati • Sisa 28 Cup', isOnline: true),
              _liveMapPin(420, 80, 'Hendra (GRB-04)', 'Juanda • RESTOCK! (15 Cup)', isOnline: true, isAlert: true),
              _liveMapPin(560, 150, 'Siti Rahma (GRB-03)', 'Pasar Senen • Sisa 35 Cup', isOnline: true),

              // Markers for Available Empty Spots to pick
              _liveMapPin(720, 90, 'Lapak Kosong: Kampus UI Salemba', 'Kuota: 90 Cup • Skor 87.4', isOnline: false),
              _liveMapPin(860, 220, 'Lapak Kosong: Kuningan Madya', 'Kuota: 100 Cup • Skor 84.1', isOnline: false),

              // Overlay Map Legend
              Positioned(
                bottom: 16,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 6)]),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Color(0xFF10B981), size: 10),
                      SizedBox(width: 6),
                      Text('Gerobak Online', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFFEF4444), size: 10),
                      SizedBox(width: 6),
                      Text('Stok Menipis (<20 Cup)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFFF59E0B), size: 10),
                      SizedBox(width: 6),
                      Text('Titik Kosong Bisa Dipilih', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Tabel Detail Lokasi & Kuota Bawaan Pagi
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Katalog Lokasi Jualan & Panduan Kuota Stok Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 6),
              const Text('Petugas lapangan sebelum berangkat melihat daftar kuota stok ini agar tahu berapa cup dan varian yang harus diambil dari gudang pusat.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
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
                      _th('ID'),
                      _th('Area & Landmark Lokasi'),
                      _th('Petugas Yang Menempati'),
                      _th('Rekomendasi Bawaan Pagi (Porsi)'),
                      _th('Trafik Pejalan Kaki'),
                      _th('Skor AI'),
                      _th('Status'),
                    ],
                  ),
                  ..._availableSpots.map((spot) {
                    bool isOcc = spot['is_occupied'] == true;
                    return TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(spot['id']),
                        _td(spot['name'], bold: true),
                        _td(spot['seller_active']),
                        _td(spot['morning_stock_quota'], color: const Color(0xFF0284C7), bold: true),
                        _td(spot['pedestrian_density']),
                        _td(spot['score'], bold: true),
                        _statusBadge(isOcc ? 'TERISI' : 'BISA DIPILIH', isOcc ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODULE 3: SISTEM REKAP KOMISI PENJUALAN
  // ==========================================
  Widget _buildCommissionSystemView() {
    num totalKomisiSemua = _staffAccounts.fold(0, (acc, s) => acc + (s['cups_sold_today'] * s['commission_rate']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sistem Komisi Penjualan Tim Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Perhitungan insentif otomatis berdasarkan setiap cup kopi yang berhasil terjual oleh masing-masing seller.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text(
                'Total Insentif Hari Ini: Rp ${totalKomisiSemua.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}',
                style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(2),
              6: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Petugas'),
                  _th('Nama Petugas Lapangan'),
                  _th('Cup Terjual'),
                  _th('Rate Komisi / Cup'),
                  _th('Total Komisi (Rp)'),
                  _th('Omzet Dihasilkan'),
                  _th('Status Pencairan'),
                ],
              ),
              ..._staffAccounts.map((s) {
                int rate = s['commission_rate'] as int;
                int sold = s['cups_sold_today'] as int;
                int komisi = rate * sold;

                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(s['id']),
                    _td(s['name'], bold: true),
                    _td('$sold Cup'),
                    _td('Rp $rate / cup'),
                    _td('Rp ${komisi.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}', bold: true, color: const Color(0xFF10B981)),
                    _td('Kas: ${s['cash_in_hand']} • QRIS: ${s['qris_collected']}'),
                    _statusBadge(sold > 0 ? 'SIAP SETOR & CAIR' : 'BELUM ADA PENJUALAN', sold > 0 ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODULE 4: INPUT STOK GUDANG PUSAT (OWNER/ADMIN)
  // ==========================================
  Widget _buildWarehouseManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Manajemen & Input Persediaan Gudang Pusat (Owner/Admin)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Owner menginput stok masuk, mengontrol stok fisik, reservasi pre-order, dan membagikan stok bawaan pagi ke gerobak.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11)),
                  onPressed: _showAddWarehouseStockModal,
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: const Text('Input Stok Baru Gudang', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11)),
                  onPressed: _showDistributeMorningStockModal,
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Bagi Stok ke Gerobak', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2.5),
              2: FlexColumnWidth(1.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Kode SKU'),
                  _th('Nama Menu / Bahan'),
                  _th('Kategori'),
                  _th('Stok Fisik Total'),
                  _th('Direservasi Pre-Order'),
                  _th('Siap Didistribusikan'),
                  _th('Status'),
                ],
              ),
              ..._warehouseStock.map((w) {
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(w['sku']),
                    _td(w['name'], bold: true),
                    _td(w['cat']),
                    _td('${w['stock']} Cup'),
                    _td('${w['reserved']} Cup (Tahan)'),
                    _td('${w['avail']} Cup', bold: true, color: const Color(0xFF0284C7)),
                    _statusBadge(w['status'], w['color']),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // MODULE 5: AI OPTIMIZATION & FORECASTING (MILP)
  // ==========================================
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
                Text('AI Inventory Optimization & Mixed-Integer Programming (MILP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Optimalisasi matematis alokasi stok gerobak dengan batasan kapasitas box, proyeksi demand, dan maksimasi profit margin.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)),
              child: const Text('Solver Status: MILP_OPTIMAL', style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(14)),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PROYEKSI POTENSI LABA BERSIH (OPTIMAL OBJECTIVE)', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
                    SizedBox(height: 6),
                    Text('Rp 24.850.000 / Siklus', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('Data Label: SIMULASI KOPIDAS V1.1 • Batasan: 120 cup/gerobak & stok pusat', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 12)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF38BDF8), foregroundColor: const Color(0xFF0F172A)),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menjalankan kembali solver matematis MILP dengan parameter terbaru...')));
                },
                icon: const Icon(Icons.bolt, size: 18),
                label: const Text('Re-calculate Optimization', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
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
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                children: [
                  _statusBadge('URGENT', const Color(0xFFEF4444)),
                  _td('Koridor Sudirman (Pak Darto)', bold: true),
                  _td('Kopi Susu Gula Aren'),
                  _td('42 Cup'),
                  _td('75 Cup (+33 Cup)', bold: true, color: const Color(0xFF10B981)),
                  _td('Lonjakan komuter jam makan siang (11.45 - 13.30). Stok saat ini berisiko stock-out pukul 12.15.', italic: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      onPressed: _showDistributeMorningStockModal,
                      child: const Text('Setujui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                children: [
                  _statusBadge('HIGH', const Color(0xFFF59E0B)),
                  _td('Stasiun Juanda (Roda Biru)', bold: true),
                  _td('Americano Double Shot'),
                  _td('15 Cup'),
                  _td('45 Cup (+30 Cup)', bold: true, color: const Color(0xFF10B981)),
                  _td('Kebutuhan asupan kafein pekerja kereta sore hari. Margin kotor tinggi Rp 10.500/cup.', italic: true),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
                      onPressed: _showDistributeMorningStockModal,
                      child: const Text('Setujui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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

  // ==========================================
  // MODULE 6: LIVE ORDER PRE-ORDER & QRIS PJP
  // ==========================================
  Widget _buildLiveTransactionsOrdersView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Monitoring Live Order Masuk & Validasi Pembayaran QRIS PJP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Pelanggan melakukan pre-order online ke gerobak seller. Status pembayaran sinkron otomatis dengan notifikasi resmi PJP/Acquirer.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2.2),
              3: FlexColumnWidth(2.5),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.5),
              7: FlexColumnWidth(1.5),
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
              ..._liveOrders.map((o) {
                bool isPaid = o['pay'].toString().contains('PAID');
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(o['id']),
                    _td(o['customer'], bold: true),
                    _td(o['seller']),
                    _td(o['items']),
                    _td(o['total'], bold: true),
                    _statusBadge(o['status'], const Color(0xFF0284C7)),
                    _statusBadge(o['pay'], isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    _td(o['pjp_ref'], italic: true),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // --- SUB WIDGET HELPER ---
  Widget _buildStaffTableSummary() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.5),
        4: FlexColumnWidth(1.8),
        5: FlexColumnWidth(1.5),
        6: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
          children: [
            _th('Petugas Seller'),
            _th('Titik Gerobak & Lokasi'),
            _th('Absen Pagi'),
            _th('Penjualan'),
            _th('Sisa Stok'),
            _th('Komisi Hari Ini'),
            _th('Status Toko'),
          ],
        ),
        ..._staffAccounts.map((s) {
          bool isOpen = s['is_store_open'] == true;
          return TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
            children: [
              _td(s['name'], bold: true),
              _td('${s['cart_id']}\n${s['selected_location']}'),
              _td(s['attendance_time']),
              _td('${s['cups_sold_today']} Cup'),
              _td(s['current_stock'], bold: true, color: s['color']),
              _td(s['total_commission'], bold: true, color: const Color(0xFF8B5CF6)),
              _statusBadge(isOpen ? 'BUKA' : 'TUTUP', isOpen ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
            ],
          );
        }),
      ],
    );
  }

  Widget _liveMapPin(double left, double top, String title, String subtitle, {required bool isOnline, bool isAlert = false}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isAlert ? const Color(0xFFEF4444) : (isOnline ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isOnline ? Colors.transparent : const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isOnline ? Icons.coffee : Icons.place_outlined, color: isOnline ? Colors.white : const Color(0xFFD97706), size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(color: isOnline ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11)),
                Text(subtitle, style: TextStyle(color: isOnline ? const Color(0xFF38BDF8) : const Color(0xFF64748B), fontSize: 9)),
              ],
            )
          ],
        ),
      ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
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
}
