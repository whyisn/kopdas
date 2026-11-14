import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Kopi Cerdas';
  static const String appTagline = 'Smart Coffee Network';

  // Development Demo Mode: data simulasi lokal, tanpa login/token backend.
  // Set false untuk Production Mode (login + API backend asli).
  static const bool demoMode = true;

  // Routing bypass mengikuti demo mode (skip login → Seller Dashboard).
  static const bool devBypassAuth = demoMode;

  // API Backend Base URL (FastAPI)
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  // Theme Colors
  static const Color primaryColor = Color(0xFF6F4E37);    // Coffee Brown
  static const Color primaryDark = Color(0xFF4A3525);
  static const Color accentColor = Color(0xFFD4A373);     // Caramel Warm
  static const Color backgroundColor = Color(0xFFFAEDCD); // Warm Latte
  static const Color surfaceColor = Colors.white;
  static const Color textDark = Color(0xFF2B2118);

  // Status Colors
  static const Color statusSuccess = Color(0xFF2A9D8F);
  static const Color statusWarning = Color(0xFFE76F51);
  static const Color statusPending = Color(0xFFF4A261);

  // Data Labels
  static const String labelReal = 'REAL';
  static const String labelSimulation = 'SIMULASI';
}
