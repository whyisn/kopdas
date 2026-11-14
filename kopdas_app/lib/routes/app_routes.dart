import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants.dart';
import '../Frontend Customer/customer_root_view.dart';
import '../Frontend owner/owner_dashboard_view.dart';
import '../Frontend seller/screens/seller_dashboard_screen.dart';
import '../Frontend seller/screens/seller_history_screen.dart';
import '../Frontend seller/screens/seller_location_screen.dart';
import '../Frontend seller/screens/seller_orders_screen.dart';
import '../Frontend seller/screens/seller_pos_screen.dart';
import '../Frontend seller/screens/seller_stock_screen.dart';
import '../Frontend seller/seller_shell.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AppConstants.devBypassAuth ? '/seller' : '/',
  refreshListenable: sessionController,
  redirect: (context, state) {
    final session = sessionController;
    final loc = state.matchedLocation;

    // Dev bypass: lewati auth guard, tanpa redirect ke Login, tanpa loop.
    if (AppConstants.devBypassAuth) {
      return (loc == '/' || loc == '/login') ? '/seller' : null;
    }

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
      builder: (_, _) => Scaffold(
        backgroundColor: const Color(0xFFF2F4F1),
        body: LayoutBuilder(
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
                  child: CustomerRootView(
                    initialUserName: sessionController.name,
                  ),
                ),
              );
            }
            return CustomerRootView(
              initialUserName: sessionController.name,
            );
          },
        ),
      ),
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