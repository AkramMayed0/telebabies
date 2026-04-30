import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

enum AppButtonVariant { primary, accent, ghost, soft }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool loading;
  final bool fullWidth;
  final AppButtonVariant variant;
  final Widget? icon;

  const AppButton({
    super.key,
    required this.label,
    this.onTap,
    this.loading = false,
    this.fullWidth = true,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg, border) = switch (variant) {
      AppButtonVariant.primary => (TbColors.ink, TbColors.cream, BorderSide.none),
      AppButtonVariant.accent  => (TbColors.pink, Colors.white, BorderSide.none),
      AppButtonVariant.ghost   => (Colors.transparent, TbColors.ink, const BorderSide(color: TbColors.ink, width: 1.5)),
      AppButtonVariant.soft    => (TbColors.card, TbColors.ink, BorderSide.none),
    };

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(label),
            ],
          );

    final button = ElevatedButton(
      onPressed: loading ? null : onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: TbColors.line,
        disabledForegroundColor: TbColors.ink3,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: border,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        minimumSize: const Size(0, 52),
      ),
      child: child,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
