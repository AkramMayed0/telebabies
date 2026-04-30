import 'package:flutter/material.dart';

class Product {
  final String id;
  final String nameAr;
  final String nameEn;
  final String cat;
  final String age;
  final String type;
  final int price;
  final int? oldPrice;
  final String? img;
  final Color color;
  final String? tagAr;
  final String? tagEn;
  final String descAr;
  final String descEn;
  final List<String> sizes;
  final int stock;
  final String currency;

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
    this.currency = 'YER',
  });

  String name(String lang) => lang == 'ar' ? nameAr : nameEn;
  String desc(String lang) => lang == 'ar' ? descAr : descEn;
  String? tag(String lang) => lang == 'ar' ? tagAr : tagEn;
}
