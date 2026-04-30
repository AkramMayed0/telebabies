import 'package:flutter/foundation.dart';

class AppConstants {
  static const String _devBase  = 'http://10.0.2.2:3000';
  static const String _prodBase = 'https://api.telebabies.ye';

  static String get baseUrl => kDebugMode ? _devBase : _prodBase;

  static const Duration connectTimeout = Duration(seconds: 12);
  static const Duration receiveTimeout = Duration(seconds: 12);
}
