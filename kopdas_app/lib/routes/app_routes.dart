// App routes placeholder using go_router (install go_router later)
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/owner_dashboard.dart';
import '../screens/seller_dashboard.dart';
import '../screens/customer_home.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/owner', builder: (context, state) => const OwnerDashboard()),
    GoRoute(path: '/seller', builder: (context, state) => const SellerDashboard()),
    GoRoute(path: '/customer', builder: (context, state) => const CustomerHome()),
  ],
);

