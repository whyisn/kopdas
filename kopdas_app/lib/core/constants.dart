import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'KopiCerdas AI';
  static const String appTagline = 'Smart Coffee Network';

  // API Backend Base URL (FastAPI)
  static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';

  // Theme Colors (Harmonized with Owner Design System)
  static const Color primaryColor = Color(0xFF1E3932);    // Forest Green (Owner Benchmark)
  static const Color primaryDark = Color(0xFF11221E);     // Deep Forest Green
  static const Color accentColor = Color(0xFFD4A373);     // Caramel Warm
  static const Color backgroundColor = Color(0xFFF8FAFC); // Clean Slate Canvas
  static const Color surfaceColor = Colors.white;         // Clean White
  static const Color borderColor = Color(0xFFE5E7EB);      // Subtle Gray Border
  static const Color textDark = Color(0xFF111827);        // Charcoal Slate 900
  static const Color textMuted = Color(0xFF6B7280);       // Cool Gray 500

  // Status Colors (Matching Owner Pill Badges)
  static const Color statusSuccess = Color(0xFF059669);   // Emerald Green
  static const Color statusWarning = Color(0xFFD97706);   // Amber Warm
  static const Color statusPending = Color(0xFFF59E0B);   // Amber 500
  static const Color statusDanger = Color(0xFFDC2626);    // Rose Red
  static const Color statusInfo = Color(0xFF2563EB);      // Royal Blue

  // Data Labels
  static const String labelReal = 'REAL';
  static const String labelSimulation = 'SIMULASI';
}
