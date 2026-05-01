// lib/presentation/widgets/product/product_card.dart
// REPLACE existing file

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String lang;

  const ProductCard({
    super.key,
    required this.product,
    this.lang = 'ar',
  });

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color get _bgColor {
    final h = product.color.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  /// Discount percentage shown on the badge, e.g. 29
  int? get _discountPct {
    final old = product.oldPrice;
    if (old == null || old <= product.price) return null;
    return (((old - product.price) / old) * 100).round();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bg   = _bgColor;
    final name = lang == 'ar' ? product.nameAr : product.nameEn;
    final tag  = lang == 'ar' ? product.tagAr  : product.tagEn;
    final pct  = _discountPct;

    return GestureDetector(
      onTap: () => context.push('/product/${product.id}'),
      child: DecoratedBox(
        decoration: tbCardDecoration,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Image ───────────────────────────────────────────────
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Colour-matched background
                    ColoredBox(color: bg.withOpacity(0.25)),

                    // Cached product image
                    if (product.img != null)
                      CachedNetworkImage(
                        imageUrl: product.img!,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 200),
                        placeholder: (_, __) =>
                            ColoredBox(color: bg.withOpacity(0.25)),
                        errorWidget: (_, __, ___) => Center(
                          child: Icon(
                            Icons.child_care_rounded,
                            size: 40,
                            color: bg.withOpacity(0.6),
                          ),
                        ),
                      ),

                    // Tag badge — top-right (RTL: start side)
                    if (tag != null)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: _Badge(
                          label: tag,
                          bg: TbColors.ink,
                          fg: TbColors.cream,
                        ),
                      ),

                    // Discount badge — top-left (RTL: end side)
                    if (pct != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _Badge(
                          label: '-$pct%',
                          bg: TbColors.pink,
                          fg: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),

              // ── Info ────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: TbColors.ink,
                        height: 1.25,
                      ),
                    ),

                    // Age · sizes count
                    const SizedBox(height: 3),
                    Text(
                      lang == 'ar'
                          ? '${product.age} سنة · ${product.sizes.length} مقاسات'
                          : '${product.age} yrs · ${product.sizes.length} sizes',
                      style: const TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 11,
                        color: TbColors.ink3,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Price row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          fmtYER(product.price, lang),
                          style: const TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: TbColors.pink,
                          ),
                        ),
                        if (product.oldPrice != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            fmtYER(product.oldPrice!, lang),
                            style: const TextStyle(
                              fontFamily: TbFonts.arabic,
                              fontSize: 11,
                              color: TbColors.ink3,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Badge ─────────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: TbFonts.arabic,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1,
        ),
      ),
    );
  }
}