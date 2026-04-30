import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/order.dart';
import 'package:my_app/data/services/api_service.dart';

final orderProvider = ChangeNotifierProvider<OrderNotifier>((ref) {
  return OrderNotifier(ref.read(apiServiceProvider));
});

class OrderNotifier extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _api;
  OrderNotifier(this._api);

  // ignore: prefer_final_fields
  List<Order> _orders = [];
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // TODO: map API response to Order list
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }
}
