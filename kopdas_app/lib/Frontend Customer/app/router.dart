import 'package:flutter/material.dart';
import '../features/auth/auth_screens.dart';
import '../features/checkout/checkout_screens.dart';
import '../features/explore/explore_screens.dart';
import '../features/home/home_screen.dart';
import '../features/menu/menu_screens.dart';
import '../features/payment/payment_screens.dart';
import '../features/review/review_screens.dart';
import '../features/tracking/tracking_screens.dart';
import 'routes.dart';

class AppRouter {
  AppRouter._();

  static final Map<String, WidgetBuilder> _builders = {
    Routes.welcome: (_) => const WelcomeScreen(),
    Routes.register: (_) => const RegisterScreen(),
    Routes.login: (_) => const CustomerLoginScreen(),
    Routes.home: (_) => const HomeScreen(),
    Routes.explore: (_) => const ExploreScreen(),
    Routes.manual: (_) => const ManualLocationScreen(),
    Routes.cartList: (_) => const CartListScreen(),
    Routes.noCart: (_) => const NoCartScreen(),
    Routes.menu: (_) => const MenuScreen(),
    Routes.customize: (_) => const CustomizeScreen(),
    Routes.cart: (_) => const CartScreen(),
    Routes.checkout: (_) => const CheckoutScreen(),
    Routes.validate: (_) => const ValidateScreen(),
    Routes.changes: (_) => const ChangesScreen(),
    Routes.request: (_) => const RequestScreen(),
    Routes.waiting: (_) => const WaitingScreen(),
    Routes.rejected: (_) => const RejectedScreen(),
    Routes.adjust: (_) => const AdjustOrderScreen(),
    Routes.reserve: (_) => const ReserveScreen(),
    Routes.bill: (_) => const BillScreen(),
    Routes.expired: (_) => const ExpiredScreen(),
    Routes.paid: (_) => const PaidScreen(),
    Routes.making: (_) => const MakingScreen(),
    Routes.ready: (_) => const ReadyScreen(),
    Routes.pickupCode: (_) => const PickupCodeScreen(),
    Routes.arrive: (_) => const ArriveScreen(),
    Routes.verify: (_) => const VerifyScreen(),
    Routes.handover: (_) => const HandoverScreen(),
    Routes.done: (_) => const DoneScreen(),
    Routes.review: (_) => const ReviewScreen(),
    Routes.end: (_) => const EndScreen(),
  };

  static Route<dynamic> generate(RouteSettings s) {
    final b = _builders[s.name] ?? _builders[Routes.welcome]!;
    return MaterialPageRoute(settings: s, builder: b);
  }
}
