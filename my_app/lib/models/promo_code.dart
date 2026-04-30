class PromoCode {
  final String code;
  final String type; // 'percent' or 'amount'
  final int value;
  final String ar;
  final String en;
  final bool active;
  final int uses;
  final int max;
  final String expires; // ISO date string

  const PromoCode({
    required this.code,
    required this.type,
    required this.value,
    required this.ar,
    required this.en,
    this.active = true,
    this.uses = 0,
    this.max = 0,
    this.expires = '',
  });

  String label(String lang) => lang == 'ar' ? ar : en;

  int discountFor(int subtotal) {
    if (type == 'percent') return (subtotal * value / 100).round();
    return value;
  }
}
