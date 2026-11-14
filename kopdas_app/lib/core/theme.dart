import 'package:flutter/material.dart';

import 'constants.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      primary: AppConstants.primaryColor,
      secondary: AppConstants.accentColor,
      surface: AppConstants.surfaceColor,
    ),
    scaffoldBackgroundColor: AppConstants.backgroundColor,
    useMaterial3: true,
    fontFamily: 'Segoe UI',
  );
}