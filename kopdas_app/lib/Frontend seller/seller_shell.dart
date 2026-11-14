import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';

class SellerShell extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const SellerShell({super.key, required this.state, required this.child});

  static const List<_SellerDestination> _destinations = [
    _SellerDestination('/seller', 'Dashboard', Icons.dashboard_outlined,
        Icons.dashboard),
    _SellerDestination('/seller/location', 'Lokasi', Icons.location_on_outlined,
        Icons.location_on),
    _SellerDestination('/seller/stock', 'Stok', Icons.inventory_2_outlined,
        Icons.inventory_2),
    _SellerDestination('/seller/pos', 'Kasir', Icons.point_of_sale_outlined,
        Icons.point_of_sale),
    _SellerDestination('/seller/orders', 'Order', Icons.receipt_long_outlined,
        Icons.receipt_long),
    _SellerDestination('/seller/history', 'Riwayat', Icons.history_outlined,
        Icons.history),
  ];

  int get _selectedIndex {
    final loc = state.matchedLocation;
    final idx = _destinations.indexWhere((d) => d.path == loc);
    return idx < 0 ? 0 : idx;
  }

  void _onSelect(BuildContext context, int index) {
    context.go(_destinations[index].path);
  }

  @override
  Widget build(BuildContext context) {
    final session = sessionController;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    final appBar = AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111827),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(height: 1, color: Color(0xFFE5E7EB)),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3932),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.coffee, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'KopiCerdas',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF111827)),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: const Color(0xFFA7F3D0)),
                    ),
                    child: const Text(
                      'SELLER PORTAL',
                      style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF065F46)),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Gerobak Lapangan Padang',
                    style: TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: const Color(0xFF1E3932),
                  child: Text(
                    (session.name?.isNotEmpty == true ? session.name![0] : 'S').toUpperCase(),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.name ?? 'Seller',
                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const Text(
                      'Petugas Lapangan',
                      style: TextStyle(fontSize: 9.5, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
        IconButton(
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout, size: 20, color: Color(0xFF6B7280)),
          onPressed: () => session.logout(),
        ),
        const SizedBox(width: 4),
      ],
    );

    if (isWide) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: appBar,
        body: Row(
          children: [
            Container(
              width: 220,
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
              ),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                children: [
                  const Padding(
                    padding: EdgeInsets.fromLTRB(10, 6, 10, 10),
                    child: Text(
                      'MENU OPERASIONAL SELLER',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                  for (int i = 0; i < _destinations.length; i++) ...[
                    _buildSidebarItem(
                      destination: _destinations[i],
                      isSelected: _selectedIndex == i,
                      onTap: () => _onSelect(context, i),
                    ),
                    const SizedBox(height: 4),
                  ],
                ],
              ),
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: appBar,
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (i) => _onSelect(context, i),
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFF1E3932).withOpacity(0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            for (final d in _destinations)
              NavigationDestination(
                icon: Icon(d.icon, color: const Color(0xFF6B7280), size: 22),
                selectedIcon: Icon(d.selectedIcon, color: const Color(0xFF1E3932), size: 22),
                label: d.label,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarItem({
    required _SellerDestination destination,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3932) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? destination.selectedIcon : destination.icon,
              size: 19,
              color: isSelected ? Colors.white : const Color(0xFF4B5563),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                destination.label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF374151),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellerDestination {
  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _SellerDestination(this.path, this.label, this.icon, this.selectedIcon);
}