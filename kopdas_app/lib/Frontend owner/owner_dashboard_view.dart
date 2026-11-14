import 'package:flutter/material.dart';

class OwnerDashboardView extends StatefulWidget {
  const OwnerDashboardView({super.key});

  @override
  State<OwnerDashboardView> createState() => _OwnerDashboardViewState();
}

class _OwnerDashboardViewState extends State<OwnerDashboardView> {
  // 13 Navigation Menu Indices:
  // 0: Dashboard, 1: Tim Lapangan, 2: Absensi, 3: Peta Monitoring, 4: Manajemen Lokasi,
  // 5: Gudang & Inventori, 6: Distribusi Stok, 7: Penjualan, 8: Pesanan, 9: Komisi,
  // 10: Traffic & Opportunity Radar, 11: Analitik & Laporan, 12: Pengaturan
  int _selectedNavIndex = 0;

  // Global Date Filter (Asia/Jakarta timezone context)
  String _activeDateFilter = 'HARI_INI'; // HARI_INI, KEMARIN, 7_HARI, 30_HARI, KUSTOM

  // Search & Filter Controllers
  String _staffSearchQuery = '';

  // ===========================================================================
  // 1. DATA TIM LAPANGAN (AKUN & STATUS OPERASIONAL KANONIS)
  // ===========================================================================
  final List<Map<String, dynamic>> _staffList = [
    {
      'id': 'USR-SLR-01',
      'username': 'budi_sudirman',
      'name': 'Budi Santoso',
      'phone': '0812-8821-9901',
      'email': 'budi.santoso@kopicerdas.id',
      'account_status': 'ACTIVE', // ACTIVE, INACTIVE, SUSPENDED
      'operational_status': 'ACTIVE_SELLING', // OFFLINE, NOT_STARTED, ACTIVE_SELLING, BREAK, COMPLETED_SHIFT
      'role_title': 'Seller Lead (Senior)',
      'cart_id': 'GRB-01 (Sudirman Core)',
      'assigned_location': 'Halte Dukuh Atas Sudirman',
      'join_date': '12 Jan 2026',
      'start_shift_time': '06:15 WIB',
      'last_gps_update': '2 menit lalu (-6.2088, 106.8227)',
      'gps_accuracy': 'Akurasi 4m (Tinggi)',
      'is_gps_fresh': true,
      'map_x': 180.0,
      'map_y': 150.0,
      'stock_held': 42,
      'stock_capacity': 120,
      'cups_sold_today': 142,
      'cash_collected': 900000,
      'qris_collected': 1940000,
      'total_commission': 284000,
      'commission_paid': false,
    },
    {
      'id': 'USR-SLR-02',
      'username': 'ahmad_suropati',
      'name': 'Ahmad Fauzi',
      'phone': '0813-1102-4451',
      'email': 'ahmad.fauzi@kopicerdas.id',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'role_title': 'Seller Reguler',
      'cart_id': 'GRB-02 (Suropati Lounge)',
      'assigned_location': 'Taman Suropati & Taman Kodok Menteng',
      'join_date': '04 Feb 2026',
      'start_shift_time': '06:40 WIB',
      'last_gps_update': '4 menit lalu (-6.1994, 106.8326)',
      'gps_accuracy': 'Akurasi 6m (Baik)',
      'is_gps_fresh': true,
      'map_x': 320.0,
      'map_y': 110.0,
      'stock_held': 28,
      'stock_capacity': 100,
      'cups_sold_today': 68,
      'cash_collected': 520000,
      'qris_collected': 900000,
      'total_commission': 136000,
      'commission_paid': false,
    },
    {
      'id': 'USR-SLR-03',
      'username': 'siti_senen',
      'name': 'Siti Rahmawati',
      'phone': '0857-4491-0023',
      'email': 'siti.rahma@kopicerdas.id',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'role_title': 'Seller Reguler',
      'cart_id': 'GRB-03 (Pasar Senen)',
      'assigned_location': 'Pojok Blok III & Halte Senen Sentral',
      'join_date': '18 Feb 2026',
      'start_shift_time': '05:30 WIB',
      'last_gps_update': '5 menit lalu (-6.1744, 106.8432)',
      'gps_accuracy': 'Akurasi 5m (Tinggi)',
      'is_gps_fresh': true,
      'map_x': 460.0,
      'map_y': 70.0,
      'stock_held': 35,
      'stock_capacity': 120,
      'cups_sold_today': 95,
      'cash_collected': 640000,
      'qris_collected': 1340000,
      'total_commission': 190000,
      'commission_paid': false,
    },
    {
      'id': 'USR-SLR-04',
      'username': 'hendra_juanda',
      'name': 'Hendra Wijaya',
      'phone': '0821-7781-3312',
      'email': 'hendra.wijaya@kopicerdas.id',
      'account_status': 'ACTIVE',
      'operational_status': 'ACTIVE_SELLING',
      'role_title': 'Seller Reguler',
      'cart_id': 'GRB-04 (Juanda Transit)',
      'assigned_location': 'Pintu Timur Stasiun Commuter Juanda',
      'join_date': '01 Mar 2026',
      'start_shift_time': '05:50 WIB',
      'last_gps_update': '1 menit lalu (-6.1668, 106.8312)',
      'gps_accuracy': 'Akurasi 3m (Sangat Baik)',
      'is_gps_fresh': true,
      'map_x': 270.0,
      'map_y': 40.0,
      'stock_held': 15,
      'stock_capacity': 110,
      'cups_sold_today': 118,
      'cash_collected': 780000,
      'qris_collected': 1670000,
      'total_commission': 236000,
      'commission_paid': false,
    },
    {
      'id': 'USR-SLR-05',
      'username': 'rizky_kuningan',
      'name': 'Rizky Pratama',
      'phone': '0812-9900-1122',
      'email': 'rizky.pratama@kopicerdas.id',
      'account_status': 'ACTIVE',
      'operational_status': 'NOT_STARTED',
      'role_title': 'Seller Trainee',
      'cart_id': 'GRB-05 (Standby)',
      'assigned_location': 'Kuningan Madya (Lapak Kandidat)',
      'join_date': '10 Nov 2026',
      'start_shift_time': 'Belum Mulai Shift',
      'last_gps_update': 'Stale (>1 jam tidak aktif)',
      'gps_accuracy': 'GPS Offline',
      'is_gps_fresh': false,
      'map_x': 240.0,
      'map_y': 230.0,
      'stock_held': 0,
      'stock_capacity': 100,
      'cups_sold_today': 0,
      'cash_collected': 0,
      'qris_collected': 0,
      'total_commission': 0,
      'commission_paid': false,
    },
  ];

  // ===========================================================================
  // 2. DATA ABSENSI & SHIFT KERJA
  // ===========================================================================
  final List<Map<String, dynamic>> _attendanceRecords = [
    {
      'id': 'ATT-20261114-01',
      'staff_id': 'USR-SLR-01',
      'name': 'Budi Santoso',
      'date': '14 Nov 2026',
      'clock_in': '06:15 WIB',
      'clock_out': '--:--',
      'duration': '7 jam 30 menit (Berjalan)',
      'status': 'ON_TIME',
      'late_minutes': 0,
      'gps_lat_long': '-6.2088, 106.8227 (Akurasi 4m)',
      'correction_note': 'Sesuai shift pagi gerobak Sudirman',
      'corrected_by': '-',
    },
    {
      'id': 'ATT-20261114-02',
      'staff_id': 'USR-SLR-02',
      'name': 'Ahmad Fauzi',
      'date': '14 Nov 2026',
      'clock_in': '06:40 WIB',
      'clock_out': '--:--',
      'duration': '7 jam 05 menit (Berjalan)',
      'status': 'TERLAMBAT (10m)',
      'late_minutes': 10,
      'gps_lat_long': '-6.1994, 106.8326 (Akurasi 6m)',
      'correction_note': 'Kendala rantai gerobak diperbaiki',
      'corrected_by': 'Owner Admin',
    },
    {
      'id': 'ATT-20261114-03',
      'staff_id': 'USR-SLR-03',
      'name': 'Siti Rahmawati',
      'date': '14 Nov 2026',
      'clock_in': '05:30 WIB',
      'clock_out': '--:--',
      'duration': '8 jam 15 menit (Berjalan)',
      'status': 'ON_TIME',
      'late_minutes': 0,
      'gps_lat_long': '-6.1744, 106.8432 (Akurasi 5m)',
      'correction_note': '-',
      'corrected_by': '-',
    },
    {
      'id': 'ATT-20261114-04',
      'staff_id': 'USR-SLR-04',
      'name': 'Hendra Wijaya',
      'date': '14 Nov 2026',
      'clock_in': '05:50 WIB',
      'clock_out': '--:--',
      'duration': '7 jam 55 menit (Berjalan)',
      'status': 'ON_TIME',
      'late_minutes': 0,
      'gps_lat_long': '-6.1668, 106.8312 (Akurasi 3m)',
      'correction_note': '-',
      'corrected_by': '-',
    },
    {
      'id': 'ATT-20261114-05',
      'staff_id': 'USR-SLR-05',
      'name': 'Rizky Pratama',
      'date': '14 Nov 2026',
      'clock_in': 'Belum Absen',
      'clock_out': '--:--',
      'duration': '0 jam',
      'status': 'TIDAK HADIR / BELUM SHIFT',
      'late_minutes': 0,
      'gps_lat_long': 'Lokasi tidak terekam',
      'correction_note': 'Shift siang jadwal 14:00 WIB',
      'corrected_by': 'Sistem Auto',
    },
  ];

  // ===========================================================================
  // 3. DATA GUDANG PUSAT & MUTASI INVENTORI
  // ===========================================================================
  final List<Map<String, dynamic>> _warehouseCatalog = [
    {
      'sku': 'PRD-01',
      'name': 'Kopi Susu Gula Aren',
      'category': 'Signature Milk Coffee',
      'unit': 'Cup',
      'cost_price': 7500,
      'sell_price': 18000,
      'stock_central': 950,
      'stock_allocated': 160,
      'stock_held_by_staff': 120,
      'stock_damaged': 2,
      'min_limit': 150,
      'status': 'AMAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-02',
      'name': 'Americano Double Shot',
      'category': 'Classic Espresso',
      'unit': 'Cup',
      'cost_price': 4500,
      'sell_price': 15000,
      'stock_central': 650,
      'stock_allocated': 90,
      'stock_held_by_staff': 75,
      'stock_damaged': 0,
      'min_limit': 100,
      'status': 'AMAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-03',
      'name': 'Matcha Uji Latte Creamy',
      'category': 'Non-Coffee Premium',
      'unit': 'Cup',
      'cost_price': 9000,
      'sell_price': 22000,
      'stock_central': 430,
      'stock_allocated': 60,
      'stock_held_by_staff': 45,
      'stock_damaged': 1,
      'min_limit': 80,
      'status': 'AMAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-04',
      'name': 'Cafe Latte Steam Velvet',
      'category': 'Signature Milk Coffee',
      'unit': 'Cup',
      'cost_price': 8000,
      'sell_price': 20000,
      'stock_central': 520,
      'stock_allocated': 50,
      'stock_held_by_staff': 40,
      'stock_damaged': 0,
      'min_limit': 80,
      'status': 'AMAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-05',
      'name': 'Cold Brew Citrus Refresh',
      'category': 'Artisan Brew',
      'unit': 'Cup',
      'cost_price': 8500,
      'sell_price': 22000,
      'stock_central': 310,
      'stock_allocated': 40,
      'stock_held_by_staff': 30,
      'stock_damaged': 0,
      'min_limit': 60,
      'status': 'AMAN',
      'status_color': const Color(0xFF10B981),
    },
    {
      'sku': 'PRD-06',
      'name': 'Roti Bakar Kaya Butter',
      'category': 'Bakery & Bites',
      'unit': 'Porsi',
      'cost_price': 6000,
      'sell_price': 15000,
      'stock_central': 140,
      'stock_allocated': 40,
      'stock_held_by_staff': 35,
      'stock_damaged': 3,
      'min_limit': 150,
      'status': 'MENDEKATI MINIMUM',
      'status_color': const Color(0xFFF59E0B),
    },
  ];

  // Riwayat Mutasi Stok (Stock Movements)
  final List<Map<String, dynamic>> _stockMovements = [
    {
      'id': 'MOV-9901',
      'time': '07:15 WIB',
      'sku': 'PRD-01',
      'product_name': 'Kopi Susu Gula Aren',
      'from_scope': 'Gudang Pusat (Central)',
      'to_scope': 'Budi Santoso (GRB-01)',
      'qty': 60,
      'type': 'DISTRIBUSI_PAGI',
      'actor': 'Owner Admin',
      'reference': 'DIST-SHIFT-PAGI-01',
      'notes': 'Stok kuota pagi disetujui',
    },
    {
      'id': 'MOV-9902',
      'time': '07:05 WIB',
      'sku': 'PRD-02',
      'product_name': 'Americano Double Shot',
      'from_scope': 'Gudang Pusat (Central)',
      'to_scope': 'Hendra (GRB-04)',
      'qty': 50,
      'type': 'DISTRIBUSI_PAGI',
      'actor': 'Owner Admin',
      'reference': 'DIST-SHIFT-PAGI-04',
      'notes': 'Stok komuter Juanda',
    },
    {
      'id': 'MOV-9903',
      'time': 'Kemarin 21:00',
      'sku': 'PRD-01',
      'product_name': 'Kopi Susu Gula Aren',
      'from_scope': 'Supplier Roastery Gayo',
      'to_scope': 'Gudang Pusat (Central)',
      'qty': 500,
      'type': 'INBOUND_SUPPLIER',
      'actor': 'Owner Admin',
      'reference': 'PO-SUPP-8821',
      'notes': 'Pasokan biji sangrai segar batch 14',
    },
  ];

  // ===========================================================================
  // 4. DATA TITIK LOKASI JUALAN & TRAFFIC RADAR
  // ===========================================================================
  final List<Map<String, dynamic>> _locationMaster = [
    {
      'id': 'LOC-01',
      'name': 'Koridor Sudirman - Halte Dukuh Atas BNI',
      'address': 'Depan Menara Astra & Akses MRT Dukuh Atas',
      'lat_long': '-6.2088, 106.8227',
      'area_cluster': 'Jakarta Pusat - Transit Komuter',
      'assigned_seller': 'Budi Santoso (GRB-01)',
      'status': 'AKTIF TERISI',
      'is_occupied': true,
      'avg_daily_cups': 145,
      'peak_hours': '07:00 - 09:30 & 17:00 - 19:30 WIB',
      'road_traffic_level': 'Padat Bergerak (Routes API Live)',
      'foot_traffic_density': '1.450 pejalan/jam',
      'potential_score': 96.8,
      'weather_state': 'Cerah 31°C (Tinggi Minat Es)',
      'recommended_quota': '120 Cup (Susu Aren 60, Americano 40, Latte 20)',
    },
    {
      'id': 'LOC-02',
      'name': 'Taman Suropati & Taman Kodok Menteng',
      'address': 'Ring Lingkar Taman Suropati No. 5',
      'lat_long': '-6.1994, 106.8326',
      'area_cluster': 'Jakarta Pusat - Komunitas & Santai',
      'assigned_seller': 'Ahmad Fauzi (GRB-02)',
      'status': 'AKTIF TERISI',
      'is_occupied': true,
      'avg_daily_cups': 75,
      'peak_hours': '06:30 - 08:30 & 16:30 - 18:30 WIB',
      'road_traffic_level': 'Lancar hingga Sedang',
      'foot_traffic_density': '480 pejalan/jam',
      'potential_score': 88.5,
      'weather_state': 'Teduh Rindang 29°C',
      'recommended_quota': '100 Cup (Matcha 40, Susu Aren 30, Roti 30)',
    },
    {
      'id': 'LOC-03',
      'name': 'Pintu Timur Stasiun Juanda Commuter',
      'address': 'Pintu Keluar Gate Kereta Commuter Line Juanda',
      'lat_long': '-6.1668, 106.8312',
      'area_cluster': 'Jakarta Pusat - Hub Transportasi Kereta',
      'assigned_seller': 'Hendra Wijaya (GRB-04)',
      'status': 'AKTIF TERISI',
      'is_occupied': true,
      'avg_daily_cups': 125,
      'peak_hours': '06:00 - 09:00 & 16:00 - 19:00 WIB',
      'road_traffic_level': 'Padat Lancar',
      'foot_traffic_density': '1.980 pejalan/jam',
      'potential_score': 93.2,
      'weather_state': 'Cerah Berawan 30°C',
      'recommended_quota': '110 Cup (Americano 50, Susu Aren 40, Cold Brew 20)',
    },
    {
      'id': 'LOC-04',
      'name': 'Pasar Senen Blok III & Halte Senen Sentral',
      'address': 'Koridor Pintu Masuk Pasar Grosir Senen Blok 3',
      'lat_long': '-6.1744, 106.8432',
      'area_cluster': 'Jakarta Pusat - Pasar & Niaga',
      'assigned_seller': 'Siti Rahmawati (GRB-03)',
      'status': 'AKTIF TERISI',
      'is_occupied': true,
      'avg_daily_cups': 105,
      'peak_hours': '05:30 - 09:00 WIB',
      'road_traffic_level': 'Sangat Padat',
      'foot_traffic_density': '850 pejalan/jam',
      'potential_score': 90.0,
      'weather_state': 'Panas 32°C',
      'recommended_quota': '120 Cup (Susu Aren 70, Roti 30, Kopi Hitam 20)',
    },
    {
      'id': 'LOC-05',
      'name': 'Area Kampus UI Salemba - Gedung Rektorat',
      'address': 'Depan Perpustakaan Salemba & Dekat RSCM',
      'lat_long': '-6.1951, 106.8504',
      'area_cluster': 'Jakarta Pusat - Pendidikan & Medis',
      'assigned_seller': 'KOSONG (SIAP DITUGASKAN)',
      'status': 'KANDIDAT TERSEDIA',
      'is_occupied': false,
      'avg_daily_cups': 85,
      'peak_hours': '07:30 - 11:30 & 13:00 - 15:30 WIB',
      'road_traffic_level': 'Sedang Normal',
      'foot_traffic_density': '720 pejalan/jam',
      'potential_score': 87.4,
      'weather_state': 'Cerah 30°C',
      'recommended_quota': '90 Cup (Matcha 35, Aren 35, Cold Brew 20)',
    },
    {
      'id': 'LOC-06',
      'name': 'Kawasan Perkantoran Kuningan Madya',
      'address': 'Plaza Kuningan & Koridor HR Rasuna Said',
      'lat_long': '-6.2185, 106.8302',
      'area_cluster': 'Jakarta Selatan - CBD Perkantoran',
      'assigned_seller': 'KOSONG (SIAP DITUGASKAN)',
      'status': 'KANDIDAT TERSEDIA',
      'is_occupied': false,
      'avg_daily_cups': 95,
      'peak_hours': '08:00 - 10:00 & 12:00 - 14:00 WIB',
      'road_traffic_level': 'Padat Merayap (Routes Live)',
      'foot_traffic_density': '640 pejalan/jam',
      'potential_score': 84.1,
      'weather_state': 'Cerah 31°C',
      'recommended_quota': '100 Cup (Americano 50, Aren 30, Latte 20)',
    },
  ];

  // ===========================================================================
  // 5. DATA ATURAN & SISTEM KOMISI
  // ===========================================================================
  final List<Map<String, dynamic>> _commissionRules = [
    {
      'rule_id': 'RULE-AREN',
      'product_name': 'Kopi Susu Gula Aren',
      'sku': 'PRD-01',
      'type': 'PER_CUP',
      'rate_nominal': 2000,
      'active_since': '01 Jan 2026',
      'status': 'BERLAKU AKTIF',
    },
    {
      'rule_id': 'RULE-AMERICANO',
      'product_name': 'Americano Double Shot',
      'sku': 'PRD-02',
      'type': 'PER_CUP',
      'rate_nominal': 1500,
      'active_since': '01 Jan 2026',
      'status': 'BERLAKU AKTIF',
    },
    {
      'rule_id': 'RULE-MATCHA',
      'product_name': 'Matcha Uji Latte Creamy',
      'sku': 'PRD-03',
      'type': 'PER_CUP',
      'rate_nominal': 2000,
      'active_since': '01 Jan 2026',
      'status': 'BERLAKU AKTIF',
    },
    {
      'rule_id': 'RULE-LATTE',
      'product_name': 'Cafe Latte Steam Velvet',
      'sku': 'PRD-04',
      'type': 'PER_CUP',
      'rate_nominal': 2000,
      'active_since': '01 Jan 2026',
      'status': 'BERLAKU AKTIF',
    },
    {
      'rule_id': 'RULE-ROTI',
      'product_name': 'Roti Bakar Kaya Butter',
      'sku': 'PRD-06',
      'type': 'PER_PORSI',
      'rate_nominal': 1000,
      'active_since': '15 Feb 2026',
      'status': 'BERLAKU AKTIF',
    },
  ];

  // ===========================================================================
  // 6. DATA LIVE TRANSAKSI & PESANAN (QRIS PJP VERIFIED)
  // ===========================================================================
  final List<Map<String, dynamic>> _transactionsList = [
    {
      'id': 'TRX-20261114-089',
      'time': '13:42 WIB',
      'seller_name': 'Budi Santoso (Sudirman)',
      'cart_id': 'GRB-01',
      'items_summary': '2x Kopi Susu Aren',
      'total': 36000,
      'payment_method': 'QRIS_STATIC',
      'payment_status': 'PAID',
      'pjp_acquirer': 'BCA QRIS Webhook',
      'idempotency': 'IDEM-99214-BCA',
    },
    {
      'id': 'TRX-20261114-088',
      'time': '13:38 WIB',
      'seller_name': 'Hendra Wijaya (Juanda)',
      'cart_id': 'GRB-04',
      'items_summary': '1x Americano Double Shot',
      'total': 15000,
      'payment_method': 'CASH',
      'payment_status': 'PAID',
      'pjp_acquirer': 'Kasir Fisik Lapangan',
      'idempotency': 'IDEM-99213-CASH',
    },
    {
      'id': 'TRX-20261114-087',
      'time': '13:25 WIB',
      'seller_name': 'Ahmad Fauzi (Suropati)',
      'cart_id': 'GRB-02',
      'items_summary': '1x Matcha Latte + 1x Roti Bakar',
      'total': 37000,
      'payment_method': 'QRIS_STATIC',
      'payment_status': 'PAID',
      'pjp_acquirer': 'GoPay QRIS Webhook',
      'idempotency': 'IDEM-99212-GOPAY',
    },
    {
      'id': 'TRX-20261114-086',
      'time': '13:14 WIB',
      'seller_name': 'Siti Rahmawati (Senen)',
      'cart_id': 'GRB-03',
      'items_summary': '2x Kopi Susu Aren (Less Sugar)',
      'total': 36000,
      'payment_method': 'CASH',
      'payment_status': 'PAID',
      'pjp_acquirer': 'Kasir Fisik Lapangan',
      'idempotency': 'IDEM-99211-CASH',
    },
  ];

  final List<Map<String, dynamic>> _ordersList = [
    {
      'order_no': 'ORD-PO-9042',
      'time': '13:40 WIB',
      'customer': 'Farhan Maulana',
      'phone': '0812-7711-4491',
      'seller': 'Budi Santoso (Sudirman)',
      'cart_id': 'GRB-01',
      'items': '1x Cafe Latte + 1x Roti Bakar Kaya',
      'total': 35000,
      'order_status': 'PREPARING',
      'payment_status': 'PAID',
      'payment_method': 'QRIS_STATIC',
      'pjp_ref': 'QRIS-BCA-920145 (Verified)',
      'pickup_estimate': '13:55 WIB di Halte BNI',
    },
    {
      'order_no': 'ORD-PO-9041',
      'time': '13:28 WIB',
      'customer': 'Rani Anggraini',
      'phone': '0856-1188-9922',
      'seller': 'Budi Santoso (Sudirman)',
      'cart_id': 'GRB-01',
      'items': '2x Kopi Susu Aren',
      'total': 36000,
      'order_status': 'READY_FOR_PICKUP',
      'payment_status': 'PAID',
      'payment_method': 'QRIS_STATIC',
      'pjp_ref': 'QRIS-GOPAY-849102 (Verified)',
      'pickup_estimate': 'Siap Diambil Sekarang',
    },
    {
      'order_no': 'ORD-PO-9040',
      'time': '13:10 WIB',
      'customer': 'Bagus Prasetyo',
      'phone': '0819-3322-1100',
      'seller': 'Hendra Wijaya (Juanda)',
      'cart_id': 'GRB-04',
      'items': '1x Americano Double Shot',
      'total': 15000,
      'order_status': 'COMPLETED',
      'payment_status': 'PAID',
      'payment_method': 'QRIS_STATIC',
      'pjp_ref': 'QRIS-BCA-889102 (Settled)',
      'pickup_estimate': 'Selesai 13:20 WIB',
    },
    {
      'order_no': 'ORD-PO-9039',
      'time': '13:35 WIB',
      'customer': 'Clarissa Olivia',
      'phone': '0822-4455-6677',
      'seller': 'Siti Rahmawati (Senen)',
      'cart_id': 'GRB-03',
      'items': '2x Matcha Uji Latte Creamy',
      'total': 44000,
      'order_status': 'PENDING_PAYMENT',
      'payment_status': 'PENDING',
      'payment_method': 'QRIS_STATIC',
      'pjp_ref': 'Menunggu Webhook Provider Acquirer',
      'pickup_estimate': 'Belum Bayar (Batas 13:50)',
    },
  ];

  // ===========================================================================
  // INTERACTIVE MODAL ACTIONS
  // ===========================================================================

  // MODAL 1: Tambah Akun Petugas Lapangan Baru
  void _showAddStaffModal() {
    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final cartCtrl = TextEditingController(text: 'GRB-0${_staffList.length + 1}');
    String selectedRole = 'Seller Reguler';
    String assignedSpot = _locationMaster.firstWhere((l) => !l['is_occupied'])['name'];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
                          Text('Tambah Akun Petugas Lapangan Baru', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
                          Text('Buat kredensial login, hak akses, dan penugasan unit gerobak', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text('1. Data Identitas & Kredensial Akun:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 10),
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Lengkap Petugas', hintText: 'Contoh: Joko Widodo', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person_outline, size: 20))),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'Username Login Aplikasi', hintText: 'joko_sudirman', border: OutlineInputBorder(), prefixIcon: Icon(Icons.badge_outlined, size: 20)))),
                      const SizedBox(width: 12),
                      Expanded(child: TextField(controller: phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor WhatsApp Aktif', hintText: '0812-xxxx-xxxx', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone_outlined, size: 20)))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email Petugas (Opsional)', hintText: 'joko@kopicerdas.id', border: OutlineInputBorder(), prefixIcon: Icon(Icons.email_outlined, size: 20))),
                  const SizedBox(height: 18),

                  const Text('2. Penugasan Unit Gerobak & Wilayah Awal:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: TextField(controller: cartCtrl, decoration: const InputDecoration(labelText: 'ID Gerobak', border: OutlineInputBorder(), prefixIcon: Icon(Icons.storefront_outlined, size: 20)))),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedRole,
                          decoration: const InputDecoration(labelText: 'Peran / Jabatan', border: OutlineInputBorder()),
                          items: const [
                            DropdownMenuItem(value: 'Seller Lead (Senior)', child: Text('Seller Lead (Senior)')),
                            DropdownMenuItem(value: 'Seller Reguler', child: Text('Seller Reguler')),
                            DropdownMenuItem(value: 'Seller Trainee', child: Text('Seller Trainee')),
                          ],
                          onChanged: (val) {
                            if (val != null) setModalState(() => selectedRole = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: assignedSpot,
                    decoration: const InputDecoration(labelText: 'Rencana Lapak Tujuan', border: OutlineInputBorder()),
                    items: _locationMaster.map((loc) => DropdownMenuItem(value: loc['name'].toString(), child: Text(loc['name'].toString(), overflow: TextOverflow.ellipsis))).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => assignedSpot = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFF0284C7), size: 18),
                        SizedBox(width: 8),
                        Expanded(child: Text('Status awal akun adalah ACTIVE (Aktif), namun status operasional tetap NOT_STARTED hingga petugas login, absen masuk, dan menerima stok.', style: TextStyle(fontSize: 11, color: Color(0xFF334155)))),
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
                          setState(() {
                            _staffList.add({
                              'id': 'USR-SLR-0${_staffList.length + 1}',
                              'username': userCtrl.text.isNotEmpty ? userCtrl.text : 'seller_${_staffList.length + 1}',
                              'name': nameCtrl.text,
                              'phone': phoneCtrl.text.isNotEmpty ? phoneCtrl.text : '0812-0000-0000',
                              'email': emailCtrl.text.isNotEmpty ? emailCtrl.text : '-',
                              'account_status': 'ACTIVE',
                              'operational_status': 'NOT_STARTED',
                              'role_title': selectedRole,
                              'cart_id': cartCtrl.text,
                              'assigned_location': assignedSpot,
                              'join_date': '${DateTime.now().day} Nov ${DateTime.now().year}',
                              'start_shift_time': 'Belum Mulai Shift',
                              'last_gps_update': 'Belum Ada Telemetri',
                              'gps_accuracy': 'Offline',
                              'is_gps_fresh': false,
                              'map_x': 250.0 + (_staffList.length * 20),
                              'map_y': 150.0,
                              'stock_held': 0,
                              'stock_capacity': 100,
                              'cups_sold_today': 0,
                              'cash_collected': 0,
                              'qris_collected': 0,
                              'total_commission': 0,
                              'commission_paid': false,
                            });
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF10B981), content: Text('Akun petugas "${nameCtrl.text}" berhasil didaftarkan!')));
                        },
                        child: const Text('Simpan Akun Petugas', style: TextStyle(fontWeight: FontWeight.bold)),
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
    String selectedSku = _warehouseCatalog.first['sku'];
    final qtyCtrl = TextEditingController(text: '100');
    final batchCtrl = TextEditingController(text: 'ROAST-BATCH-${DateTime.now().month}${DateTime.now().day}');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(26),
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
                          Text('Input Pasokan Stok Gudang Pusat', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
                          Text('Catat pasokan roasting biji kopi & bahan masuk resmi', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text('Pilih Produk / Bahan Baku Kopi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSku,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _warehouseCatalog.map((w) {
                      return DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['sku']} • ${w['name']} (Sisa Fisik: ${w['stock_central']} ${w['unit']})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSku = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah Stok Masuk (Porsi)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.inventory_2_outlined, size: 20))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(controller: batchCtrl, decoration: const InputDecoration(labelText: 'Batch / Roasting ID', border: OutlineInputBorder(), prefixIcon: Icon(Icons.qr_code, size: 20))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                    child: const Text('⚠️ Setiap perubahan stok akan otomatis mencatat entri pada log Stock Movement guna menjaga integritas dan audit trail.', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
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
                            for (var item in _warehouseCatalog) {
                              if (item['sku'] == selectedSku) {
                                item['stock_central'] = (item['stock_central'] as int) + addQty;
                                item['status'] = 'AMAN';
                                item['status_color'] = const Color(0xFF10B981);
                                _stockMovements.insert(0, {
                                  'id': 'MOV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                  'time': 'Baru Saja',
                                  'sku': item['sku'],
                                  'product_name': item['name'],
                                  'from_scope': 'Supplier / Roastery',
                                  'to_scope': 'Gudang Pusat (Central)',
                                  'qty': addQty,
                                  'type': 'INBOUND_RESTOCK',
                                  'actor': 'Owner Admin',
                                  'reference': batchCtrl.text,
                                  'notes': 'Restock pasokan baru berhasil dicatat',
                                });
                              }
                            }
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: const Color(0xFF10B981), content: Text('Berhasil menambahkan $addQty porsi ke gudang pusat!')));
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

  // MODAL 3: Distribusi Stok Bawaan Pagi ke Gerobak Petugas
  void _showDistributeStockModal() {
    String selectedSellerId = _staffList.first['id'];
    String selectedSku = _warehouseCatalog.first['sku'];
    final qtyCtrl = TextEditingController(text: '30');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(26),
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
                          Text('Distribusi Stok Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: Color(0xFF0F172A))),
                          Text('Kirim alokasi stok dari gudang pusat ke gerobak seller', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  const Text('Pilih Petugas Gerobak Penerima:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSellerId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _staffList.map((s) {
                      return DropdownMenuItem(value: s['id'].toString(), child: Text('${s['name']} • ${s['cart_id']} (Stok saat ini: ${s['stock_held']} cup)'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSellerId = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Pilih Produk dari Gudang Pusat:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF334155))),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: selectedSku,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _warehouseCatalog.map((w) {
                      return DropdownMenuItem(value: w['sku'].toString(), child: Text('${w['name']} (Sedia Gudang: ${w['stock_central']} ${w['unit']})'));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedSku = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Jumlah Porsi / Cup yang Dibawa', hintText: '30', border: OutlineInputBorder(), prefixIcon: Icon(Icons.coffee, size: 20)),
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
                            for (var w in _warehouseCatalog) {
                              if (w['sku'] == selectedSku) {
                                if ((w['stock_central'] as int) < qty) {
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Colors.red, content: Text('Stok gudang pusat tidak mencukupi!')));
                                  return;
                                }
                                w['stock_central'] = (w['stock_central'] as int) - qty;
                                w['stock_allocated'] = (w['stock_allocated'] as int) + qty;
                              }
                            }
                            // Tambah stok ke petugas
                            for (var s in _staffList) {
                              if (s['id'] == selectedSellerId) {
                                s['stock_held'] = (s['stock_held'] as int) + qty;
                                _stockMovements.insert(0, {
                                  'id': 'MOV-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                                  'time': 'Baru Saja',
                                  'sku': selectedSku,
                                  'product_name': 'Alokasi Pagi',
                                  'from_scope': 'Gudang Pusat (Central)',
                                  'to_scope': '${s['name']} (${s['cart_id']})',
                                  'qty': qty,
                                  'type': 'DISTRIBUSI_PAGI',
                                  'actor': 'Owner Admin',
                                  'reference': 'DIST-MANUAL-ALLOC',
                                  'notes': 'Alokasi stok pagi dikonfirmasi',
                                });
                              }
                            }
                          });
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Distribusi stok berhasil dicatat & dialokasikan ke gerobak petugas!')));
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

  // MODAL 4: Cairkan Komisi Petugas
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
            Text('Unit Gerobak: ${staff['cart_id']}', style: const TextStyle(color: Color(0xFF64748B))),
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
            const Text('Metode Pencairan: Dipotong langsung dari uang kasir fisik harian atau transfer rekening.', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
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
      color: const Color(0xFFF8FAFC),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Sidebar Navigasi 13 Menu
          _buildSidebar13Menus(),

          // 2. Workspace Utama
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

  // ===========================================================================
  // SIDEBAR NAVIGATION (13 MENUS TERORGANISIR DALAM 4 KATEGORI)
  // ===========================================================================
  Widget _buildSidebar13Menus() {
    final activeStaffCount = _staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length;

    return Container(
      width: 285,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A), // Slate 900
        border: Border(right: BorderSide(color: Color(0xFF1E293B), width: 1.2)),
      ),
      child: Column(
        children: [
          // Header Brand
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF78350F), Color(0xFFD97706)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.coffee_maker, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('KopiCerdas AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.3)),
                      Text('OWNER EXECUTIVE HQ', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),

          // List Navigasi 13 Menu
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                // KATEGORI 1: OPERASIONAL & TIM
                _sidebarCategoryHeader('OPERASIONAL & TIM'),
                _sidebarNavItem(0, Icons.dashboard_outlined, '1. Dashboard'),
                _sidebarNavItem(1, Icons.badge_outlined, '2. Tim Lapangan', badge: '$activeStaffCount Aktif', badgeColor: const Color(0xFF10B981)),
                _sidebarNavItem(2, Icons.access_time_outlined, '3. Absensi', badge: 'Live Shift'),
                _sidebarNavItem(3, Icons.map_outlined, '4. Peta Monitoring', badge: 'Google Maps', badgeColor: const Color(0xFF0284C7)),

                const SizedBox(height: 10),
                // KATEGORI 2: GUDANG & DISTRIBUSI
                _sidebarCategoryHeader('GUDANG & LOGISTIK'),
                _sidebarNavItem(4, Icons.place_outlined, '5. Manajemen Lokasi'),
                _sidebarNavItem(5, Icons.warehouse_outlined, '6. Gudang & Inventori', badge: '6 SKU'),
                _sidebarNavItem(6, Icons.local_shipping_outlined, '7. Distribusi Stok', badge: 'Bawaan Pagi', badgeColor: const Color(0xFFF59E0B)),

                const SizedBox(height: 10),
                // KATEGORI 3: PENJUALAN & PESANAN
                _sidebarCategoryHeader('PENJUALAN & PESANAN'),
                _sidebarNavItem(7, Icons.point_of_sale_outlined, '8. Penjualan Real-time'),
                _sidebarNavItem(8, Icons.receipt_long_outlined, '9. Pesanan Pelanggan', badge: '${_ordersList.length} Order', badgeColor: const Color(0xFF38BDF8)),
                _sidebarNavItem(9, Icons.military_tech_outlined, '10. Sistem Komisi', badge: 'Rp/Cup'),

                const SizedBox(height: 10),
                // KATEGORI 4: INTELIJEN & PENGATURAN
                _sidebarCategoryHeader('INTELIJEN & PENGATURAN'),
                _sidebarNavItem(10, Icons.radar_outlined, '11. Traffic Radar', badge: 'Routes AI', badgeColor: const Color(0xFF8B5CF6)),
                _sidebarNavItem(11, Icons.analytics_outlined, '12. Analitik & Laporan'),
                _sidebarNavItem(12, Icons.settings_outlined, '13. Pengaturan'),
              ],
            ),
          ),

          // Quick Fleet Status in Sidebar Footer
          Padding(
            padding: const EdgeInsets.all(14),
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
                      const Text('Jaringan Gerobak Live', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('$activeStaffCount dari ${_staffList.length} Seller Aktif Melayani', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                          onPressed: _showDistributeStockModal,
                          child: const Text('Bagi Stok', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Color(0xFF475569)), padding: const EdgeInsets.symmetric(vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                          onPressed: _showAddStaffModal,
                          child: const Text('+ Akun', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _sidebarCategoryHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 6),
      child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _sidebarNavItem(int index, IconData icon, String title, {String? badge, Color? badgeColor}) {
    final isSelected = _selectedNavIndex == index;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: InkWell(
        onTap: () => setState(() => _selectedNavIndex = index),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E293B) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected ? Border.all(color: const Color(0xFF38BDF8).withOpacity(0.35)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? const Color(0xFF38BDF8) : const Color(0xFF94A3B8)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (badgeColor ?? const Color(0xFF38BDF8)).withOpacity(0.18), borderRadius: BorderRadius.circular(5)),
                  child: Text(badge, style: TextStyle(color: badgeColor ?? const Color(0xFF38BDF8), fontSize: 9.5, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1.2))),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_getMenuTitle(), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
              Text(_getMenuSubtitle(), style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
            ],
          ),
          const Spacer(),

          // Date Filter Toolbar (Asia/Jakarta context)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                _dateFilterButton('Hari Ini', 'HARI_INI'),
                _dateFilterButton('Kemarin', 'KEMARIN'),
                _dateFilterButton('7 Hari', '7_HARI'),
                _dateFilterButton('30 Hari', '30_HARI'),
              ],
            ),
          ),
          const SizedBox(width: 14),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF0F172A), content: Text('Sinkronisasi data backend & telemetri GPS Asia/Jakarta berhasil diperbarui.')));
            },
            icon: const Icon(Icons.sync, size: 15),
            label: const Text('Sync Realtime', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
          const SizedBox(width: 14),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1))),
            child: const Row(
              children: [
                CircleAvatar(radius: 12, backgroundColor: Color(0xFF78350F), child: Text('OW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10))),
                SizedBox(width: 8),
                Text('Owner Pusat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF0F172A))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _dateFilterButton(String label, String value) {
    final isSelected = _activeDateFilter == value;
    return InkWell(
      onTap: () => setState(() => _activeDateFilter = value),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : null),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B))),
      ),
    );
  }

  String _getMenuTitle() {
    switch (_selectedNavIndex) {
      case 0: return '1. Executive Dashboard';
      case 1: return '2. Manajemen Tim Lapangan';
      case 2: return '3. Absensi & Shift Kerja';
      case 3: return '4. Peta Monitoring (Google Maps Platform)';
      case 4: return '5. Manajemen Lokasi Jualan';
      case 5: return '6. Gudang & Manajemen Stok';
      case 6: return '7. Distribusi Stok Bawaan Pagi';
      case 7: return '8. Monitoring Penjualan Real-time';
      case 8: return '9. Monitoring Pesanan Pelanggan (QRIS PJP)';
      case 9: return '10. Sistem Komisi Penjualan Kopi';
      case 10: return '11. Traffic & Opportunity Radar';
      case 11: return '12. Analitik & Laporan';
      case 12: return '13. Pengaturan Sistem';
      default: return 'KopiCerdas AI Owner Suite';
    }
  }

  String _getMenuSubtitle() {
    switch (_selectedNavIndex) {
      case 0: return 'Ringkasan operasional harian, omzet, margin laba, dan telemetri jaringan gerobak';
      case 1: return 'Kelola akun seluruh petugas, status aktif vs status jualan, dan hak akses';
      case 2: return 'Pantau absensi masuk/pulang, keterlambatan, koordinat GPS clock-in, dan audit log';
      case 3: return 'Pantau koordinat GPS realtime armada gerobak, rute perjalanan, dan status lokasi';
      case 4: return 'Katalog lapak aktif dan kandidat titik potensial dengan riwayat penjualan';
      case 5: return 'Kontrol pasokan stok gudang pusat, SKU, harga modal, harga jual, dan audit movement';
      case 6: return 'Alokasi stok bawaan pagi per petugas gerobak, pengurangan atomik, dan rekonsiliasi sisa';
      case 7: return 'Pantau transaksi penjualan walk-in & online, kas tunai kasir vs pembayaran QRIS';
      case 8: return 'Validasi transaksi pre-order pelanggan & verifikasi webhook resmi PJP/Acquirer';
      case 9: return 'Atur rate komisi per cup, rekap komisi per transaksi, dan pencairan insentif';
      case 10: return 'Analisis traffic jalan raya (Routes API) dan opportunity scoring titik lapak';
      case 11: return 'Laporan laba kotor, HPP, komisi, dan ekspor CSV/Excel pembukuan';
      case 12: return 'Pengaturan profil bisnis, shift kerja operasional, dan keamanan Google Maps API';
      default: return 'Portal Kendali Operasional Jaringan Kopi Gerobakan';
    }
  }

  // ===========================================================================
  // SWITCH VIEW FOR ALL 13 MENUS
  // ===========================================================================
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
  // MENU 0: EXECUTIVE DASHBOARD
  // ===========================================================================
  Widget _buildDashboardView() {
    final num totalCash = _staffList.fold(0, (acc, s) => acc + (s['cash_collected'] as num));
    final num totalQris = _staffList.fold(0, (acc, s) => acc + (s['qris_collected'] as num));
    final num totalOmzet = totalCash + totalQris;
    final num totalCups = _staffList.fold(0, (acc, s) => acc + (s['cups_sold_today'] as num));
    final num totalCommission = _staffList.fold(0, (acc, s) => acc + (s['total_commission'] as num));
    final num grossMargin = (totalOmzet * 0.58).round();
    final activeStaffCount = _staffList.where((s) => s['operational_status'] == 'ACTIVE_SELLING').length;
    final notStartedCount = _staffList.where((s) => s['operational_status'] == 'NOT_STARTED').length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // KPI Stat Cards Row
        Row(
          children: [
            Expanded(child: _kpiCard('Total Penjualan Hari Ini', _formatRupiah(totalOmzet), '+24.5% vs Kemarin', Icons.trending_up, const Color(0xFF10B981))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Estimasi Laba Bersih', _formatRupiah(grossMargin), 'Margin Sehat 58.0%', Icons.account_balance_wallet_outlined, const Color(0xFF0284C7))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Kopi Terjual', '$totalCups Cup', '$activeStaffCount Petugas Aktif Jualan', Icons.coffee, const Color(0xFFD97706))),
            const SizedBox(width: 16),
            Expanded(child: _kpiCard('Total Komisi Berjalan', _formatRupiah(totalCommission), 'Hak Insentif Tim', Icons.military_tech_outlined, const Color(0xFF8B5CF6))),
          ],
        ),
        const SizedBox(height: 20),

        // Urgent Realtime Alert Banner
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: const Color(0xFFFFFBEB), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFFDE68A))),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24)),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('PERINGATAN STOK MENIPIS: Hendra Wijaya (GRB-04 • Stasiun Juanda) Sisa 15 Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Color(0xFF92400E))),
                    SizedBox(height: 3),
                    Text('Laju pembelian tinggi di stasiun kereta. Diprediksi habis pukul 14.15 WIB. Segera alokasikan stok tambahan dari gudang pusat.', style: TextStyle(color: Color(0xFFB45309), fontSize: 11.5)),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: _showDistributeStockModal,
                icon: const Icon(Icons.send, size: 14),
                label: const Text('Kirim Stok Tambahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Performance Chart & Cash Split
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ranking Penjualan Petugas
            Expanded(
              flex: 5,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Ranking Penjualan Petugas Hari Ini', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
                        Text('Kapasitas Box: 100-120 cup', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    for (final s in _staffList) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${s['name']} (${s['cart_id']})', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF334155))),
                                Text('${s['cups_sold_today']} Cup • Sisa: ${s['stock_held']} Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: (s['stock_held'] as int) < 20 ? Colors.red : Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: ((s['cups_sold_today'] as int) / (s['stock_capacity'] as int)).clamp(0.0, 1.0),
                                minHeight: 7,
                                backgroundColor: const Color(0xFFF1F5F9),
                                valueColor: AlwaysStoppedAnimation<Color>((s['stock_held'] as int) < 20 ? const Color(0xFFEF4444) : const Color(0xFF10B981)),
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
            const SizedBox(width: 18),

            // Cash Breakdown & Status Ringkas
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Komposisi Kas Masuk Lapangan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.qr_code_2, color: Color(0xFF0284C7), size: 18),
                              SizedBox(width: 6),
                              Text('QRIS PJP Acquirer (Non-Tunai)', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_formatRupiah(totalQris), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('${((totalQris / (totalOmzet == 0 ? 1 : totalOmzet)) * 100).toStringAsFixed(1)}% dari total • Langsung kliring rekening', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.account_balance_wallet, color: Color(0xFF10B981), size: 18),
                              SizedBox(width: 6),
                              Text('Uang Tunai Kasir (CASH Fisik)', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11.5)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(_formatRupiah(totalCash), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          const Text('Wajib disetor oleh petugas saat rekonsiliasi tutup shift', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Ringkasan Status Tim Lapangan Table
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Armada Tim Yang Sedang Beroperasi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF0F172A))),
                      Text('$activeStaffCount Aktif Berjualan • $notStartedCount Belum Mulai Shift', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5)),
                    ],
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () => setState(() => _selectedNavIndex = 1),
                    icon: const Icon(Icons.manage_accounts, size: 15),
                    label: const Text('Kelola Tim Lapangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(2),
                  1: FlexColumnWidth(2.6),
                  2: FlexColumnWidth(1.6),
                  3: FlexColumnWidth(1.4),
                  4: FlexColumnWidth(1.6),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.4),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('Petugas Seller'),
                      _th('Titik Gerobak & Lapak'),
                      _th('Jam Mulai Shift'),
                      _th('Terjual'),
                      _th('Sisa Stok'),
                      _th('Komisi Akumulasi'),
                      _th('Status Operasional'),
                    ],
                  ),
                  for (final s in _staffList)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td('${s['name']}\n@${s['username']}', bold: true),
                        _td('${s['cart_id']}\n${s['assigned_location']}'),
                        _td(s['start_shift_time']),
                        _td('${s['cups_sold_today']} Cup', bold: true),
                        _td('${s['stock_held']} / ${s['stock_capacity']} Cup', bold: true, color: (s['stock_held'] as int) < 20 ? Colors.red : Colors.green),
                        _td(_formatRupiah(s['total_commission'] as num), bold: true, color: const Color(0xFF8B5CF6)),
                        _statusBadge(s['operational_status'], s['operational_status'] == 'ACTIVE_SELLING' ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
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
  // MENU 1: MANAJEMEN TIM LAPANGAN
  // ===========================================================================
  Widget _buildStaffManagementView() {
    final filtered = _staffList.where((s) {
      if (_staffSearchQuery.isEmpty) return true;
      final q = _staffSearchQuery.toLowerCase();
      return s['name'].toString().toLowerCase().contains(q) || s['username'].toString().toLowerCase().contains(q) || s['cart_id'].toString().toLowerCase().contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              icon: const Icon(Icons.person_add_alt_1, size: 18),
              label: const Text('Tambah Petugas Lapangan Baru', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final s in filtered) ...[
              Builder(builder: (context) {
                final bool isSelling = s['operational_status'] == 'ACTIVE_SELLING';

                return Container(
                  width: 380,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelling ? const Color(0xFFE2E8F0) : const Color(0xFFCBD5E1), width: 1.2),
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
                                radius: 22,
                                backgroundColor: isSelling ? const Color(0xFF0F172A) : const Color(0xFF94A3B8),
                                child: Text(s['name'].toString().substring(0, 1), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(s['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                                  Text('@${s['username']} • ${s['role_title']}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          _statusBadge(s['operational_status'], isSelling ? const Color(0xFF10B981) : const Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 10),

                      _infoRow(Icons.phone_outlined, 'WhatsApp', s['phone']),
                      _infoRow(Icons.storefront_outlined, 'Unit Gerobak', s['cart_id']),
                      _infoRow(Icons.location_on_outlined, 'Lapak', s['assigned_location']),
                      _infoRow(Icons.gps_fixed, 'GPS Telemetri', s['last_gps_update']),
                      _infoRow(Icons.security, 'Status Akun', s['account_status']),

                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFE2E8F0))),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Sisa Stok Bawaan:', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                Text('${s['stock_held']} / ${s['stock_capacity']} Cup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: (s['stock_held'] as int) < 20 ? Colors.red : Colors.green)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Terjual Hari Ini:', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                Text('${s['cups_sold_today']} Cup', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF10B981))),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Total Hak Komisi:', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                Text(_formatRupiah(s['total_commission'] as num), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF8B5CF6))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: isSelling ? Colors.red.shade300 : Colors.green.shade400),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                              onPressed: () {
                                setState(() {
                                  s['operational_status'] = isSelling ? 'OFFLINE' : 'ACTIVE_SELLING';
                                  if (s['operational_status'] == 'ACTIVE_SELLING') {
                                    s['start_shift_time'] = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')} WIB';
                                  }
                                });
                              },
                              child: Text(isSelling ? 'Set Tutup Toko' : 'Set Buka Jualan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelling ? Colors.red : Colors.green)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(vertical: 8)),
                              onPressed: _showDistributeStockModal,
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
  // MENU 2: ABSENSI & SHIFT KERJA
  // ===========================================================================
  Widget _buildAttendanceView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekap Absensi Masuk/Pulang & Jam Kerja Petugas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Pencatatan waktu server resmi, toleransi keterlambatan, koordinat GPS clock-in, dan audit log', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.access_time_filled, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 6),
                  Text('Server Clock Sinkron: Asia/Jakarta', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.4),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.8),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(2.2),
              7: FlexColumnWidth(1.8),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Absensi'),
                  _th('Nama Petugas'),
                  _th('Clock In'),
                  _th('Clock Out'),
                  _th('Durasi Kerja'),
                  _th('Status Masuk'),
                  _th('Koordinat GPS Clock-In'),
                  _th('Catatan Audit'),
                ],
              ),
              for (final att in _attendanceRecords)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(att['id']),
                    _td(att['name'], bold: true),
                    _td(att['clock_in']),
                    _td(att['clock_out']),
                    _td(att['duration']),
                    _statusBadge(att['status'], att['status'].toString().contains('ON_TIME') ? const Color(0xFF10B981) : (att['status'].toString().contains('TERLAMBAT') ? const Color(0xFFF59E0B) : const Color(0xFF94A3B8))),
                    _td(att['gps_lat_long']),
                    _td(att['correction_note'], italic: true),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 3: PETA MONITORING (GOOGLE MAPS PLATFORM ASLI)
  // ===========================================================================
  Widget _buildGoogleMapsMonitoringView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Peta Monitoring Armada Google Maps Platform', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Google Maps JavaScript API, Advanced Markers, dan Routes API dengan koordinat telemetri aktif.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: const Color(0xFF0284C7).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.gps_fixed, color: Color(0xFF0284C7), size: 16),
                  SizedBox(width: 6),
                  Text('Advanced Markers Active', style: TextStyle(color: Color(0xFF0284C7), fontWeight: FontWeight.bold, fontSize: 11.5)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Google Maps Interactive Canvas Container
        Container(
          width: double.infinity,
          height: 440,
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF334155), width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _VectorTransitMapPainter()),
              ),

              // Live GPS Markers for Active Sellers
              for (final staff in _staffList) ...[
                if (staff['operational_status'] == 'ACTIVE_SELLING') ...[
                  Positioned(
                    left: staff['map_x'] as double,
                    top: staff['map_y'] as double,
                    child: _googleMapMarker(
                      title: staff['name'],
                      subtitle: '${staff['cart_id']} • Sisa: ${staff['stock_held']} Cup',
                      statusColor: (staff['stock_held'] as int) < 20 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                      isAlert: (staff['stock_held'] as int) < 20,
                    ),
                  ),
                ],
              ],

              // Central Warehouse Marker
              Positioned(
                left: 60,
                top: 200,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF78350F), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFD97706))),
                  child: const Row(
                    children: [
                      Icon(Icons.warehouse, color: Colors.white, size: 15),
                      SizedBox(width: 6),
                      Text('Gudang Pusat (Central Hub)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                    ],
                  ),
                ),
              ),

              // Overlay Map Controls
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
                      Text('Petugas Aktif Jualan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFFEF4444), size: 10),
                      SizedBox(width: 6),
                      Text('Stok Kritis (<20 cup)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      SizedBox(width: 14),
                      Icon(Icons.circle, color: Color(0xFF78350F), size: 10),
                      SizedBox(width: 6),
                      Text('Gudang Pusat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _googleMapMarker({required String title, required String subtitle, required Color statusColor, bool isAlert = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isAlert ? const Color(0xFFEF4444) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.coffee, color: isAlert ? Colors.white : statusColor, size: 15),
          const SizedBox(width: 6),
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

  // ===========================================================================
  // MENU 4: MANAJEMEN LOKASI JUALAN
  // ===========================================================================
  Widget _buildLocationManagementView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Katalog Lapak Strategis & Penugasan Petugas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        const Text('Owner mengelola titik lokasi jualan yang menjadi kandidat maupun lapak yang sedang terisi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2.6),
              2: FlexColumnWidth(2.2),
              3: FlexColumnWidth(2),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.2),
              6: FlexColumnWidth(1.3),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Lapak'),
                  _th('Area & Landmark Lokasi'),
                  _th('Petugas Yang Menempati'),
                  _th('Jam Sibuk Operasional'),
                  _th('Trafik Pejalan'),
                  _th('Skor Potensi'),
                  _th('Status'),
                ],
              ),
              for (final loc in _locationMaster)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(loc['id']),
                    _td('${loc['name']}\n${loc['address']}', bold: true),
                    _td(loc['assigned_seller']),
                    _td(loc['peak_hours']),
                    _td(loc['foot_traffic_density']),
                    _td('${loc['potential_score']} / 100', bold: true),
                    _statusBadge(loc['is_occupied'] ? 'TERISI' : 'TERSEDIA', loc['is_occupied'] ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 5: GUDANG & MANAJEMEN STOK
  // ===========================================================================
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
                Text('Persediaan Gudang Pusat (Owner Single Source of Truth)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Owner mengontrol stok fisik pusat, stok dialokasikan, dan riwayat mutasi resmi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Row(
              children: [
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: _showAddWarehouseStockModal,
                  icon: const Icon(Icons.add_box_outlined, size: 18),
                  label: const Text('Input Pasokan Masuk', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: _showDistributeStockModal,
                  icon: const Icon(Icons.local_shipping_outlined, size: 18),
                  label: const Text('Bagi Stok ke Gerobak', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 18),

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
              6: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('SKU'),
                  _th('Nama Menu / Bahan'),
                  _th('Kategori'),
                  _th('Stok Pusat'),
                  _th('Dialokasikan'),
                  _th('Dipegang Petugas'),
                  _th('Status'),
                ],
              ),
              for (final w in _warehouseCatalog)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(w['sku']),
                    _td('${w['name']}\nHarga: ${_formatRupiah(w['sell_price'] as num)}', bold: true),
                    _td(w['category']),
                    _td('${w['stock_central']} ${w['unit']}', bold: true, color: const Color(0xFF0284C7)),
                    _td('${w['stock_allocated']} ${w['unit']}'),
                    _td('${w['stock_held_by_staff']} ${w['unit']}'),
                    _statusBadge(w['status'], w['status_color']),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stock Movement Audit Log
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.history, color: Color(0xFF0F172A), size: 20),
                  SizedBox(width: 8),
                  Text('Log Audit Mutasi Stok (Stock Movements)', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
                ],
              ),
              const SizedBox(height: 12),
              for (final log in _stockMovements) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: const Color(0xFF0F172A).withOpacity(0.08), borderRadius: BorderRadius.circular(5)), child: Text(log['type'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: Color(0xFF0F172A)))),
                      const SizedBox(width: 10),
                      Expanded(child: Text('${log['qty']} porsi ${log['product_name']} • Dari: ${log['from_scope']} ➔ Ke: ${log['to_scope']}', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155)))),
                      Text(log['actor'], style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      const SizedBox(width: 12),
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
  // MENU 6: DISTRIBUSI STOK BAWAAN PAGI
  // ===========================================================================
  Widget _buildStockDistributionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Penetapan Stok Bawaan Pagi & Rekonsiliasi Sore', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Owner menetapkan kuota stok bawaan pagi yang menjadi dasar pengurangan atomik setiap penjualan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: _showDistributeStockModal,
              icon: const Icon(Icons.send_and_archive, size: 18),
              label: const Text('Distribusikan Bawaan Pagi', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.2),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(1.5),
              6: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Petugas'),
                  _th('Nama Petugas Lapangan'),
                  _th('Gerobak & Wilayah'),
                  _th('Stok Awal Pagi'),
                  _th('Terjual Siang'),
                  _th('Sisa Fisik Box'),
                  _th('Status Alokasi'),
                ],
              ),
              for (final s in _staffList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(s['id']),
                    _td(s['name'], bold: true),
                    _td('${s['cart_id']}\n${s['assigned_location']}'),
                    _td('${(s['stock_held'] as int) + (s['cups_sold_today'] as int)} Cup', bold: true),
                    _td('${s['cups_sold_today']} Cup', color: const Color(0xFF10B981), bold: true),
                    _td('${s['stock_held']} Cup', bold: true, color: (s['stock_held'] as int) < 20 ? Colors.red : Colors.blue),
                    _statusBadge(s['operational_status'] == 'ACTIVE_SELLING' ? 'TERKONFIRMASI' : 'PENDING KONFIRMASI', s['operational_status'] == 'ACTIVE_SELLING' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 7: MONITORING PENJUALAN REAL-TIME
  // ===========================================================================
  Widget _buildSalesMonitoringView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Feed Transaksi Penjualan Walk-In & Online Real-time', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        const Text('Setiap transaksi langsung mengurangi stok gerobak bersangkutan secara atomik dan menghitung komisi.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(2.5),
              3: FlexColumnWidth(1.5),
              4: FlexColumnWidth(1.5),
              5: FlexColumnWidth(2),
              6: FlexColumnWidth(1.4),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('ID Transaksi'),
                  _th('Petugas & Gerobak'),
                  _th('Item Yang Dibeli'),
                  _th('Total Nominal'),
                  _th('Metode Bayar'),
                  _th('Penyelesaian / Acquirer'),
                  _th('Waktu Server'),
                ],
              ),
              for (final tx in _transactionsList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(tx['id']),
                    _td(tx['seller_name'], bold: true),
                    _td(tx['items_summary']),
                    _td(_formatRupiah(tx['total'] as num), bold: true),
                    _statusBadge(tx['payment_method'], tx['payment_method'] == 'CASH' ? const Color(0xFF10B981) : const Color(0xFF0284C7)),
                    _td(tx['pjp_acquirer']),
                    _td(tx['time']),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 8: MONITORING PESANAN PELANGGAN (QRIS PJP VERIFIED)
  // ===========================================================================
  Widget _buildOrdersMonitoringView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Monitoring Pesanan Online Pre-Order & Verifikasi QRIS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Status pembayaran hanya diverifikasi melalui konfirmasi resmi PJP Acquirer backend.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                  SizedBox(width: 6),
                  Text('Webhook Acquirer Terhubung', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4),
              1: FlexColumnWidth(1.8),
              2: FlexColumnWidth(2),
              3: FlexColumnWidth(2.6),
              4: FlexColumnWidth(1.4),
              5: FlexColumnWidth(1.6),
              6: FlexColumnWidth(1.5),
              7: FlexColumnWidth(2.2),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('No. Order'),
                  _th('Pelanggan'),
                  _th('Gerobak Tujuan'),
                  _th('Item Pesanan'),
                  _th('Total'),
                  _th('Status Order'),
                  _th('Status Bayar'),
                  _th('Referensi PJP Acquirer'),
                ],
              ),
              for (final o in _ordersList)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(o['order_no']),
                    _td('${o['customer']}\n${o['phone']}', bold: true),
                    _td(o['seller']),
                    _td(o['items']),
                    _td(_formatRupiah(o['total'] as num), bold: true),
                    _statusBadge(o['order_status'], const Color(0xFF0284C7)),
                    _statusBadge(o['payment_status'], o['payment_status'] == 'PAID' ? const Color(0xFF10B981) : const Color(0xFFF59E0B)),
                    _td(o['pjp_ref'], italic: true),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 9: SISTEM KOMISI PENJUALAN KOPI
  // ===========================================================================
  Widget _buildCommissionSystemView() {
    final num totalCommission = _staffList.fold(0, (acc, s) => acc + (s['total_commission'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sistem Komisi Penjualan Kopi per Cup', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Perhitungan insentif otomatis berdasarkan setiap transaksi yang berhasil dan tidak dibatalkan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: Text('Total Insentif Hari Ini: ${_formatRupiah(totalCommission)}', style: const TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        // Aturan Komisi Per Produk
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Konfigurasi Aturan Komisi per Menu Kopi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2.5),
                  2: FlexColumnWidth(1.5),
                  3: FlexColumnWidth(1.8),
                  4: FlexColumnWidth(1.5),
                  5: FlexColumnWidth(1.5),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('ID Aturan'),
                      _th('Nama Varian Menu'),
                      _th('Tipe Komisi'),
                      _th('Besaran Insentif'),
                      _th('Berlaku Sejak'),
                      _th('Status Aturan'),
                    ],
                  ),
                  for (final r in _commissionRules)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(r['rule_id']),
                        _td(r['product_name'], bold: true),
                        _td(r['type']),
                        _td(_formatRupiah(r['rate_nominal'] as num), bold: true, color: const Color(0xFF10B981)),
                        _td(r['active_since']),
                        _statusBadge(r['status'], const Color(0xFF10B981)),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Rekap Hak Komisi Petugas
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rekap Hak Komisi & Pencairan Dana Petugas', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
              const SizedBox(height: 12),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2.2),
                  2: FlexColumnWidth(1.4),
                  3: FlexColumnWidth(1.8),
                  4: FlexColumnWidth(2.2),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.4),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('ID Petugas'),
                      _th('Nama Petugas Lapangan'),
                      _th('Cup Terjual'),
                      _th('Total Komisi'),
                      _th('Omzet Dihasilkan'),
                      _th('Status Pencairan'),
                      _th('Aksi Owner'),
                    ],
                  ),
                  for (final s in _staffList)
                    TableRow(
                      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                      children: [
                        _td(s['id']),
                        _td('${s['name']}\n${s['cart_id']}', bold: true),
                        _td('${s['cups_sold_today']} Cup', bold: true),
                        _td(_formatRupiah(s['total_commission'] as num), bold: true, color: const Color(0xFF10B981)),
                        _td('Cash: ${_formatRupiah(s['cash_collected'] as num)}\nQRIS: ${_formatRupiah(s['qris_collected'] as num)}'),
                        _statusBadge(
                          s['commission_paid'] == true
                              ? 'SUDAH CAIR'
                              : ((s['cups_sold_today'] as int) > 0 ? 'SIAP DICAIRKAN' : 'BELUM ADA TRX'),
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
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 10: TRAFFIC & OPPORTUNITY RADAR
  // ===========================================================================
  Widget _buildTrafficRadarView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Traffic & Opportunity Location Intelligence', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Evaluasi kondisi jalan raya (Google Routes API) dan penilaian potensi lokasi jualan.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
              child: const Text('Routes API Live Traffic Integrated', style: TextStyle(color: Color(0xFF6D28D9), fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Table(
            columnWidths: const {
              0: FlexColumnWidth(1.8),
              1: FlexColumnWidth(2),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.2),
              4: FlexColumnWidth(2.8),
              5: FlexColumnWidth(1.5),
            },
            children: [
              TableRow(
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                children: [
                  _th('Lapak Rekomendasi'),
                  _th('Kondisi Lalu Lintas Jalan'),
                  _th('Aktivitas Pejalan'),
                  _th('Skor AI'),
                  _th('Saran Porsi Bawaan Pagi'),
                  _th('Aksi Pengarahan'),
                ],
              ),
              for (final loc in _locationMaster)
                TableRow(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
                  children: [
                    _td(loc['name'], bold: true),
                    _td(loc['road_traffic_level']),
                    _td(loc['foot_traffic_density']),
                    _td('${loc['potential_score']} / 100', bold: true, color: const Color(0xFF10B981)),
                    _td(loc['recommended_quota'], italic: true),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Notifikasi pengarahan lapak ${loc['name']} dikirimkan ke tim seller!')));
                        },
                        child: const Text('Tugaskan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
  // MENU 11: ANALITIK & LAPORAN BISNIS
  // ===========================================================================
  Widget _buildAnalyticsReportsView() {
    final num totalCash = _staffList.fold(0, (acc, s) => acc + (s['cash_collected'] as num));
    final num totalQris = _staffList.fold(0, (acc, s) => acc + (s['qris_collected'] as num));
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
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analitik Keuangan & Laporan Laba Bersih', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
                Text('Pemisahan komponen Omzet, Harga Pokok Penjualan (HPP), Komisi, dan Margin Laba Bersih.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mengunduh Laporan Pembukuan Excel / CSV resmi...')));
              },
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Ekspor Laporan (CSV)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(child: _kpiCard('Omzet Bruto', _formatRupiah(totalOmzet), 'Pendapatan Kotor', Icons.monetization_on, const Color(0xFF10B981))),
            const SizedBox(width: 14),
            Expanded(child: _kpiCard('Harga Pokok (HPP)', _formatRupiah(totalHpp), '38% Biaya Bahan Kopi', Icons.shopping_bag_outlined, const Color(0xFFF59E0B))),
            const SizedBox(width: 14),
            Expanded(child: _kpiCard('Komisi Tim Seller', _formatRupiah(totalCommission), 'Insentif Cup Terjual', Icons.military_tech_outlined, const Color(0xFF8B5CF6))),
            const SizedBox(width: 14),
            Expanded(child: _kpiCard('Laba Bersih Operasional', _formatRupiah(netProfit), 'Margin Bersih Riil', Icons.account_balance, const Color(0xFF0284C7))),
          ],
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Rincian Pembukuan Per Gerobak Jualan', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14.5, color: Color(0xFF0F172A))),
              const SizedBox(height: 14),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.2),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.4),
                  3: FlexColumnWidth(1.6),
                  4: FlexColumnWidth(1.6),
                  5: FlexColumnWidth(1.6),
                  6: FlexColumnWidth(1.6),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFCBD5E1), width: 1))),
                    children: [
                      _th('Unit'),
                      _th('Petugas Bertugas'),
                      _th('Cup Terjual'),
                      _th('Omzet Bruto'),
                      _th('Estimasi HPP'),
                      _th('Komisi Dibayar'),
                      _th('Kontribusi Laba'),
                    ],
                  ),
                  for (final s in _staffList)
                    _buildStaffAnalyticsRow(s),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // MENU 12: PENGATURAN SISTEM
  // ===========================================================================
  Widget _buildSettingsView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pengaturan Sistem Operasional & Konfigurasi Google Maps', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF0F172A))),
        const SizedBox(height: 6),
        const Text('Kelola parameter bisnis usaha kopi, kebijakan jam shift, dan pembatasan keamanan API key.', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('1. Profil Usaha & Operasional KopiCerdas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              const SizedBox(height: 10),
              const TextField(decoration: InputDecoration(labelText: 'Nama Usaha / Brand', border: OutlineInputBorder()), controller: null),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Jam Buka Shift Pagi', border: OutlineInputBorder()), controller: TextEditingController(text: '05:30 WIB'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(decoration: const InputDecoration(labelText: 'Batas Akhir Setor Sore', border: OutlineInputBorder()), controller: TextEditingController(text: '19:30 WIB'))),
                ],
              ),
              const SizedBox(height: 20),

              const Text('2. Keamanan Google Maps Platform', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🔒 Google Maps API Key Protection: ACTIVE', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10B981), fontSize: 12)),
                    SizedBox(height: 4),
                    Text('Kunci API dibatasi menggunakan HTTP Referrer restriction pada domain proyek dan backend proxy. Secret API tidak pernah diekspos pada bundle client.', style: TextStyle(fontSize: 11, color: Color(0xFF475569))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F172A), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(backgroundColor: Color(0xFF10B981), content: Text('Pengaturan sistem berhasil disimpan!')));
                    },
                    child: const Text('Simpan Pengaturan', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              )
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SUB WIDGET & FORMATTING HELPERS
  // ===========================================================================
  TableRow _buildStaffAnalyticsRow(Map<String, dynamic> s) {
    final omzet = (s['cash_collected'] as num) + (s['qris_collected'] as num);
    final hpp = (omzet * 0.38).round();
    final komisi = s['total_commission'] as num;
    final laba = omzet - hpp - komisi;
    return TableRow(
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9), width: 1))),
      children: [
        _td(s['cart_id'].toString().split(' ')[0]),
        _td(s['name'], bold: true),
        _td('${s['cups_sold_today']} Cup'),
        _td(_formatRupiah(omzet), bold: true),
        _td(_formatRupiah(hpp)),
        _td(_formatRupiah(komisi), color: const Color(0xFF8B5CF6)),
        _td(_formatRupiah(laba), bold: true, color: const Color(0xFF10B981)),
      ],
    );
  }

  Widget _kpiCard(String title, String value, String subtext, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12.5, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 19)),
            ],
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: Color(0xFF0F172A))),
          const SizedBox(height: 4),
          Text(subtext, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String val) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF64748B)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
          Expanded(child: Text(val, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _th(String text) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF475569))));
  }

  Widget _td(String text, {bool bold = false, bool italic = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontSize: 12.5,
          color: color ?? const Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
          child: Text(text, style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.w800)),
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

// Vector Transit Map Painter for Jabodetabek corridors
class _VectorTransitMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()..color = const Color(0xFF1E293B).withOpacity(0.5)..strokeWidth = 1.0;
    for (double x = 0; x < size.width; x += 60) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 60) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final avenuePaint = Paint()..color = const Color(0xFF334155).withOpacity(0.8)..strokeWidth = 8.0..strokeCap = StrokeCap.round;
    final secondaryRoad = Paint()..color = const Color(0xFF334155).withOpacity(0.5)..strokeWidth = 4.0;

    canvas.drawLine(const Offset(160, 0), const Offset(200, 440), avenuePaint);
    canvas.drawLine(const Offset(240, 60), const Offset(250, 440), secondaryRoad);
    canvas.drawLine(const Offset(60, 160), const Offset(700, 150), avenuePaint);
    canvas.drawLine(const Offset(180, 50), const Offset(580, 90), secondaryRoad);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
