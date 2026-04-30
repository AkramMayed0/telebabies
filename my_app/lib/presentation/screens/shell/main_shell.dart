import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/theme.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';

class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static int _indexForLocation(String location) {
    if (location.startsWith('/browse')) return 1;
    if (location.startsWith('/cart')) return 2;
    if (location.startsWith('/orders')) return 3;
    if (location.startsWith('/account')) return 4;
    return 0;
  }

  static String _locationForIndex(int index) {
    const paths = ['/home', '/browse', '/cart', '/orders', '/account'];
    return paths[index];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);
    final cartCount = ref.watch(cartProvider).count;

    return Scaffold(
      body: child,
      bottomNavigationBar: _TbTabBar(
        currentIndex: currentIndex,
        cartCount: cartCount,
        onTap: (i) => context.go(_locationForIndex(i)),
      ),
    );
  }
}

class _TbTabBar extends StatelessWidget {
  final int currentIndex;
  final int cartCount;
  final ValueChanged<int> onTap;

  const _TbTabBar({
    required this.currentIndex,
    required this.cartCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tabs = [
      (icon: Icons.home_rounded,           label: 'الرئيسية'),
      (icon: Icons.search_rounded,         label: 'تصفح'),
      (icon: Icons.shopping_bag_outlined,  label: 'السلة'),
      (icon: Icons.receipt_long_outlined,  label: 'طلباتي'),
      (icon: Icons.person_outline_rounded, label: 'حسابي'),
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
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 56,
                        height: 30,
                        decoration: BoxDecoration(
                          color: active ? TbColors.pinkSoft : Colors.transparent,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          tabs[i].icon,
                          size: 22,
                          color: active ? TbColors.ink : TbColors.ink3,
                        ),
                      ),
                      if (i == 2 && cartCount > 0)
                        Positioned(
                          top: -2,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            height: 18,
                            constraints: const BoxConstraints(minWidth: 18),
                            decoration: BoxDecoration(
                              color: TbColors.pink,
                              borderRadius: BorderRadius.circular(9),
                              border: Border.all(color: TbColors.card, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                '$cartCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  height: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tabs[i].label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? TbColors.ink : TbColors.ink3,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
