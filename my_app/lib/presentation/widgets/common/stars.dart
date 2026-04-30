import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class Stars extends StatelessWidget {
  final double value;
  final double size;
  final int? count;

  const Stars({super.key, this.value = 4.6, this.size = 14, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: TbColors.yellowDeep),
        const SizedBox(width: 4),
        Text(
          value.toStringAsFixed(1),
          style: TextStyle(fontSize: size - 1, fontWeight: FontWeight.w700, color: TbColors.ink),
        ),
        if (count != null) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: TextStyle(fontSize: size - 2, color: TbColors.ink3),
          ),
        ],
      ],
    );
  }
}
