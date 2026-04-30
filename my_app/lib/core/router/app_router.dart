import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/router/routes.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';

// Customer screens
import 'package:my_app/presentation/screens/auth/login_screen.dart';
import 'package:my_app/presentation/screens/auth/register_screen.dart';
import 'package:my_app/presentation/screens/auth/verifying_screen.dart';
import 'package:my_app/presentation/screens/shell/main_shell.dart';
import 'package:my_app/presentation/screens/home/home_screen.dart';
import 'package:my_app/presentation/screens/browse/browse_screen.dart';
import 'package:my_app/presentation/screens/cart/cart_screen.dart';
import 'package:my_app/presentation/screens/orders/orders_screen.dart';
import 'package:my_app/presentation/screens/account/account_screen.dart';
import 'package:my_app/presentation/screens/shop/product_detail_screen.dart';
import 'package:my_app/presentation/screens/orders/order_detail_screen.dart';
import 'package:my_app/presentation/screens/checkout/checkout_screen.dart';
import 'package:my_app/presentation/screens/checkout/order_placed_screen.dart';

// Admin screens
import 'package:my_app/presentation/screens/admin/admin_shell.dart';
import 'package:my_app/presentation/screens/admin/admin_overview_screen.dart';
import 'package:my_app/presentation/screens/admin/admin_orders_screen.dart';
import 'package:my_app/presentation/screens/admin/admin_order_detail_screen.dart';
import 'package:my_app/presentation/screens/admin/admin_products_screen.dart';
import 'package:my_app/presentation/screens/admin/admin_promos_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authProvider);

  return GoRouter(
    initialLocation: Routes.login,
    debugLogDiagnostics: true,
    refreshListenable: auth,
    redirect: (context, state) => _redirect(state, auth),
    routes: _routes,
  );
});

// ── Redirect logic ────────────────────────────────────────────────────────────
String? _redirect(GoRouterState state, AuthNotifier auth) {
  final loc = state.matchedLocation;
  final onAuthPage = loc == Routes.login || loc == Routes.register || loc == Routes.verify;

  // Not logged in — allow auth pages, bounce everything else to login.
  if (!auth.isAuthenticated) {
    return onAuthPage ? null : Routes.login;
  }

  // Already logged in — skip auth pages.
  if (onAuthPage) {
    return auth.isAdmin ? Routes.adminOrders : Routes.home;
  }

  // Customer trying to reach admin area.
  if (!auth.isAdmin && loc.startsWith('/admin')) {
    return Routes.home;
  }

  return null;
}

// ── Page transition helper ────────────────────────────────────────────────────
Page<dynamic> _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );

// ── Route table ───────────────────────────────────────────────────────────────
final _routes = <RouteBase>[
  // Auth — fade transition so it doesn't slide in like a normal page.
  GoRoute(
    path: Routes.login,
    pageBuilder: (_, s) => _fadePage(s, const LoginScreen()),
  ),
  GoRoute(
    path: Routes.register,
    pageBuilder: (_, s) => _fadePage(s, const RegisterScreen()),
  ),
  GoRoute(
    path: Routes.verify,
    pageBuilder: (_, s) => _fadePage(s, const VerifyingScreen()),
  ),

  // ── Customer tab shell ────────────────────────────────────────────────────
  ShellRoute(
    builder: (_, __, child) => MainShell(child: child),
    routes: [
      GoRoute(path: Routes.home,    builder: (_, __) => const HomeScreen()),
      GoRoute(path: Routes.browse,  builder: (_, __) => const BrowseScreen()),
      GoRoute(path: Routes.cart,    builder: (_, __) => const CartScreen()),
      GoRoute(path: Routes.orders,  builder: (_, __) => const OrdersScreen()),
      GoRoute(path: Routes.account, builder: (_, __) => const AccountScreen()),
    ],
  ),

  // Customer full-screen (no tab bar)
  GoRoute(
    path: '/product/:id',
    builder: (_, s) => ProductDetailScreen(productId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: '/orders/:id',
    builder: (_, s) => OrderDetailScreen(orderId: s.pathParameters['id']!),
  ),
  GoRoute(
    path: Routes.checkout,
    builder: (_, __) => const CheckoutScreen(),
  ),
  GoRoute(
    path: '/placed/:id',
    builder: (_, s) => OrderPlacedScreen(orderId: s.pathParameters['id']!),
  ),

  // ── Admin tab shell ───────────────────────────────────────────────────────
  ShellRoute(
    builder: (_, __, child) => AdminShell(child: child),
    routes: [
      GoRoute(path: Routes.admin,         builder: (_, __) => const AdminOverviewScreen()),
      GoRoute(path: Routes.adminOrders,   builder: (_, __) => const AdminOrdersScreen()),
      GoRoute(path: Routes.adminProducts, builder: (_, __) => const AdminProductsScreen()),
      GoRoute(path: Routes.adminPromos,   builder: (_, __) => const AdminPromosScreen()),
    ],
  ),

  // Admin order detail — full-screen, no admin tab bar
  GoRoute(
    path: '/admin/orders/:id',
    builder: (_, s) =>
        AdminOrderDetailScreen(orderId: s.pathParameters['id']!),
  ),
];
