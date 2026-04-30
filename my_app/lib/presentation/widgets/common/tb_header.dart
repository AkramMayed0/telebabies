import 'package:flutter/material.dart';
import 'package:my_app/theme.dart';

class TbHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBack;

  const TbHeader({super.key, required this.title, this.actions, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: TbColors.ink)),
      automaticallyImplyLeading: showBack,
      actions: actions,
    );
  }
}
