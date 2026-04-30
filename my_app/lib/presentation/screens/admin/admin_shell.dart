import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/router/routes.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/theme.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  static int _indexForLocation(String loc) {
    if (loc.startsWith('/admin/orders'))   return 1;
    if (loc.startsWith('/admin/products')) return 2;
    if (loc.startsWith('/admin/promos'))   return 3;
    return 0; // overview
  }

  static const _paths = [
    Routes.admin,
    Routes.adminOrders,
    Routes.adminProducts,
    Routes.adminPromos,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).matchedLocation;
    final idx = _indexForLocation(loc);

    return Scaffold(
      backgroundColor: TbColors.bg,
      appBar: _AdminTopBar(onExit: () {
        ref.read(authProvider).logout();
        context.go(Routes.login);
      }),
      body: child,
      bottomNavigationBar: _AdminTabBar(
        currentIndex: idx,
        onTap: (i) => context.go(_paths[i]),
      ),
    );
  }
}

class _AdminTopBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onExit;
  const _AdminTopBar({required this.onExit});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TbColors.ink,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: TbColors.yellow,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, size: 20, color: TbColors.ink),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('لوحة الإدارة',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                          color: TbColors.cream, letterSpacing: 0.06, height: 1)),
                  SizedBox(height: 2),
                  Text('teleBabies',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
                          color: TbColors.cream, height: 1)),
                ],
              ),
            ),
            TextButton(
              onPressed: onExit,
              style: TextButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: TbColors.cream,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: const StadiumBorder(),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('خروج'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdminTabBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const _AdminTabBar({required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (icon: Icons.auto_awesome_rounded,   label: 'نظرة'),
      (icon: Icons.receipt_long_outlined,  label: 'الطلبات'),
      (icon: Icons.checkroom_outlined,     label: 'المنتجات'),
      (icon: Icons.sell_outlined,          label: 'الأكواد'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: TbColors.card,
        border: Border(top: BorderSide(color: TbColors.line)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final active = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 56, height: 30,
                    decoration: BoxDecoration(
                      color: active ? TbColors.yellow.withValues(alpha: 0.25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(tabs[i].icon, size: 22,
                        color: active ? TbColors.ink : TbColors.ink3),
                  ),
                  const SizedBox(height: 2),
                  Text(tabs[i].label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        color: active ? TbColors.ink : TbColors.ink3,
                      )),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
