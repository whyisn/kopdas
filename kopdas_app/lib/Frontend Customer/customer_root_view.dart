import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/router.dart';
import 'app/routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';

/// Entry widget for Customer role embedded in Kopdas project
class CustomerRootView extends StatelessWidget {
  final String initialRoute;
  final String? initialUserName;

  const CustomerRootView({
    super.key,
    this.initialRoute = Routes.home,
    this.initialUserName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            initialUserName: initialUserName ?? 'Sobat Kopi',
          ),
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: Builder(
        builder: (context) {
          final brightness = Theme.of(context).brightness;
          return Theme(
            data: buildTheme(brightness),
            child: Navigator(
              initialRoute: initialRoute,
              onGenerateRoute: AppRouter.generate,
            ),
          );
        },
      ),
    );
  }
}
