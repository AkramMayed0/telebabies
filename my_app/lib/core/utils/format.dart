// Currency formatter — matches design's fmtYER
String fmtYER(int amount, String lang) {
  if (lang == 'ar') {
    final s = _toArabicNumerals(amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    ));
    return '$s ر.ي';
  }
  final s = amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '$s YER';
}

String _toArabicNumerals(String s) {
  const en = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const ar = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  var result = s;
  for (var i = 0; i < en.length; i++) {
    result = result.replaceAll(en[i], ar[i]);
  }
  return result;
}
