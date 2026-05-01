import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/data/network/api_exception.dart';
import 'package:my_app/data/network/dio_client.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref.read(dioProvider));
});

class ApiService {
  final Dio _dio;
  ApiService(this._dio);

  // ── Auth ──────────────────────────────────────────────────────────────────

Future<void> register({
  required String name,
  required String email,
  String? phone,
  required String password,
}) async {
  try {
    await _dio.post('/auth/register', data: {
      'name': name,
      'email': email,
      if (phone != null) 'phone': phone,
      'password': password,
    });
  } on DioException catch (e) {
    final status = e.response?.statusCode;
    final msg = e.response?.data?['message'] ?? e.response?.data?['error'];
    throw switch (status) {
      409 => 'هذا الحساب مسجل مسبقًا، يرجى تسجيل الدخول',
      422 => 'تنسيق البريد الإلكتروني أو رقم الهاتف غير صحيح',
      429 => 'لقد تجاوزت عدد المحاولات، يرجى الانتظار قليلًا',
      500 => 'الخادم غير متاح حاليًا، يرجى المحاولة لاحقًا',
      _ => (msg is String && msg.isNotEmpty) ? msg : 'حدث خطأ، يرجى المحاولة مجددًا',
    };
  }
}

  Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) =>
      _post('/auth/login', {'identifier': identifier, 'password': password});

  Future<Map<String, dynamic>> requestOtp(String phone) =>
      _post('/auth/request-otp', {'phone': phone});

  Future<Map<String, dynamic>> verifyOtp(String phone, String code) =>
      _post('/auth/verify-otp', {'phone': phone, 'code': code});

  // ── Products ──────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getProducts({String? category, String? search}) =>
      _get('/products', params: {'category': category, 'search': search});

  Future<Map<String, dynamic>> getProduct(String id) =>
      _get('/products/$id');

  // ── Orders ────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getOrders() => _get('/orders');

  Future<Map<String, dynamic>> getOrder(String id) => _get('/orders/$id');

  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> payload) =>
      _post('/orders', payload);

  // ── Admin ─────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> adminGetOrders({String? status}) =>
      _get('/admin/orders', params: {'status': status});

  Future<Map<String, dynamic>> adminUpdateOrderStatus(
          String id, String status) =>
      _post('/admin/orders/$id/status', {'status': status});

  Future<Map<String, dynamic>> adminGetProducts() =>
      _get('/admin/products');

  Future<Map<String, dynamic>> adminGetStats() =>
      _get('/admin/stats');

  // ── Internals ─────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> _get(String path,
      {Map<String, dynamic>? params}) =>
      _call(() => _dio.get<Map<String, dynamic>>(
            path,
            queryParameters: params != null
                ? (Map.of(params)..removeWhere((_, v) => v == null))
                : null,
          ));

  Future<Map<String, dynamic>> _post(String path,
          Map<String, dynamic> body) =>
      _call(() => _dio.post<Map<String, dynamic>>(path, data: body));

  Future<Map<String, dynamic>> _call(
      Future<Response<Map<String, dynamic>>> Function() fn) async {
    try {
      final res = await fn();
      return res.data!;
    } on DioException catch (e) {
      // AuthInterceptor already wrapped the error; unwrap or convert.
      throw e.error is ApiException
          ? e.error as ApiException
          : ApiException.fromDio(e);
    }
  }
}
