// lib/presentation/screens/cart/cart_screen.dart
// REPLACE: my_app/lib/presentation/screens/cart/cart_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cart Screen
// ─────────────────────────────────────────────────────────────────────────────

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: cart.isEmpty
            ? const _EmptyCart()
            : _CartBody(cart: cart),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header
          const _CartHeader(itemCount: 0),

          // Body
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon circle
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: TbColors.yellow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: TbColors.yellow.withOpacity(0.35),
                            blurRadius: 40,
                            offset: const Offset(0, 14),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🛍️', style: TextStyle(fontSize: 52)),
                      ),
                    ),
                    const SizedBox(height: 22),

                    const Text(
                      'سلتك فارغة',
                      style: TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: TbColors.ink,
                      ),
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'تصفح أحدث القطع وأضفها إلى سلتك',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 14,
                        color: TbColors.ink2,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),

                    AppButton(
                      label: 'تصفح المنتجات',
                      variant: AppButtonVariant.primary,
                      icon: const Icon(
                        Icons.search_rounded,
                        size: 18,
                        color: TbColors.cream,
                      ),
                      onTap: () => context.go('/home'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart body — list + summary + checkout
// ─────────────────────────────────────────────────────────────────────────────

class _CartBody extends ConsumerWidget {
  final CartState cart;
  const _CartBody({required this.cart});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          _CartHeader(itemCount: cart.items.length),

          // ── Scrollable items + summary ──────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Items list
                ...cart.items.map(
                  (item) => _CartItemTile(
                    key: ValueKey('${item.productId}_${item.size}'),
                    item: item,
                    onIncrement: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(
                          item.productId,
                          item.size,
                          item.quantity + 1,
                        ),
                    onDecrement: () => ref
                        .read(cartProvider.notifier)
                        .updateQuantity(
                          item.productId,
                          item.size,
                          item.quantity - 1,
                        ),
                    onRemove: () => ref
                        .read(cartProvider.notifier)
                        .removeItem(item.productId, item.size),
                  ),
                ),

                const SizedBox(height: 20),

                // Order summary card
                _SummaryCard(cart: cart),

                const SizedBox(height: 12),

                // Clear cart link
                Center(
                  child: GestureDetector(
                    onTap: () => _confirmClear(context, ref),
                    child: const Text(
                      'إفراغ السلة',
                      style: TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: TbColors.ink3,
                        decoration: TextDecoration.underline,
                        decorationColor: TbColors.ink3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sticky checkout bar ─────────────────────────────────────────
          _CheckoutBar(grandTotal: cart.subtotal + _SummaryCard.shipping),
        ],
      ),
    );
  }

  void _confirmClear(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ClearConfirmSheet(),
    ).then((confirmed) {
      if (confirmed == true) {
        ref.read(cartProvider.notifier).clearCart();
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  final int itemCount;
  const _CartHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          const Text(
            'سلتي',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: TbColors.ink,
            ),
          ),
          if (itemCount > 0) ...[
            const SizedBox(width: 8),
            Text(
              '($itemCount)',
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: TbColors.ink3,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart item tile
// ─────────────────────────────────────────────────────────────────────────────

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const _CartItemTile({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: TbColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TbColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Product image ───────────────────────────────────────────────
          _ProductThumb(imageUrl: item.imageUrl),
          const SizedBox(width: 12),

          // ── Name + size + price + stepper ───────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TbColors.ink,
                  ),
                ),
                const SizedBox(height: 3),

                // Size badge
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: TbColors.bg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: TbColors.line),
                      ),
                      child: Text(
                        'المقاس: ${item.size}',
                        style: const TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: TbColors.ink2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price row + stepper
                Row(
                  children: [
                    // Line subtotal (unit × qty)
                    Expanded(
                      child: Text(
                        fmtYER(item.lineTotal, 'ar'),
                        style: const TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: TbColors.pink,
                        ),
                      ),
                    ),

                    // Qty stepper pill
                    _QtyPill(
                      qty: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),

                // Unit price hint when qty > 1
                if (item.quantity > 1) ...[
                  const SizedBox(height: 3),
                  Text(
                    '${fmtYER(item.unitPrice, 'ar')} × ${item.quantity}',
                    style: const TextStyle(
                      fontFamily: TbFonts.arabic,
                      fontSize: 11,
                      color: TbColors.ink3,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // ── Remove button ───────────────────────────────────────────────
          const SizedBox(width: 8),
          _RemoveButton(onTap: onRemove),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product thumbnail
// ─────────────────────────────────────────────────────────────────────────────

class _ProductThumb extends StatelessWidget {
  final String? imageUrl;
  const _ProductThumb({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 78,
        height: 78,
        child: imageUrl != null
            ? CachedNetworkImage(
                imageUrl: imageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => const ColoredBox(
                  color: TbColors.line,
                ),
                errorWidget: (_, __, ___) => _ThumbPlaceholder(),
              )
            : _ThumbPlaceholder(),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: TbColors.bg,
      child: Center(
        child: Icon(
          Icons.child_care_rounded,
          color: TbColors.line,
          size: 32,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantity pill — ( − qty + )
// ─────────────────────────────────────────────────────────────────────────────

class _QtyPill extends StatelessWidget {
  final int qty;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QtyPill({
    required this.qty,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: TbColors.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TbColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement — becomes a trash icon at qty == 1
          _PillBtn(
            onTap: onDecrement,
            filled: false,
            child: qty == 1
                ? const Icon(Icons.delete_outline_rounded,
                    size: 14, color: TbColors.ink2)
                : const Icon(Icons.remove_rounded,
                    size: 14, color: TbColors.ink),
          ),

          // Count
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$qty',
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: TbColors.ink,
                ),
              ),
            ),
          ),

          // Increment
          _PillBtn(
            onTap: onIncrement,
            filled: true,
            child: const Icon(Icons.add_rounded,
                size: 14, color: TbColors.cream),
          ),
        ],
      ),
    );
  }
}

class _PillBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool filled;

  const _PillBtn({
    required this.child,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: filled ? TbColors.ink : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Center(child: child),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Remove button
// ─────────────────────────────────────────────────────────────────────────────

class _RemoveButton extends StatelessWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 18,
          color: TbColors.ink3,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order summary card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final CartState cart;
  const _SummaryCard({required this.cart});

  static const int shipping = 1500; // flat YER — single source of truth

  int get _total => cart.subtotal + shipping;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: TbColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TbColors.line),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'المجموع الفرعي',
            value: fmtYER(cart.subtotal, 'ar'),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'التوصيل',
            value: fmtYER(shipping, 'ar'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: TbColors.line, height: 1),
          ),
          _SummaryRow(
            label: 'الإجمالي',
            value: fmtYER(_total, 'ar'),
            bold: true,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontFamily: TbFonts.arabic,
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: bold ? TbColors.ink : TbColors.ink2,
    );
    final valueStyle = TextStyle(
      fontFamily: TbFonts.arabic,
      fontSize: bold ? 20 : 14,
      fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
      color: bold ? TbColors.ink : TbColors.ink,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle),
        Text(value, style: valueStyle),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout bar (sticky bottom)
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutBar extends StatelessWidget {
  /// Grand total already includes shipping — pass [CartState.subtotal] + shipping
  /// from [_SummaryCard._total].
  final int grandTotal;
  const _CheckoutBar({required this.grandTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TbColors.card,
        border: Border(top: BorderSide(color: TbColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: AppButton(
        label: 'إتمام الطلب · ${fmtYER(grandTotal, 'ar')}',
        variant: AppButtonVariant.accent,
        icon: const Icon(Icons.arrow_back_rounded, size: 18, color: Colors.white),
        onTap: () => context.go('/checkout'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clear-cart confirmation bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ClearConfirmSheet extends StatelessWidget {
  const _ClearConfirmSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TbColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TbColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TbColors.pink.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: TbColors.pink,
              size: 28,
            ),
          ),
          const SizedBox(height: 16),

          const Text(
            'إفراغ السلة؟',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: TbColors.ink,
            ),
          ),
          const SizedBox(height: 8),

          const Text(
            'سيتم حذف جميع المنتجات من سلتك. هذا الإجراء لا يمكن التراجع عنه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 14,
              color: TbColors.ink2,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              // Cancel
              Expanded(
                child: AppButton(
                  label: 'إلغاء',
                  variant: AppButtonVariant.ghost,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),

              // Confirm
              Expanded(
                child: AppButton(
                  label: 'إفراغ',
                  variant: AppButtonVariant.accent,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}