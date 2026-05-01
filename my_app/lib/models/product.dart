// lib/models/product.dart
// NEW FILE

class Product {
  final String id;
  final String nameAr;
  final String nameEn;
  final String cat;    // gender: 'girls' | 'boys' | 'unisex'
  final String age;    // age group: '0-2' | '2-4' | '4-6' | '6-10'
  final String type;   // clothing type: 'dress' | 'tshirt' | 'jacket' etc.
  final int price;
  final int? oldPrice;
  final String? img;
  final String color;
  final String? tagAr;
  final String? tagEn;
  final String descAr;
  final String descEn;
  final List<String> sizes;
  final int stock;

  const Product({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.cat,
    required this.age,
    required this.type,
    required this.price,
    this.oldPrice,
    this.img,
    required this.color,
    this.tagAr,
    this.tagEn,
    required this.descAr,
    required this.descEn,
    required this.sizes,
    required this.stock,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id:       j['id'] as String,
        nameAr:   j['name_ar'] as String,
        nameEn:   j['name_en'] as String,
        cat:      j['cat'] as String,
        age:      j['age'] as String,
        type:     j['type'] as String,
        price:    j['price'] as int,
        oldPrice: j['old_price'] as int?,
        img:      j['img'] as String?,
        color:    (j['color'] as String?) ?? '#FFD23F',
        tagAr:    j['tag_ar'] as String?,
        tagEn:    j['tag_en'] as String?,
        descAr:   (j['desc_ar'] as String?) ?? '',
        descEn:   (j['desc_en'] as String?) ?? '',
        sizes:    (j['sizes'] as List<dynamic>?)
                      ?.map((e) => e as String)
                      .toList() ??
                  [],
        stock:    (j['stock'] as int?) ?? 0,
      );
}