import 'package:flutter/material.dart';

import 'Frontend owner/owner_dashboard_view.dart';

void main() {
  runApp(const KopiCerdasApp());
}

class KopiCerdasApp extends StatelessWidget {
  const KopiCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KopiCerdas AI - Portal Owner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3932), // Dark Forest Green (3S.NET / Starbucks style)
          primary: const Color(0xFF1E3932),
          secondary: const Color(0xFF134E4A),
          surface: Colors.white,
        ),
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      ),
      home: const OwnerDashboardView(),
    );
  }
}
