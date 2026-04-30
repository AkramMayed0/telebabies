import 'package:flutter/material.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/theme.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final String lang;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.lang = 'ar', this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: tbCardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: Container(color: product.color.withValues(alpha: 0.15)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name(lang), maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: TbColors.ink)),
                  const SizedBox(height: 4),
                  Row(children: [
                    Text('${product.price} ﷼', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: TbColors.ink)),
                    if (product.oldPrice != null) ...[
                      const SizedBox(width: 6),
                      Text('${product.oldPrice} ﷼',
                          style: const TextStyle(fontSize: 12, color: TbColors.ink3, decoration: TextDecoration.lineThrough)),
                    ],
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
