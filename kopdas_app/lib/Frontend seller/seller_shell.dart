import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
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
      backgroundColor: AppConstants.primaryDark,
      foregroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.coffee, color: AppConstants.accentColor, size: 22),
          const SizedBox(width: 8),
          const Text(
            AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
        ],
      ),
      actions: [
        Center(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.name ?? 'Seller',
              style: const TextStyle(fontSize: 13, color: Colors.white),
            ),
          ),
        ),
        IconButton(
          tooltip: 'Keluar',
          icon: const Icon(Icons.logout),
          onPressed: () => session.logout(),
        ),
        const SizedBox(width: 4),
      ],
    );

    if (isWide) {
      return Scaffold(
        appBar: appBar,
        body: Row(
          children: [
            NavigationRail(
              extended: true,
              minExtendedWidth: 210,
              backgroundColor: AppConstants.surfaceColor,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => _onSelect(context, i),
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'MENU SELLER',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: Colors.brown.shade300,
                  ),
                ),
              ),
              destinations: [
                for (final d in _destinations)
                  NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon,
                        color: AppConstants.primaryColor),
                    label: Text(d.label),
                  ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (i) => _onSelect(context, i),
        backgroundColor: AppConstants.surfaceColor,
        indicatorColor: AppConstants.accentColor.withValues(alpha: 0.3),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          for (final d in _destinations)
            NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.selectedIcon, color: AppConstants.primaryColor),
              label: d.label,
            ),
        ],
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