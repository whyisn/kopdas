import 'package:flutter/material.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  int _selectedNavIndex = 0;
  String _locationFilter = 'ALL';
  String _sellerFilter = 'ALL';

  // --- DATA KOPICERDAS AI SUITE ---
  final List<Map<String, dynamic>> _kpis = const [
    {'title': 'Total Omzet Bisnis', 'value': 'Rp 14.250.000', 'sub': '+18.4% vs target harian', 'color': Color(0xFF10B981), 'icon': Icons.payments_outlined},
    {'title': 'Laba Bersih Operasional', 'value': 'Rp 8.120.000', 'sub': 'Margin Kontribusi 57.0%', 'color': Color(0xFF0284C7), 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Total Cup Terjual', 'value': '748 Cup', 'sub': 'Kapasitas Terpakai 62.3%', 'color': Color(0xFFF59E0B), 'icon': Icons.local_cafe_outlined},
    {'title': 'Penetrasi QRIS Statis', 'value': '68.4%', 'sub': '492 Trx QRIS • Terverifikasi PJP', 'color': Color(0xFF6366F1), 'icon': Icons.qr_code_2},
  ];

  final List<Map<String, dynamic>> _fieldStaff = const [
    {
      'staff_id': 'STF-01',
      'name': 'Budi Santoso (Pak Darto)',
      'phone': '0812-8821-9901',
      'cart_id': 'GRB-01 (Sudirman)',
      'location': 'Halte Dukuh Atas Sudirman (Pintu Barat)',
      'coordinates': '-6.2088, 106.8227',
      'shift': 'Pagi (06.30 - 15.00 WIB)',
      'sales_cup': '142 Cup',
      'cash_collected': 'Rp 900.000',
      'qris_collected': 'Rp 1.940.000',
      'stock_left': '42 / 120 Cup',
      'status': 'AKTIF JUALAN',
      'device_status': 'GPS & POS Online',
      'color': Color(0xFF10B981)
    },
    {
      'staff_id': 'STF-02',
      'name': 'Ahmad Fauzi (Gerobak Sore)',
      'phone': '0813-1102-4451',
      'cart_id': 'GRB-02 (Suropati)',
      'location': 'Taman Suropati & Taman Kodok Menteng',
      'coordinates': '-6.1994, 106.8326',
      'shift': 'Sore (14.00 - 22.00 WIB)',
      'sales_cup': '68 Cup',
      'cash_collected': 'Rp 520.000',
      'qris_collected': 'Rp 900.000',
      'stock_left': '28 / 100 Cup',
      'status': 'AKTIF JUALAN',
      'device_status': 'GPS & POS Online',
      'color': Color(0xFF10B981)
    },
    {
      'staff_id': 'STF-03',
      'name': 'Siti Rahmawati (Mbak Ayu)',
      'phone': '0857-4491-0023',
      'cart_id': 'GRB-03 (Pasar Senen)',
      'location': 'Pojok Blok III & Halte Senen Sentral',
      'coordinates': '-6.1744, 106.8432',
      'shift': 'Pagi (05.30 - 14.00 WIB)',
      'sales_cup': '95 Cup',
      'cash_collected': 'Rp 640.000',
      'qris_collected': 'Rp 1.340.000',
      'stock_left': '35 / 120 Cup',
      'status': 'AKTIF JUALAN',
      'device_status': 'GPS & POS Online',
      'color': Color(0xFF10B981)
    },
    {
      'staff_id': 'STF-04',
      'name': 'Hendra Wijaya (Roda Biru)',
      'phone': '0821-7781-3312',
      'cart_id': 'GRB-04 (Juanda)',
      'location': 'Pintu Timur Stasiun Commuter Juanda',
      'coordinates': '-6.1668, 106.8312',
      'shift': 'Full Day (06.00 - 20.00 WIB)',
      'sales_cup': '118 Cup',
      'cash_collected': 'Rp 780.000',
      'qris_collected': 'Rp 1.670.000',
      'stock_left': '15 / 110 Cup',
      'status': 'PERLU RESTOCK',
      'device_status': 'Low Stock Alert (15 cup)',
      'color': Color(0xFFEF4444)
    },
  ];

  final List<Map<String, dynamic>> _locationsWithMap = const [
    {
      'id': 'LOC-01',
      'name': 'Koridor Sudirman - Halte Dukuh Atas',
      'address': 'Jl. Jend. Sudirman Kav 10, Jakarta Pusat',
      'lat_long': '-6.2088, 106.8227',
      'seller_assigned': 'Budi Santoso (Pak Darto)',
      'pedestrian_density': 'Sangat Tinggi (1.450 pejalan/jam)',
      'poi_nearby': 'Stasiun KRL Sudirman, MRT Dukuh Atas, LRT Jabodebek',
      'weather': 'Cerah 31°C (Kondusif Es Kopi)',
      'today_sales': '142 Cup',
      'score': '96.8',
      'status': 'OPERASIONAL',
      'color': Color(0xFF10B981)
    },
    {
      'id': 'LOC-02',
      'name': 'Taman Suropati & Taman Kodok Menteng',
      'address': 'Kawasan Taman Menteng, Jakarta Pusat',
      'lat_long': '-6.1994, 106.8326',
      'seller_assigned': 'Ahmad Fauzi (Gerobak Sore)',
      'pedestrian_density': 'Sedang (480 pengunjung/jam)',
      'poi_nearby': 'Area Jogging, Spot Nongkrong Mahasiswa, Komunitas Musik',
      'weather': 'Berawan 29°C',
      'today_sales': '68 Cup',
      'score': '88.5',
      'status': 'OPERASIONAL',
      'color': Color(0xFF10B981)
    },
    {
      'id': 'LOC-03',
      'name': 'Pintu Timur Stasiun Juanda Commuter',
      'address': 'Jl. Ir. H. Juanda No. 1, Gambir',
      'lat_long': '-6.1668, 106.8312',
      'seller_assigned': 'Hendra Wijaya (Roda Biru)',
      'pedestrian_density': 'Tinggi (980 komuter/jam)',
      'poi_nearby': 'Masjid Istiqlal, Gereja Katedral, Halte Juanda',
      'weather': 'Cerah Berawan 30°C',
      'today_sales': '118 Cup',
      'score': '93.2',
      'status': 'OPERASIONAL',
      'color': Color(0xFF10B981)
    },
    {
      'id': 'LOC-04',
      'name': 'Pasar Senen Blok III & Halte Senen',
      'address': 'Jl. Stasiun Senen, Senen',
      'lat_long': '-6.1744, 106.8432',
      'seller_assigned': 'Siti Rahmawati (Mbak Ayu)',
      'pedestrian_density': 'Tinggi (850 pedagang/jam)',
      'poi_nearby': 'Pusat Grosir Senen, Halte Transjakarta Senen',
      'weather': 'Panas 32°C',
      'today_sales': '95 Cup',
      'score': '90.0',
      'status': 'OPERASIONAL',
      'color': Color(0xFF10B981)
    },
    {
      'id': 'LOC-05',
      'name': 'Area Kampus UI Salemba - Rektorat',
      'address': 'Jl. Salemba Raya No. 4, Kenari',
      'lat_long': '-6.1951, 106.8504',
      'seller_assigned': 'BELUM ADA (KANDIDAT AI)',
      'pedestrian_density': 'Potensi Tinggi (720 civitas/jam)',
      'poi_nearby': 'Fakultas Kedokteran UI, RS Cipto Mangunkusumo (RSCM)',
      'weather': 'Cerah 31°C',
      'today_sales': '0 Cup',
      'score': '87.4',
      'status': 'KANDIDAT AI',
      'color': Color(0xFFF59E0B)
    },
    {
      'id': 'LOC-06',
      'name': 'Kawasan Perkantoran Kuningan Madya',
      'address': 'Jl. HR Rasuna Said Kav C-18',
      'lat_long': '-6.2185, 106.8302',
      'seller_assigned': 'BELUM ADA (KANDIDAT AI)',
      'pedestrian_density': 'Potensi Tinggi (640 pekerja/jam)',
      'poi_nearby': 'Plaza Festival, Setiabudi One, Halte GOR Soemantri',
      'weather': 'Cerah 31°C',
      'today_sales': '0 Cup',
      'score': '84.1',
      'status': 'KANDIDAT AI',
      'color': Color(0xFFF59E0B)
    },
  ];

  final List<Map<String, dynamic>> _warehouse = const [
    {'sku': 'PRD-01', 'name': 'Kopi Susu Gula Aren', 'stock': '850 Cup', 'reserved': '40 Cup', 'avail': '810 Cup', 'status': 'AMAN', 'color': Color(0xFF10B981)},
    {'sku': 'PRD-02', 'name': 'Americano Double Shot', 'stock': '620 Cup', 'reserved': '15 Cup', 'avail': '605 Cup', 'status': 'AMAN', 'color': Color(0xFF10B981)},
    {'sku': 'PRD-03', 'name': 'Matcha Uji Latte Creamy', 'stock': '420 Cup', 'reserved': '20 Cup', 'avail': '400 Cup', 'status': 'AMAN', 'color': Color(0xFF10B981)},
    {'sku': 'PRD-04', 'name': 'Cafe Latte Steam Velvet', 'stock': '510 Cup', 'reserved': '30 Cup', 'avail': '480 Cup', 'status': 'AMAN', 'color': Color(0xFF10B981)},
    {'sku': 'PRD-05', 'name': 'Roti Bakar Cokelat Keju', 'stock': '250 Porsi', 'reserved': '10 Porsi', 'avail': '240 Porsi', 'status': 'PERHATIAN', 'color': Color(0xFFF59E0B)},
    {'sku': 'PRD-06', 'name': 'Cold Brew Citrus Signature', 'stock': '380 Cup', 'reserved': '5 Cup', 'avail': '375 Cup', 'status': 'AMAN', 'color': Color(0xFF10B981)},
  ];

  final List<Map<String, dynamic>> _aiRecommendations = const [
    {
      'priority': 'URGENT',
      'cart': 'Koridor Sudirman (Pak Darto)',
      'product': 'Kopi Susu Gula Aren',
      'now': '42 Cup',
      'rec': '75 Cup (+33 Cup)',
      'rationale': 'Lonjakan komuter jam makan siang (11.45 - 13.30). Stok saat ini berisiko stock-out pukul 12.15.',
      'color': Color(0xFFEF4444)
    },
    {
      'priority': 'HIGH',
      'cart': 'Stasiun Juanda (Roda Biru)',
      'product': 'Americano Double Shot',
      'now': '15 Cup',
      'rec': '45 Cup (+30 Cup)',
      'rationale': 'Kebutuhan asupan kafein pekerja kereta sore hari. Margin kotor tinggi Rp 10.500/cup.',
      'color': Color(0xFFF59E0B)
    },
    {
      'priority': 'MEDIUM',
      'cart': 'Taman Suropati (Gerobak Sore)',
      'product': 'Matcha Uji Latte Creamy',
      'now': '12 Cup',
      'rec': '35 Cup (+23 Cup)',
      'rationale': 'Pergeseran pola konsumsi non-kopi anak muda sore hari (15.00 - 18.00).',
      'color': Color(0xFF0284C7)
    },
    {
      'priority': 'MEDIUM',
      'cart': 'Pasar Senen (Mbak Ayu)',
      'product': 'Roti Bakar Cokelat Keju',
      'now': '8 Porsi',
      'rec': '25 Porsi (+17 Porsi)',
      'rationale': 'Tingkat bundling menu camilan dengan kopi mencapai 38% di area pasar.',
      'color': Color(0xFF0284C7)
    },
  ];

  final List<Map<String, dynamic>> _preOrders = const [
    {'id': 'PO-9041', 'customer': 'Rani Anggraini', 'seller': 'Pak Darto (Sudirman)', 'items': '2x Kopi Susu Aren (Pickup 11:45)', 'total': 'Rp 37.000', 'order_status': 'CONFIRMED', 'pay_status': 'PAID', 'ref': 'QRIS-GOPAY-849102'},
    {'id': 'PO-9040', 'customer': 'Bagus Prasetyo', 'seller': 'Roda Biru (Juanda)', 'items': '1x Americano (Pickup 11:30)', 'total': 'Rp 16.000', 'order_status': 'READY_FOR_PICKUP', 'pay_status': 'PAID', 'ref': 'QRIS-BCA-920145'},
    {'id': 'PO-9039', 'customer': 'Clarissa Olivia', 'seller': 'Mbak Ayu (Senen)', 'items': '2x Matcha Latte', 'total': 'Rp 49.000', 'order_status': 'PENDING_PAYMENT', 'pay_status': 'PENDING', 'ref': 'MENUNGGU PJP NOTIF'},
  ];

  final List<Map<String, dynamic>> _walkins = const [
    {'id': 'TX-20261114-089', 'seller': 'Pak Darto (Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 'Rp 36.000', 'method': 'QRIS_STATIC', 'time': '11:15 WIB'},
    {'id': 'TX-20261114-088', 'seller': 'Gerobak Sore (Suropati)', 'items': '1x Americano + 1x Roti Bakar', 'total': 'Rp 30.000', 'method': 'CASH', 'time': '11:08 WIB'},
    {'id': 'TX-20261114-087', 'seller': 'Mbak Ayu (Senen)', 'items': '3x Kopi Susu Aren', 'total': 'Rp 54.000', 'method': 'QRIS_STATIC', 'time': '10:55 WIB'},
    {'id': 'TX-20261114-086', 'seller': 'Roda Biru (Juanda)', 'items': '2x Cold Brew Citrus', 'total': 'Rp 40.000', 'method': 'QRIS_STATIC', 'time': '10:42 WIB'},
  ];

  final List<Map<String, dynamic>> _products = const [
    {'id': 'PRD-01', 'name': 'Kopi Susu Gula Aren', 'cat': 'Signature', 'hpp': 'Rp 7.500', 'price': 'Rp 18.000', 'margin': 'Rp 10.500', 'marginPct': '58.3%'},
    {'id': 'PRD-02', 'name': 'Americano Double Shot', 'cat': 'Classic Espresso', 'hpp': 'Rp 4.500', 'price': 'Rp 15.000', 'margin': 'Rp 10.500', 'marginPct': '70.0%'},
    {'id': 'PRD-03', 'name': 'Matcha Uji Latte Creamy', 'cat': 'Non-Coffee', 'hpp': 'Rp 9.500', 'price': 'Rp 24.000', 'margin': 'Rp 14.500', 'marginPct': '60.4%'},
    {'id': 'PRD-04', 'name': 'Cafe Latte Steam Velvet', 'cat': 'Signature', 'hpp': 'Rp 8.500', 'price': 'Rp 22.000', 'margin': 'Rp 13.500', 'marginPct': '61.4%'},
    {'id': 'PRD-05', 'name': 'Roti Bakar Cokelat Keju', 'cat': 'Camilan', 'hpp': 'Rp 6.000', 'price': 'Rp 15.000', 'margin': 'Rp 9.000', 'marginPct': '60.0%'},
    {'id': 'PRD-06', 'name': 'Cold Brew Citrus Signature', 'cat': 'Classic Espresso', 'hpp': 'Rp 7.000', 'price': 'Rp 20.000', 'margin': 'Rp 13.000', 'marginPct': '65.0%'},
  ];

  void _showDistributeModal() {
    String selectedSeller = 'GRB-01';
    String selectedProduct = 'PRD-01';
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
                decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.local_shipping_outlined, color: Color(0xFF0F172A)),
              ),
              const SizedBox(width: 12),
              const Text('Alokasi Stok ke Petugas Lapangan (Seller)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            ],
          ),
          content: SizedBox(
            width: 500,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih Petugas & Gerobak Tujuan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: selectedSeller,
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: 'GRB-01', child: Text('Budi Santoso • GRB-01 (Sudirman)')),
                    DropdownMenuItem(value: 'GRB-02', child: Text('Ahmad Fauzi • GRB-02 (Suropati)')),
                    DropdownMenuItem(value: 'GRB-03', child: Text('Siti Rahmawati • GRB-03 (Pasar Senen)')),
                    DropdownMenuItem(value: 'GRB-04', child: Text('Hendra Wijaya • GRB-04 (Juanda)')),
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
                  decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                  items: const [
                    DropdownMenuItem(value: 'PRD-01', child: Text('Kopi Susu Gula Aren (Sedia: 810 Cup)')),
                    DropdownMenuItem(value: 'PRD-02', child: Text('Americano Double Shot (Sedia: 605 Cup)')),
                    DropdownMenuItem(value: 'PRD-03', child: Text('Matcha Uji Latte Creamy (Sedia: 400 Cup)')),
                    DropdownMenuItem(value: 'PRD-04', child: Text('Cafe Latte Steam Velvet (Sedia: 480 Cup)')),
                  ],
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
                  decoration: InputDecoration(hintText: 'Contoh: 30', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B)))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Berhasil mendistribusikan alokasi stok ke gerobak seller!')),
                );
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
      color: const Color(0xFFF8FAFC), // Ultra-clean background
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar Nav
          _buildSidebar(),

          // 2. Main Content
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
      width: 270,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
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
            _sidebarCategory('MONITORING BISNIS'),
            _sidebarItem(0, Icons.grid_view_outlined, 'Executive Dashboard'),
            _sidebarItem(1, Icons.badge_outlined, 'Petugas Lapangan (Seller)', badge: '4 Aktif'),
            _sidebarItem(2, Icons.map_outlined, 'Peta Geospasial & Lapak', badge: '6 Titik'),

            const SizedBox(height: 14),
            _sidebarCategory('OPERASIONAL & STOK'),
            _sidebarItem(3, Icons.inventory_2_outlined, 'Stok Gudang & Distribusi'),
            _sidebarItem(4, Icons.psychology_outlined, 'AI Demand & Alokasi (MILP)', badge: 'Optimal'),
            _sidebarItem(5, Icons.receipt_long_outlined, 'Transaksi & QRIS PJP'),
            _sidebarItem(6, Icons.coffee_outlined, 'Master Produk & HPP'),

            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.all(18),
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
                        const Text('Koneksi Backend REST', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text('FastAPI :8000 • Database Live', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyinkronkan data bisnis terbaru...')));
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

  String _getSectionTitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Executive Dashboard & Financial KPI';
      case 1: return 'Monitoring Armada Petugas Lapangan (Seller)';
      case 2: return 'Peta Geospasial Titik Gerobak & Evaluasi Lapak';
      case 3: return 'Persediaan Stok Pusat & Mutasi Distribusi';
      case 4: return 'AI Demand Forecasting & Optimasi Alokasi (MILP)';
      case 5: return 'Monitoring Transaksi, Mutasi, dan Validasi QRIS PJP';
      case 6: return 'Master Produk, Biaya Pokok Produksi (HPP) & Margin';
      default: return 'Owner Executive Suite';
    }
  }

  Widget _buildSelectedView() {
    switch (_selectedNavIndex) {
      case 0: return _buildExecutiveDashboard();
      case 1: return _buildFieldStaffView();
      case 2: return _buildLocationsAndMapView();
      case 3: return _buildInventoryView();
      case 4: return _buildAiOptimizationView();
      case 5: return _buildTransactionsOrdersView();
      case 6: return _buildProductsView();
      default: return _buildExecutiveDashboard();
    }
  }

  // 0. EXECUTIVE DASHBOARD
  Widget _buildExecutiveDashboard() {
    List<Widget> kpiWidgets = [];
    for (int i = 0; i < _kpis.length; i++) {
      final k = _kpis[i];
      kpiWidgets.add(
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == _kpis.length - 1 ? 0 : 16.0),
            child: _kpiCard(k['title'], k['value'], k['sub'], k['icon'], k['color']),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: kpiWidgets),
        const SizedBox(height: 24),

        // Urgent Alert
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

        // Fleet Quick Overview
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
                      Text('Ringkasan Petugas Gerobak Hari Ini', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                      Text('Pantau performa penjualan dan kas masuk dari seluruh seller lapangan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _selectedNavIndex = 1),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('Lihat Detail Seluruh Petugas'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildStaffTableMini(),
            ],
          ),
        ),
      ],
    );
  }

  // 1. MONITORING PETUGAS LAPANGAN (SELLER) VIEW
  Widget _buildFieldStaffView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monitoring Armada Petugas Lapangan (Seller)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
                Text('Pantau lokasi live, nomor kontak, jadwal shift, uang kas fisik terkumpul, dan sisa stok gerobak.', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _showDistributeModal,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Kirim Alokasi Stok ke Petugas'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Staff Cards Grid
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: _fieldStaff.map((stf) {
            final isCritical = stf['status'] == 'PERLU RESTOCK';
            return Container(
              width: 380,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isCritical ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0), width: isCritical ? 1.5 : 1),
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
                            backgroundColor: const Color(0xFF0F172A),
                            child: Text(stf['name'].toString().substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(stf['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                              Text('ID: ${stf['staff_id']} • Telp: ${stf['phone']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      _statusBadge(stf['status'], stf['color']),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  _infoRow(Icons.storefront, 'Gerobak', stf['cart_id']),
                  _infoRow(Icons.location_on_outlined, 'Titik Posisi', stf['location']),
                  _infoRow(Icons.schedule, 'Jadwal Shift', stf['shift']),
                  _infoRow(Icons.gps_fixed, 'Status GPS/POS', stf['device_status']),

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
                            Text(stf['stock_left'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isCritical ? const Color(0xFFEF4444) : const Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Penjualan Hari Ini:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(stf['sales_cup'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Penerimaan Kasir Fisik (CASH):', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(stf['cash_collected'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Penerimaan QRIS Statis:', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                            Text(stf['qris_collected'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6366F1))),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Menghubungi nomor ${stf['phone']}...')));
                          },
                          icon: const Icon(Icons.phone_outlined, size: 16),
                          label: const Text('Hubungi', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 10)),
                          onPressed: _showDistributeModal,
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('Kirim Stok', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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

  // 2. PETA GEOSPASIAL & LOCATION SCORING VIEW
  Widget _buildLocationsAndMapView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pemetaan Geospasial & Location Scoring Titik Jualan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        const Text('Evaluasi titik lapak gerobak aktif dan analisis kandidat ekspansi berbasis skor AI (trafik pejalan kaki transit POI & historis).', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
        const SizedBox(height: 20),

        // Visual Map Representation Container
        Container(
          width: double.infinity,
          height: 320,
          decoration: BoxDecoration(
            color: const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1)),
          ),
          child: Stack(
            children: [
              // Map background mock
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: const Color(0xFFF1F5F9),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.blueGrey.shade200),
                        const SizedBox(height: 8),
                        Text('INTERACTIVE GEOSPATIAL MAP VIEW (JABODETABEK NETWORK)', style: TextStyle(color: Colors.blueGrey.shade400, fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.1)),
                        Text('Menampilkan 4 Titik Operasional Aktif • 2 Titik Kandidat Rekomendasi AI', style: TextStyle(color: Colors.blueGrey.shade400, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),

              // Simulated Map Markers
              _mapMarker(120, 80, 'GRB-01 Sudirman', '142 Cup', isOperasional: true),
              _mapMarker(240, 160, 'GRB-02 Suropati', '68 Cup', isOperasional: true),
              _mapMarker(380, 70, 'GRB-04 Juanda', '118 Cup (Restock!)', isOperasional: true, isCritical: true),
              _mapMarker(480, 140, 'GRB-03 Senen', '95 Cup', isOperasional: true),
              _mapMarker(600, 90, 'Kandidat AI: UI Salemba', 'Skor 87.4', isOperasional: false),
              _mapMarker(720, 190, 'Kandidat AI: Kuningan', 'Skor 84.1', isOperasional: false),

              // Map Overlay Badge
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(10), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                  child: const Row(
                    children: [
                      Icon(Icons.layers_outlined, color: Color(0xFF38BDF8), size: 16),
                      SizedBox(width: 8),
                      Text('Layer: Trafik Transit POI & Cuaca Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Location Detail Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Data Detail Titik Gerobak & Indikator AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(2),
                  3: FlexColumnWidth(2.2),
                  4: FlexColumnWidth(2.2),
                  5: FlexColumnWidth(1.2),
                  6: FlexColumnWidth(1.2),
                  7: FlexColumnWidth(1.2),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('ID'),
                      _th('Nama Area & Posisi'),
                      _th('Petugas Bertugas'),
                      _th('Trafik Pejalan Kaki'),
                      _th('Titik Transit POI'),
                      _th('Kondisi Cuaca'),
                      _th('Skor AI'),
                      _th('Status'),
                    ],
                  ),
                  ..._locationsWithMap.map((loc) {
                    return TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(loc['id']),
                        _td(loc['name'], bold: true),
                        _td(loc['seller_assigned']),
                        _td(loc['pedestrian_density']),
                        _td(loc['poi_nearby'], italic: true),
                        _td(loc['weather']),
                        _td('${loc['score']} / 100', bold: true, color: const Color(0xFF0284C7)),
                        _statusBadge(loc['status'], loc['color']),
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

  // 3. INVENTORY VIEW
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
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _showDistributeModal,
              icon: const Icon(Icons.local_shipping_outlined, size: 18),
              label: const Text('Buat Alokasi Distribusi Baru', style: TextStyle(fontWeight: FontWeight.bold)),
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
              ..._warehouse.map((inv) {
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(inv['sku']),
                    _td(inv['name'], bold: true),
                    _td(inv['stock']),
                    _td(inv['reserved']),
                    _td(inv['avail'], bold: true, color: const Color(0xFF0284C7)),
                    _statusBadge(inv['status'], inv['color']),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 4. AI OPTIMIZATION & FORECASTING VIEW
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
              ..._aiRecommendations.map((r) {
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _statusBadge(r['priority'], r['color']),
                    _td(r['cart'], bold: true),
                    _td(r['product']),
                    _td(r['now']),
                    _td(r['rec'], bold: true, color: const Color(0xFF10B981)),
                    _td(r['rationale'], italic: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8)),
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

  // 5. TRANSACTIONS & QRIS ORDERS
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
              ..._preOrders.map((o) {
                final isPaid = o['pay_status'] == 'PAID';
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(o['id']),
                    _td(o['customer'], bold: true),
                    _td(o['seller']),
                    _td(o['items']),
                    _td(o['total'], bold: true),
                    _statusBadge(o['order_status'], const Color(0xFF0284C7)),
                    _statusBadge(o['pay_status'], isPaid ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    _td(o['ref'], italic: true),
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
              ..._walkins.map((tx) {
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(tx['id']),
                    _td(tx['seller'], bold: true),
                    _td(tx['items']),
                    _td(tx['total'], bold: true, color: const Color(0xFF10B981)),
                    _statusBadge(tx['method'], tx['method'] == 'QRIS_STATIC' ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
                    _td(tx['time']),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // 6. MASTER PRODUCTS & MARGIN
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
                return TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(p['id']),
                    _td(p['name'], bold: true),
                    _td(p['cat']),
                    _td(p['hpp']),
                    _td(p['price'], bold: true),
                    _td(p['margin'], bold: true, color: const Color(0xFF10B981)),
                    _td(p['marginPct']),
                    _statusBadge('ACTIVE', const Color(0xFF10B981)),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  // Mini fleet table for Dashboard Overview
  Widget _buildStaffTableMini() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(2.5),
        2: FlexColumnWidth(1.5),
        3: FlexColumnWidth(1.8),
        4: FlexColumnWidth(1.5),
        5: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
          children: [
            _th('Petugas Seller'),
            _th('Titik Gerobak'),
            _th('Penjualan'),
            _th('Sisa Stok'),
            _th('Uang Fisik Kasir'),
            _th('Status'),
          ],
        ),
        ..._fieldStaff.map((stf) {
          return TableRow(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
            children: [
              _td(stf['name'], bold: true),
              _td(stf['cart_id']),
              _td(stf['sales_cup']),
              _td(stf['stock_left'], bold: true, color: stf['color']),
              _td(stf['cash_collected'], bold: true),
              _statusBadge(stf['status'], stf['color']),
            ],
          );
        }),
      ],
    );
  }

  Widget _mapMarker(double left, double top, String title, String subtitle, {bool isOperasional = true, bool isCritical = false}) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isCritical ? const Color(0xFFEF4444) : (isOperasional ? const Color(0xFF0F172A) : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isOperasional ? Colors.transparent : const Color(0xFFF59E0B), width: 1.5),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isOperasional ? Icons.coffee : Icons.place_outlined, color: isOperasional ? Colors.white : const Color(0xFFD97706), size: 14),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title, style: TextStyle(color: isOperasional ? Colors.white : const Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 11)),
                Text(subtitle, style: TextStyle(color: isOperasional ? const Color(0xFF38BDF8) : const Color(0xFF64748B), fontSize: 9)),
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
