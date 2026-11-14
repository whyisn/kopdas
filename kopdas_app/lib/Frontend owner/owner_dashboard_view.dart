import 'package:flutter/material.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  int _selectedNavIndex = 0;

  final List<Map<String, dynamic>> _kpis = const [
    {'title': 'Omzet Bruto Hari Ini', 'value': 'Rp 14.250.000', 'sub': '+18.4% vs kemarin', 'color': Color(0xFF10B981), 'icon': Icons.payments_outlined},
    {'title': 'Laba Bersih Operasional', 'value': 'Rp 8.120.000', 'sub': 'Margin Sehat 57.0%', 'color': Color(0xFF0284C7), 'icon': Icons.account_balance_wallet_outlined},
    {'title': 'Total Cup Terjual', 'value': '748 Cup', 'sub': 'Kapasitas Armada 62%', 'color': Color(0xFFF59E0B), 'icon': Icons.local_cafe_outlined},
    {'title': 'Penetrasi QRIS Statis', 'value': '68.4%', 'sub': 'Terverifikasi PJP', 'color': Color(0xFF6366F1), 'icon': Icons.qr_code_2},
  ];

  final List<Map<String, dynamic>> _fleet = const [
    {'id': 'GRB-01', 'seller': 'Pak Darto (Halte Sudirman)', 'sales': '142 Cup', 'omzet': 'Rp 2.840.000', 'stock': '42 / 120 Cup', 'status': 'OPTIMAL', 'color': Color(0xFF10B981)},
    {'id': 'GRB-02', 'seller': 'Gerobak Sore (Taman Suropati)', 'sales': '68 Cup', 'omzet': 'Rp 1.420.000', 'stock': '28 / 100 Cup', 'status': 'OPTIMAL', 'color': Color(0xFF10B981)},
    {'id': 'GRB-03', 'seller': 'Mbak Ayu (Pasar Senen)', 'sales': '95 Cup', 'omzet': 'Rp 1.980.000', 'stock': '35 / 120 Cup', 'status': 'OPTIMAL', 'color': Color(0xFF10B981)},
    {'id': 'GRB-04', 'seller': 'Roda Biru (Stasiun Juanda)', 'sales': '118 Cup', 'omzet': 'Rp 2.450.000', 'stock': '15 / 110 Cup', 'status': 'PERLU STOK', 'color': Color(0xFFEF4444)},
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
    {'id': 'PO-9041', 'customer': 'Rani Anggraini', 'seller': 'Pak Darto', 'items': '2x Kopi Susu Aren (Pickup 11:45)', 'total': 'Rp 37.000', 'order_status': 'CONFIRMED', 'pay_status': 'PAID', 'ref': 'QRIS-GOPAY-849102'},
    {'id': 'PO-9040', 'customer': 'Bagus Prasetyo', 'seller': 'Roda Biru', 'items': '1x Americano (Pickup 11:30)', 'total': 'Rp 16.000', 'order_status': 'READY_FOR_PICKUP', 'pay_status': 'PAID', 'ref': 'QRIS-BCA-920145'},
    {'id': 'PO-9039', 'customer': 'Clarissa Olivia', 'seller': 'Mbak Ayu', 'items': '2x Matcha Latte', 'total': 'Rp 49.000', 'order_status': 'PENDING_PAYMENT', 'pay_status': 'PENDING', 'ref': 'MENUNGGU PJP NOTIF'},
  ];

  final List<Map<String, dynamic>> _walkins = const [
    {'id': 'TX-20261114-089', 'seller': 'Pak Darto (Halte Sudirman)', 'items': '2x Kopi Susu Aren', 'total': 'Rp 36.000', 'method': 'QRIS_STATIC', 'time': '11:15 WIB'},
    {'id': 'TX-20261114-088', 'seller': 'Gerobak Sore (Taman Suropati)', 'items': '1x Americano + 1x Roti Bakar', 'total': 'Rp 30.000', 'method': 'CASH', 'time': '11:08 WIB'},
    {'id': 'TX-20261114-087', 'seller': 'Mbak Ayu (Pasar Senen)', 'items': '3x Kopi Susu Aren', 'total': 'Rp 54.000', 'method': 'QRIS_STATIC', 'time': '10:55 WIB'},
    {'id': 'TX-20261114-086', 'seller': 'Roda Biru (Stasiun Juanda)', 'items': '2x Cold Brew Citrus', 'total': 'Rp 40.000', 'method': 'QRIS_STATIC', 'time': '10:42 WIB'},
  ];

  final List<Map<String, dynamic>> _locations = const [
    {'id': 'LOC-01', 'name': 'Koridor Sudirman - Halte Dukuh Atas', 'seller': 'Pak Darto', 'density': 'Sangat Tinggi (1.450 org/jam)', 'sales': '142 Cup Hari Ini', 'score': '96.8 / 100', 'status': 'OPERASIONAL', 'color': Color(0xFF10B981)},
    {'id': 'LOC-02', 'name': 'Taman Suropati & Taman Kodok Menteng', 'seller': 'Gerobak Sore', 'density': 'Sedang (480 org/jam)', 'sales': '68 Cup Hari Ini', 'score': '88.5 / 100', 'status': 'OPERASIONAL', 'color': Color(0xFF10B981)},
    {'id': 'LOC-03', 'name': 'Pintu Timur Stasiun Juanda Commuter', 'seller': 'Roda Biru', 'density': 'Tinggi (980 org/jam)', 'sales': '118 Cup Hari Ini', 'score': '93.2 / 100', 'status': 'OPERASIONAL', 'color': Color(0xFF10B981)},
    {'id': 'LOC-04', 'name': 'Pasar Senen Blok III & Halte Senen', 'seller': 'Mbak Ayu', 'density': 'Tinggi (850 org/jam)', 'sales': '95 Cup Hari Ini', 'score': '90.0 / 100', 'status': 'OPERASIONAL', 'color': Color(0xFF10B981)},
    {'id': 'LOC-05', 'name': 'Area Kampus UI Salemba - Gedung Rektorat', 'seller': 'KANDIDAT AI', 'density': 'Potensi Tinggi (720 mhs/jam)', 'sales': '0 Cup', 'score': '87.4 / 100', 'status': 'KANDIDAT AI', 'color': Color(0xFFF59E0B)},
    {'id': 'LOC-06', 'name': 'Kawasan Perkantoran Kuningan Madya', 'seller': 'KANDIDAT AI', 'density': 'Potensi Tinggi (640 kry/jam)', 'sales': '0 Cup', 'score': '84.1 / 100', 'status': 'KANDIDAT AI', 'color': Color(0xFFF59E0B)},
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
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Berhasil mendistribusikan alokasi stok ke gerobak!')),
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
      color: const Color(0xFFF1F5F9), // Slate 100 enterprise background
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar Navigation
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
      child: SingleChildScrollView(
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

            // Navigation Links
            const SizedBox(height: 16),
            _sidebarItem(0, Icons.grid_view, 'Executive Dashboard'),
            _sidebarItem(1, Icons.inventory_2_outlined, 'Stok Gudang & Gerobak'),
            _sidebarItem(2, Icons.psychology_outlined, 'AI Demand & Alokasi (MILP)'),
            _sidebarItem(3, Icons.point_of_sale_outlined, 'Transaksi & Pembayaran QRIS'),
            _sidebarItem(4, Icons.map_outlined, 'Peta & Scoring Lokasi Gerobak'),
            _sidebarItem(5, Icons.menu_book_outlined, 'Master Produk & HPP'),

            const SizedBox(height: 24),

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
                    const Text('FastAPI :8000 • Terhubung', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
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
            border: isSelected ? Border.all(color: const Color(0xFF38BDF8).withOpacity(0.3)) : null,
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
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menyinkronkan data bisnis terbaru...')));
            },
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
      case 2: return 'AI Demand Forecasting & Mixed-Integer Linear Optimization (MILP)';
      case 3: return 'Monitoring Transaksi, Mutasi, dan Validasi QRIS PJP';
      case 4: return 'Pemetaan Geospasial & Location Scoring Titik Jualan';
      case 5: return 'Master Produk, Biaya Pokok Produksi (HPP) & Margin';
      default: return 'Owner Executive Suite';
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

    List<TableRow> fleetRows = [
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
      )
    ];

    for (final f in _fleet) {
      fleetRows.add(_fleetRow(f['id'], f['seller'], f['sales'], f['omzet'], f['stock'], f['status'], f['color']));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: kpiWidgets),
        const SizedBox(height: 24),

        // AI Urgent Warning Callout
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFFDE68A)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
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
                children: fleetRows,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // 2. INVENTORY MANAGEMENT VIEW
  Widget _buildInventoryView() {
    List<TableRow> warehouseRows = [
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
      )
    ];

    for (final inv in _warehouse) {
      warehouseRows.add(
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
          children: [
            _td(inv['sku']),
            _td(inv['name'], bold: true),
            _td(inv['stock']),
            _td(inv['reserved']),
            _td(inv['avail'], bold: true, color: const Color(0xFF0284C7)),
            _statusBadge(inv['status'], inv['color']),
          ],
        ),
      );
    }

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
            children: warehouseRows,
          ),
        ),
      ],
    );
  }

  // 3. AI OPTIMIZATION & FORECASTING VIEW
  Widget _buildAiOptimizationView() {
    List<TableRow> aiRows = [
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
      )
    ];

    for (final r in _aiRecommendations) {
      aiRows.add(
        TableRow(
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
        ),
      );
    }

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
              child: const Text(
                'Solver Status: MILP_OPTIMAL',
                style: TextStyle(color: Color(0xFF38BDF8), fontWeight: FontWeight.bold, fontSize: 12),
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menjalankan kembali solver matematis MILP dengan parameter terbaru...')),
                  );
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
            children: aiRows,
          ),
        ),
      ],
    );
  }

  // 4. TRANSACTIONS & QRIS ORDERS VIEW
  Widget _buildTransactionsOrdersView() {
    List<TableRow> poRows = [
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
      )
    ];

    for (final o in _preOrders) {
      final isPaid = o['pay_status'] == 'PAID';
      poRows.add(
        TableRow(
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
        ),
      );
    }

    List<TableRow> walkinRows = [
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
      )
    ];

    for (final tx in _walkins) {
      walkinRows.add(
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
          children: [
            _td(tx['id']),
            _td(tx['seller'], bold: true),
            _td(tx['items']),
            _td(tx['total'], bold: true, color: const Color(0xFF10B981)),
            _statusBadge(tx['method'], tx['method'] == 'QRIS_STATIC' ? const Color(0xFF6366F1) : const Color(0xFF64748B)),
            _td(tx['time']),
          ],
        ),
      );
    }

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
            children: poRows,
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
            children: walkinRows,
          ),
        ),
      ],
    );
  }

  // 5. LOCATIONS & SCORING VIEW
  Widget _buildLocationsView() {
    List<TableRow> locRows = [
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
      )
    ];

    for (final loc in _locations) {
      locRows.add(
        TableRow(
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
          children: [
            _td(loc['id']),
            _td(loc['name'], bold: true),
            _td(loc['seller']),
            _td(loc['density']),
            _td(loc['sales']),
            _td(loc['score'], bold: true, color: const Color(0xFF0284C7)),
            _statusBadge(loc['status'], loc['color']),
          ],
        ),
      );
    }

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
            children: locRows,
          ),
        ),
      ],
    );
  }

  // 6. MASTER PRODUCTS & MARGIN VIEW
  Widget _buildProductsView() {
    List<TableRow> productRows = [
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
      )
    ];

    for (final p in _products) {
      productRows.add(
        TableRow(
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
        ),
      );
    }

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
            children: productRows,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
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
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }
}
