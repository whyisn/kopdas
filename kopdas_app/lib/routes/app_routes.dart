import 'package:go_router/go_router.dart';

import '../Frontend owner/owner_dashboard_view.dart';
import '../Frontend seller/screens/seller_dashboard_screen.dart';
import '../Frontend seller/screens/seller_history_screen.dart';
import '../Frontend seller/screens/seller_location_screen.dart';
import '../Frontend seller/screens/seller_orders_screen.dart';
import '../Frontend seller/screens/seller_pos_screen.dart';
import '../Frontend seller/screens/seller_stock_screen.dart';
import '../Frontend seller/seller_shell.dart';
import '../screens/login_screen.dart';
import '../screens/role_placeholder_screen.dart';
import '../services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  refreshListenable: sessionController,
  redirect: (context, state) {
    final session = sessionController;
    final loc = state.matchedLocation;

    if (!session.isLoggedIn) {
      return loc == '/login' ? null : '/login';
    }

    final home = session.homeRoute;
    if (loc == '/login' || loc == '/') return home;

    if (loc.startsWith('/seller') && !session.isSeller) return home;
    if (loc.startsWith('/owner') && session.role != 'OWNER') return home;
    if (loc.startsWith('/customer') && session.role != 'CUSTOMER') return home;

    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(
      path: '/owner',
      builder: (_, _) => const OwnerDashboardView(),
    ),
    GoRoute(
      path: '/customer',
      builder: (_, _) => const RolePlaceholderScreen(roleLabel: 'Customer'),
    ),
    ShellRoute(
      builder: (context, state, child) =>
          SellerShell(state: state, child: child),
      routes: [
        GoRoute(
          path: '/seller',
          builder: (_, _) => const SellerDashboardScreen(),
        ),
        GoRoute(
          path: '/seller/location',
          builder: (_, _) => const SellerLocationScreen(),
        ),
        GoRoute(
          path: '/seller/stock',
          builder: (_, _) => const SellerStockScreen(),
        ),
        GoRoute(
          path: '/seller/pos',
          builder: (_, _) => const SellerPosScreen(),
        ),
        GoRoute(
          path: '/seller/orders',
          builder: (_, _) => const SellerOrdersScreen(),
        ),
        GoRoute(
          path: '/seller/history',
          builder: (_, _) => const SellerHistoryScreen(),
        ),
      ],
    ),
  ],
);