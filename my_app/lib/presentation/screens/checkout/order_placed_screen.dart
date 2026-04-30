import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/theme.dart';
import 'package:my_app/core/utils/tb_utils.dart';

class OrderPlacedScreen extends StatelessWidget {
  final String orderId;
  const OrderPlacedScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    const lang = 'ar';
    return Scaffold(
      backgroundColor: TbColors.bg,
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: TbColors.mint,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TbColors.mint.withValues(alpha: 0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded, color: TbColors.ink, size: 68),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      t(lang, 'تم استلام طلبك! 🎉', 'Order placed! 🎉'),
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: TbColors.ink),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t(lang,
                        'سنراجع إيصال الدفع ونؤكد طلبك خلال ساعة.',
                        'We\'ll review your receipt and confirm within an hour.'),
                      style: const TextStyle(fontSize: 14, color: TbColors.ink2, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: tbCardDecoration,
                      child: Column(
                        children: [
                          Text(t(lang, 'رقم الطلب', 'Order ID'),
                              style: const TextStyle(fontSize: 11, color: TbColors.ink3, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(orderId,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: TbColors.ink)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.go('/home'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: const StadiumBorder(),
                      side: const BorderSide(color: TbColors.line),
                    ),
                    child: Text(t(lang, 'العودة للرئيسية', 'Back to home'),
                        style: const TextStyle(fontWeight: FontWeight.w700, color: TbColors.ink)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => context.go('/orders/$orderId'),
                    child: Text(t(lang, 'تتبع الطلب', 'Track order')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
