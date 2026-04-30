class Review {
  final String id;
  final String nameAr;
  final String nameEn;
  final int rating;
  final String dateAr;
  final String dateEn;
  final String textAr;
  final String textEn;
  final bool verified;
  int helpful;

  Review({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.rating,
    required this.dateAr,
    required this.dateEn,
    required this.textAr,
    required this.textEn,
    this.verified = false,
    this.helpful = 0,
  });

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String text(String lang) => lang == 'ar' ? textAr : textEn;
  String date(String lang) => lang == 'ar' ? dateAr : dateEn;
}
