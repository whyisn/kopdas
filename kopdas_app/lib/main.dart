import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'models/product.dart';
import 'Frontend owner/owner_dashboard_view.dart';
import 'Frontend Customer/customer_root_view.dart';

void main() {
  runApp(const KopiCerdasApp());
}

class KopiCerdasApp extends StatelessWidget {
  const KopiCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppConstants.primaryColor,
          primary: AppConstants.primaryColor,
          secondary: AppConstants.accentColor,
          surface: AppConstants.surfaceColor,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
      ),
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentRoleIndex = 0; // 0: Owner, 1: Seller, 2: Customer
  final bool _isBackendConnected = true;
  final String _backendStatusText = 'Backend Siap (FastAPI :8000)';

  final List<ProductModel> _sampleProducts = [
    ProductModel(
      id: 'prd-01',
      categoryId: 'cat-01',
      name: 'Kopi Susu Gula Aren',
      price: 18000,
      costPrice: 8000,
      status: 'ACTIVE',
      categoryName: 'Kopi Susu',
    ),
    ProductModel(
      id: 'prd-02',
      categoryId: 'cat-02',
      name: 'Americano Dingin',
      price: 15000,
      costPrice: 5000,
      status: 'ACTIVE',
      categoryName: 'Black Coffee',
    ),
    ProductModel(
      id: 'prd-03',
      categoryId: 'cat-03',
      name: 'Matcha Latte',
      price: 20000,
      costPrice: 9000,
      status: 'ACTIVE',
      categoryName: 'Non-Coffee',
    ),
    ProductModel(
      id: 'prd-04',
      categoryId: 'cat-01',
      name: 'Kopi Cerdas Signature',
      price: 22000,
      costPrice: 10000,
      status: 'ACTIVE',
      categoryName: 'Kopi Susu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppConstants.primaryDark,
        elevation: 2,
        title: Row(
          children: [
            const Icon(Icons.coffee, color: AppConstants.accentColor),
            const SizedBox(width: 8),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppConstants.accentColor, width: 0.8),
              ),
              child: const Text(
                AppConstants.appTagline,
                style: TextStyle(fontSize: 11, color: AppConstants.accentColor),
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 10,
                  color: _isBackendConnected
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                ),
                const SizedBox(width: 6),
                Text(
                  _backendStatusText,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppConstants.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRoleTab(0, 'Owner Dashboard', Icons.admin_panel_settings),
                _buildRoleTab(1, 'Seller POS (Kasir)', Icons.point_of_sale),
                _buildRoleTab(2, 'Customer Discovery', Icons.explore),
              ],
            ),
          ),
        ),
      ),
      body: _buildActiveRoleBody(),
    );
  }

  Widget _buildRoleTab(int index, String label, IconData icon) {
    final isSelected = _currentRoleIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentRoleIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppConstants.accentColor : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.white60,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveRoleBody() {
    switch (_currentRoleIndex) {
      case 0:
        return const OwnerDashboardView();
      case 1:
        return _buildSellerView();
      case 2:
        return _buildCustomerView();
      default:
        return const Center(child: Text('Peran tidak dikenal'));
    }
  }

  Widget _buildSellerView() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kasir Penjualan Walk-in (Stasiun Sudirman)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.8,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: _sampleProducts.length,
                    itemBuilder: (context, idx) {
                      final p = _sampleProducts[idx];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 1,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Rp ${p.price}',
                                    style: const TextStyle(
                                      color: Colors.brown,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Stok: 45 Cup',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {},
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          AppConstants.primaryColor,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('+ Tambah'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            flex: 4,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Keranjang Kasir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('1x Kopi Susu Gula Aren'),
                      trailing: Text(
                        'Rp 18.000',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text('1x Americano Dingin'),
                      trailing: Text(
                        'Rp 15.000',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    const Divider(),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Pembayaran:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Rp 33.000',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {},
                            child: const Text('CASH (Tunai)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('QRIS Statis'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 520;
        if (isWide) {
          return Center(
            child: Container(
              width: 440,
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black12, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: const CustomerRootView(),
            ),
          );
        }
        return const CustomerRootView();
      },
    );
  }
}
