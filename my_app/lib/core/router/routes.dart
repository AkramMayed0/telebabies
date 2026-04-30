abstract class Routes {
  // ── Auth ──────────────────────────────────────────────────────────────────
  static const login    = '/login';
  static const register = '/register';
  static const verify   = '/verify';

  // ── Customer tabs (inside MainShell) ─────────────────────────────────────
  static const home    = '/home';
  static const browse  = '/browse';
  static const cart    = '/cart';
  static const orders  = '/orders';
  static const account = '/account';

  // ── Customer full-screen ──────────────────────────────────────────────────
  static const product  = '/product';   // /product/:id
  static const orderDetail = '/orders'; // /orders/:id  (shares prefix with tab)
  static const checkout = '/checkout';
  static const placed   = '/placed';    // /placed/:id

  // ── Admin tabs (inside AdminShell) ────────────────────────────────────────
  static const admin          = '/admin';
  static const adminOrders    = '/admin/orders';
  static const adminProducts  = '/admin/products';
  static const adminPromos    = '/admin/promos';

  // ── Admin full-screen ─────────────────────────────────────────────────────
  static const adminOrderDetail = '/admin/orders'; // /admin/orders/:id

  // ── Helpers ───────────────────────────────────────────────────────────────
  static String productPath(String id)      => '/product/$id';
  static String orderDetailPath(String id)  => '/orders/$id';
  static String placedPath(String id)       => '/placed/$id';
  static String adminOrderDetailPath(String id) => '/admin/orders/$id';
}
