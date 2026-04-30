import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final settingsProvider =
    ChangeNotifierProvider<SettingsNotifier>((ref) => SettingsNotifier());

class SettingsNotifier extends ChangeNotifier {
  String _lang = 'ar';

  String get lang => _lang;
  bool get isArabic => _lang == 'ar';

  void setLang(String lang) {
    if (_lang == lang) return;
    _lang = lang;
    notifyListeners();
  }
}
