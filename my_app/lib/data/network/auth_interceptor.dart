import 'package:dio/dio.dart';
import 'package:my_app/data/network/api_exception.dart';
import 'package:my_app/data/services/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _storage;
  final void Function()? onUnauthorized;

  AuthInterceptor(this._storage, {this.onUnauthorized});

  // Inject JWT from secure storage into every request.
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storage.read();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // Wrap DioException → ApiException so callers never touch Dio internals.
  // On 401 also wipe the stored token and fire the logout callback.
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.clear();
      onUnauthorized?.call();
    }
    final apiEx = ApiException.fromDio(err);
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: apiEx,
      message: apiEx.message,
      response: err.response,
      type: err.type,
    ));
  }
}
