import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/constants.dart';
import 'package:my_app/data/network/auth_interceptor.dart';
import 'package:my_app/data/services/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.read(tokenStorageProvider);
  return buildDioClient(storage);
});

Dio buildDioClient(TokenStorage storage, {void Function()? onUnauthorized}) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: AppConstants.connectTimeout,
    receiveTimeout: AppConstants.receiveTimeout,
    headers: {'Accept': 'application/json'},
  ));

  dio.interceptors.addAll([
    AuthInterceptor(storage, onUnauthorized: onUnauthorized),
    if (kDebugMode)
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => debugPrint('[Dio] $o'),
      ),
  ]);

  return dio;
}
