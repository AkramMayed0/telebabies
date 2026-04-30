class CartItem {
  final String productId;
  final String size;
  int qty;

  CartItem({required this.productId, required this.size, this.qty = 1});

  CartItem copyWith({int? qty}) => CartItem(productId: productId, size: size, qty: qty ?? this.qty);
}
