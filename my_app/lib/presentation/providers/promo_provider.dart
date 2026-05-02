// lib/presentation/providers/promo_provider.dart
// NEW FILE

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/data/network/dio_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

/// Result returned by the backend when a promo code is valid.
class PromoResult {
  final String code;
  final String type;   // 'percent' | 'fixed'
  final int value;     // percentage (0-100) or fixed amount in YER
  final int discount;  // actual YER amount deducted from this subtotal
  final int subtotal;  // the subtotal the server computed against

  const PromoResult({
    required this.code,
    required this.type,
    required this.value,
    required this.discount,
    required this.subtotal,
  });

  factory PromoResult.fromJson(Map<String, dynamic> j) => PromoResult(
        code:     j['code'] as String,
        type:     j['type'] as String,
        value:    j['value'] as int,
        discount: j['discount'] as int,
        subtotal: j['subtotal'] as int,
      );

  /// Human-readable description, e.g. "10%" or "5,000 ر.ي".
  String get label => type == 'percent' ? '$value%' : '$value ر.ي';
}

// ─────────────────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────────────────

enum PromoStatus { idle, loading, applied, error }

class PromoState {
  final PromoStatus status;
  final PromoResult? result;  // non-null when status == applied
  final String? errorMessage; // non-null when status == error

  const PromoState({
    this.status = PromoStatus.idle,
    this.result,
    this.errorMessage,
  });

  // ── Convenience getters ───────────────────────────────────────────────────

  bool get isIdle    => status == PromoStatus.idle;
  bool get isLoading => status == PromoStatus.loading;
  bool get isApplied => status == PromoStatus.applied;
  bool get hasError  => status == PromoStatus.error;

  /// YER discount amount to deduct from the cart total.
  /// Zero when no code is applied or on error.
  int get discountAmount => result?.discount ?? 0;

  // ── Copy helpers ──────────────────────────────────────────────────────────

  PromoState asLoading() => const PromoState(status: PromoStatus.loading);

  PromoState asApplied(PromoResult r) =>
      PromoState(status: PromoStatus.applied, result: r);

  PromoState asError(String msg) =>
      PromoState(status: PromoStatus.error, errorMessage: msg);

  PromoState asIdle() => const PromoState();

  @override
  String toString() => 'PromoState($status, discount: $discountAmount)';
}

// ─────────────────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────────────────

class PromoNotifier extends Notifier<PromoState> {
  @override
  PromoState build() => const PromoState();

  Dio get _dio => ref.read(dioProvider);

  /// Call `POST /api/discount-codes/apply` with the given [code] and [subtotal].
  ///
  /// Handles all backend error shapes:
  /// - 400 → bad input
  /// - 404 → invalid / inactive code
  /// - 422 → expired / usage limit / min_order not met
  Future<void> apply({
    required String code,
    required int subtotal,
  }) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return;

    // ── Guard: reject if subtotal is 0 ────────────────────────────────────
    if (subtotal <= 0) {
      state = state.asError('أضف منتجات إلى السلة أولاً');
      return;
    }

    state = state.asLoading();

    try {
      final res = await _dio.post<Map<String, dynamic>>(
        '/api/discount-codes/apply',
        data: {'code': trimmed, 'subtotal': subtotal},
      );

      final result = PromoResult.fromJson(res.data!);
      state = state.asApplied(result);
    } on DioException catch (e) {
      state = state.asError(_mapError(e));
    } catch (_) {
      state = state.asError('حدث خطأ غير متوقع، يرجى المحاولة مجددًا');
    }
  }

  /// Clear the applied code and reset to idle.
  void clear() => state = state.asIdle();

  // ── Error mapping ─────────────────────────────────────────────────────────

  String _mapError(DioException e) {
    final status = e.response?.statusCode;
    final data   = e.response?.data;

    // Backend may send { error: '...' } or { error: '...', min_order: N }
    final serverMsg = data is Map ? data['error'] as String? : null;
    final minOrder  = data is Map ? data['min_order'] as int? : null;

    return switch (status) {
      400 => 'كود الخصم أو المبلغ غير صحيح',
      404 => 'كود الخصم غير صحيح أو غير مفعّل',
      422 => _map422(serverMsg, minOrder),
      429 => 'تجاوزت عدد المحاولات، انتظر قليلاً',
      500 || 502 || 503 =>
        'الخادم غير متاح حالياً، يرجى المحاولة لاحقاً',
      _ when e.type == DioExceptionType.connectionTimeout ||
             e.type == DioExceptionType.receiveTimeout =>
        'انتهت مهلة الاتصال، تحقق من الإنترنت',
      _ when e.type == DioExceptionType.connectionError =>
        'تعذّر الاتصال بالخادم، تحقق من الإنترنت',
      _ => serverMsg ?? 'فشل تطبيق الكود، يرجى المحاولة مجددًا',
    };
  }

  String _map422(String? serverMsg, int? minOrder) {
    if (serverMsg == null) return 'لا يمكن تطبيق كود الخصم';

    final msg = serverMsg.toLowerCase();
    if (msg.contains('expired'))       return 'انتهت صلاحية كود الخصم';
    if (msg.contains('usage limit'))   return 'وصل الكود إلى الحد الأقصى للاستخدام';
    if (msg.contains('minimum order')) {
      final fmt = minOrder != null
          ? '${minOrder.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ر.ي'
          : '';
      return 'الحد الأدنى للطلب${fmt.isNotEmpty ? ' $fmt' : ''} غير مكتمل';
    }
    return serverMsg;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Scoped to the cart session — auto-clears when the widget tree disposes.
///
/// Usage:
/// ```dart
/// final promo = ref.watch(promoProvider);
/// ref.read(promoProvider.notifier).apply(code: 'EID2026', subtotal: 12000);
/// ref.read(promoProvider.notifier).clear();
/// ```
final promoProvider = NotifierProvider<PromoNotifier, PromoState>(
  PromoNotifier.new,
);