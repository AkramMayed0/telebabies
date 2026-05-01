// lib/presentation/providers/products_provider.dart
// NEW FILE

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/services/api_client.dart';

// ── Filter params ─────────────────────────────────────────────────────────────
// Passed as the family key so the provider re-fetches when any value changes.

class ProductFilter {
  final String? search;
  final String? age;
  final String? cat;
  final String? type;

  const ProductFilter({
    this.search,
    this.age,
    this.cat,
    this.type,
  });

  // Convert to Dio query params — omit null/empty values.
  Map<String, dynamic> toQueryParams() => {
        if (search != null && search!.isNotEmpty) 'search': search,
        if (age != null) 'age': age,
        if (cat != null) 'cat': cat,
        if (type != null) 'type': type,
      };

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.search == search &&
      other.age == age &&
      other.cat == cat &&
      other.type == type;

  @override
  int get hashCode => Object.hash(search, age, cat, type);
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class ProductsNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Product>, ProductFilter> {
  @override
  Future<List<Product>> build(ProductFilter arg) => _fetch(arg);

  Future<List<Product>> _fetch(ProductFilter filter) async {
    try {
      final res = await ApiClient.instance.dio.get<dynamic>(
        '/products',
        queryParameters: filter.toQueryParams(),
      );

      final list = res.data as List<dynamic>;
      return list
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      // Re-throw so AsyncValue.error surfaces in the UI.
      throw _mapError(e);
    }
  }

  /// Pull-to-refresh: re-runs the fetch with the same filter.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetch(arg));
  }

  String _mapError(DioException e) {
    final status = e.response?.statusCode;
    return switch (status) {
      500 => 'الخادم غير متاح حاليًا، يرجى المحاولة لاحقًا',
      429    => 'لقد تجاوزت عدد الطلبات، يرجى الانتظار قليلًا',
      _  when e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout =>
          'انتهت مهلة الاتصال، تحقق من الإنترنت',
      _ when e.type == DioExceptionType.connectionError =>
          'تعذّر الاتصال بالخادم، تحقق من الإنترنت',
      _ => 'حدث خطأ في تحميل المنتجات، يرجى المحاولة مجددًا',
    };
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final productsProvider = AsyncNotifierProvider.autoDispose
    .family<ProductsNotifier, List<Product>, ProductFilter>(
  ProductsNotifier.new,
);