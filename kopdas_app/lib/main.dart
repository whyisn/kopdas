import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/theme.dart';
import 'routes/app_routes.dart';

void main() {
  runApp(const KopiCerdasApp());
}

class KopiCerdasApp extends StatelessWidget {
  const KopiCerdasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}