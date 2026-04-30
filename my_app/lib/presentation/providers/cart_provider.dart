import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/cart_item.dart';

final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) => CartNotifier());

class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get count => _items.fold(0, (sum, i) => sum + i.qty);

  int total(Map<String, int> prices) =>
      _items.fold(0, (sum, i) => sum + (prices[i.productId] ?? 0) * i.qty);

  void add(String productId, String size, {int qty = 1}) {
    final idx = _items.indexWhere(
        (i) => i.productId == productId && i.size == size);
    if (idx >= 0) {
      _items[idx] = _items[idx].copyWith(qty: _items[idx].qty + qty);
    } else {
      _items.add(CartItem(productId: productId, size: size, qty: qty));
    }
    notifyListeners();
  }

  void remove(String productId, String size) {
    _items.removeWhere((i) => i.productId == productId && i.size == size);
    notifyListeners();
  }

  void updateQty(String productId, String size, int qty) {
    final idx = _items.indexWhere(
        (i) => i.productId == productId && i.size == size);
    if (idx < 0) return;
    if (qty <= 0) {
      _items.removeAt(idx);
    } else {
      _items[idx] = _items[idx].copyWith(qty: qty);
    }
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
