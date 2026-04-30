import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/data/services/api_service.dart';

final productProvider = ChangeNotifierProvider<ProductNotifier>((ref) {
  return ProductNotifier(ref.read(apiServiceProvider));
});

class ProductNotifier extends ChangeNotifier {
  // ignore: unused_field
  final ApiService _api;
  ProductNotifier(this._api);

  // ignore: prefer_final_fields
  List<Product> _products = [];
  bool _loading = false;
  String? _error;

  List<Product> get products => _products;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({String? category, String? search}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // TODO: map API response to Product list
      _loading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
    }
  }
}
