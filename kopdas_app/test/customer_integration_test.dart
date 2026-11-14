import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kopdas_app/Frontend%20Customer/customer_root_view.dart';
import 'package:kopdas_app/Frontend%20Customer/app/routes.dart';

void main() {
  testWidgets('CustomerRootView mounts and renders home screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomerRootView(initialRoute: Routes.home),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify customer home screen elements exist
    expect(find.text('Explore Coffee Cart'), findsOneWidget);
    expect(find.byType(CustomerRootView), findsOneWidget);
  });

  testWidgets('CustomerRootView can mount on welcome screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomerRootView(initialRoute: Routes.welcome),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Sudah punya akun?'), findsOneWidget);
  });
}
