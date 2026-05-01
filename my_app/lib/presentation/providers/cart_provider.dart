// lib/presentation/providers/cart_provider.dart
// REPLACE: my_app/lib/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/models/product.dart';

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

/// Immutable snapshot of the cart.
///
/// All derived values (count, subtotal, isEmpty) are computed properties
/// so the UI always reads a consistent view from a single source of truth.
class CartState {
  final List<CartItem> items;

  const CartState({this.items = const []});

  // ── Derived ───────────────────────────────────────────────────────────────

  /// Total number of individual units across all lines.
  int get count => items.fold(0, (sum, i) => sum + i.quantity);

  /// Sum of all line totals (unitPrice × quantity) in YER.
  int get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => items.isNotEmpty;

  // ── Copy helper ───────────────────────────────────────────────────────────

  CartState copyWith({List<CartItem>? items}) =>
      CartState(items: items ?? this.items);

  @override
  String toString() => 'CartState(${items.length} lines, subtotal: $subtotal)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class CartNotifier extends Notifier<CartState> {
  @override
  CartState build() => const CartState();

  // ── Internal helpers ──────────────────────────────────────────────────────

  /// Index of the existing line for [productId] + [size], or -1.
  int _indexOf(String productId, String size) => state.items
      .indexWhere((i) => i.productId == productId && i.size == size);

  List<CartItem> get _items => List<CartItem>.from(state.items);

  // ── Public API ────────────────────────────────────────────────────────────

  /// Add [quantity] units to the cart.
  ///
  /// Accepts a full [Product] so the CartItem is self-contained
  /// (name, image, price are snapshotted).
  ///
  /// If the same product+size is already in the cart the quantities
  /// are summed, capped at [product.stock].
  void addItem(Product product, String size, {int quantity = 1}) {
    assert(quantity > 0, 'quantity must be positive');

    final items = _items;
    final idx = _indexOf(product.id, size);

    if (idx >= 0) {
      // Existing line — increment, but never exceed stock
      final existing = items[idx];
      final newQty = (existing.quantity + quantity).clamp(1, product.stock);
      items[idx] = existing.copyWith(quantity: newQty);
    } else {
      // New line
      items.add(CartItem(
        productId: product.id,
        name:      product.nameAr,
        imageUrl:  product.img,
        unitPrice: product.price,
        size:      size,
        quantity:  quantity.clamp(1, product.stock),
      ));
    }

    state = state.copyWith(items: items);
  }

  /// Convenience overload used by screens that only have productId/size/qty
  /// available (e.g. restored from storage). Requires explicit field values.
  void addRaw({
    required String productId,
    required String name,
    String? imageUrl,
    required int unitPrice,
    required String size,
    int quantity = 1,
    int maxStock = 9999,
  }) {
    assert(quantity > 0, 'quantity must be positive');

    final items = _items;
    final idx = _indexOf(productId, size);

    if (idx >= 0) {
      final existing = items[idx];
      final newQty = (existing.quantity + quantity).clamp(1, maxStock);
      items[idx] = existing.copyWith(quantity: newQty);
    } else {
      items.add(CartItem(
        productId: productId,
        name:      name,
        imageUrl:  imageUrl,
        unitPrice: unitPrice,
        size:      size,
        quantity:  quantity.clamp(1, maxStock),
      ));
    }

    state = state.copyWith(items: items);
  }

  /// Remove the line for [productId] + [size] entirely.
  void removeItem(String productId, String size) {
    state = state.copyWith(
      items: state.items
          .where((i) => !(i.productId == productId && i.size == size))
          .toList(),
    );
  }

  /// Set an absolute quantity for [productId] + [size].
  ///
  /// Passing [quantity] ≤ 0 removes the line (matches UX where
  /// decrementing below 1 removes the item).
  void updateQuantity(String productId, String size, int quantity) {
    if (quantity <= 0) {
      removeItem(productId, size);
      return;
    }

    final items = _items;
    final idx = _indexOf(productId, size);
    if (idx < 0) return; // line not found — no-op

    items[idx] = items[idx].copyWith(quantity: quantity);
    state = state.copyWith(items: items);
  }

  /// Empty the cart completely.
  void clearCart() => state = const CartState();

  // ── Convenience getters used by UI ────────────────────────────────────────

  /// Total YER to pay (alias for [CartState.subtotal]).
  int get total => state.subtotal;

  /// Quantity already in cart for a specific product+size.
  /// Returns 0 if the line does not exist.
  int quantityFor(String productId, String size) {
    final idx = _indexOf(productId, size);
    return idx >= 0 ? state.items[idx].quantity : 0;
  }

  /// Whether a specific product+size is already in the cart.
  bool contains(String productId, String size) =>
      _indexOf(productId, size) >= 0;

  // ── Legacy shim ───────────────────────────────────────────────────────────
  // Keeps existing call sites (product_detail_screen, main_shell) compiling
  // without changes while the richer API is adopted screen-by-screen.

  /// Legacy: add by id/size/qty only. Uses productId as display name fallback.
  /// Prefer [addItem] when a [Product] object is available.
  void add(String productId, String size, {int qty = 1}) {
    addRaw(
      productId: productId,
      name:      productId, // placeholder — real name unknown without Product
      unitPrice: 0,         // placeholder — callers using this shim don't show price
      size:      size,
      quantity:  qty,
    );
  }

  /// Legacy alias for [removeItem].
  void remove(String productId, String size) => removeItem(productId, size);

  /// Legacy alias for [updateQuantity].
  void updateQty(String productId, String size, int qty) =>
      updateQuantity(productId, size, qty);

  /// Legacy alias for [clearCart].
  void clear() => clearCart();
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global cart provider.
///
/// Usage:
/// ```dart
/// // Read state
/// final cart = ref.watch(cartProvider);
/// final count = cart.count;
/// final subtotal = cart.subtotal;
///
/// // Call methods
/// ref.read(cartProvider.notifier).addItem(product, '3T');
/// ref.read(cartProvider.notifier).removeItem(product.id, '3T');
/// ref.read(cartProvider.notifier).updateQuantity(product.id, '3T', 2);
/// ref.read(cartProvider.notifier).clearCart();
/// ```
final cartProvider = NotifierProvider<CartNotifier, CartState>(
  CartNotifier.new,
);

// ─────────────────────────────────────────────────────────────────────────────
// Convenience selectors
// ─────────────────────────────────────────────────────────────────────────────
// Use these with ref.watch to rebuild only when the specific value changes.

/// Total item count (sum of all quantities).
final cartCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).count;
});

/// Cart subtotal in YER.
final cartSubtotalProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Whether the cart has any items.
final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});