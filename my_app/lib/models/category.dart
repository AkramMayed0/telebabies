class Category {
  final String id;
  final String ar;
  final String en;
  final int color;
  final String icon;

  const Category({
    required this.id,
    required this.ar,
    required this.en,
    required this.color,
    required this.icon,
  });

  String label(String lang) => lang == 'ar' ? ar : en;
}
