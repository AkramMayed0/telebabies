// Shared utility functions used across screens

String fmtYER(int amount, String lang) {
  if (lang == 'ar') {
    final s = amount.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return '$s ر.ي';
  }
  final s = amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  return '$s YER';
}

String t(String lang, String ar, String en) => lang == 'ar' ? ar : en;
