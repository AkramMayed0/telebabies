// lib/models/cart_item.dart
// REPLACE: my_app/lib/models/cart_item.dart

/// A single line in the shopping cart.
///
/// Carries everything the cart UI needs to render itself without
/// a separate product lookup — name, image URL, and unit price are
/// snapshotted at the moment the item is added, exactly like the
/// backend's `unit_price` snapshot in `order_items`.
class CartItem {
  final String productId;
  final String name;       // Arabic name (primary display language)
  final String? imageUrl;  // nullable — products may not have a photo yet
  final int unitPrice;     // YER, integer — matches backend convention
  final String size;
  final int quantity;

  const CartItem({
    required this.productId,
    required this.name,
    this.imageUrl,
    required this.unitPrice,
    required this.size,
    required this.quantity,
  });

  // ── Computed ────────────────────────────────────────────────────────────

  /// Total price for this line: unit × quantity.
  int get lineTotal => unitPrice * quantity;

  // ── Immutable copy helpers ───────────────────────────────────────────────

  CartItem copyWith({
    String? productId,
    String? name,
    String? imageUrl,
    int? unitPrice,
    String? size,
    int? quantity,
  }) {
    return CartItem(
      productId:  productId  ?? this.productId,
      name:       name       ?? this.name,
      imageUrl:   imageUrl   ?? this.imageUrl,
      unitPrice:  unitPrice  ?? this.unitPrice,
      size:       size       ?? this.size,
      quantity:   quantity   ?? this.quantity,
    );
  }

  // ── Equality ─────────────────────────────────────────────────────────────
  // Two CartItems are the same line when they share product + size.

  @override
  bool operator ==(Object other) =>
      other is CartItem &&
      other.productId == productId &&
      other.size == size;

  @override
  int get hashCode => Object.hash(productId, size);

  @override
  String toString() =>
      'CartItem($productId, size: $size, qty: $quantity, price: $unitPrice)';
}