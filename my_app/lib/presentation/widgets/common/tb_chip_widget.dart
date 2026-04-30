import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class TbChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const TbChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? TbColors.ink : TbColors.card,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: selected ? TbColors.ink : TbColors.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? TbColors.cream : TbColors.ink2,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
