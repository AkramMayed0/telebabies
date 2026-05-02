// lib/presentation/screens/cart/cart_screen.dart
// REPLACE: my_app/lib/presentation/screens/cart/cart_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/providers/promo_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Cart Screen root
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
        body: cart.isEmpty ? const _EmptyCart() : const _CartBody(),
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
          const _CartHeader(itemCount: 0),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
// Cart body — owns TextEditingController + all interaction logic
// ─────────────────────────────────────────────────────────────────────────────

class _CartBody extends ConsumerStatefulWidget {
  const _CartBody();

  @override
  ConsumerState<_CartBody> createState() => _CartBodyState();
}

class _CartBodyState extends ConsumerState<_CartBody> {
  final _promoController = TextEditingController();

  // Flat shipping — single source of truth shared with summary + checkout bar
  static const int _shipping = 1500;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  // ── Totals ────────────────────────────────────────────────────────────────

  int _grandTotal(int subtotal, int discount) =>
      (subtotal - discount + _shipping).clamp(0, 999999999);

  // ── Promo actions ─────────────────────────────────────────────────────────

  void _applyPromo(int subtotal) {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;
    FocusScope.of(context).unfocus();
    ref.read(promoProvider.notifier).apply(code: code, subtotal: subtotal);
  }

  void _removePromo() {
    _promoController.clear();
    ref.read(promoProvider.notifier).clear();
  }

  // ── Re-validate promo when cart changes ───────────────────────────────────

  void _revalidatePromo(PromoState promo, int newSubtotal) {
    if (!promo.isApplied) return;
    if (newSubtotal == 0) {
      _removePromo();
    } else {
      ref.read(promoProvider.notifier).apply(
            code: promo.result!.code,
            subtotal: newSubtotal,
          );
    }
  }

  // ── Clear cart ────────────────────────────────────────────────────────────

  void _confirmClear() {
    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ClearConfirmSheet(),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        ref.read(cartProvider.notifier).clearCart();
        _removePromo();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart  = ref.watch(cartProvider);
    final promo = ref.watch(promoProvider);

    final discount   = promo.discountAmount;
    final grandTotal = _grandTotal(cart.subtotal, discount);

    return SafeArea(
      child: Column(
        children: [
          // ── Header ─────────────────────────────────────────────────────
          _CartHeader(itemCount: cart.items.length),

          // ── Scrollable content ──────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                // Item tiles
                ...cart.items.map(
                  (item) => _CartItemTile(
                    key: ValueKey('${item.productId}_${item.size}'),
                    item: item,
                    onIncrement: () {
                      ref.read(cartProvider.notifier).updateQuantity(
                          item.productId, item.size, item.quantity + 1);
                      _revalidatePromo(
                          promo, ref.read(cartProvider).subtotal);
                    },
                    onDecrement: () {
                      ref.read(cartProvider.notifier).updateQuantity(
                          item.productId, item.size, item.quantity - 1);
                      _revalidatePromo(
                          promo, ref.read(cartProvider).subtotal);
                    },
                    onRemove: () {
                      ref.read(cartProvider.notifier)
                          .removeItem(item.productId, item.size);
                      _revalidatePromo(
                          promo, ref.read(cartProvider).subtotal);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // ── Promo code field ──────────────────────────────────
                _PromoField(
                  controller: _promoController,
                  promo: promo,
                  onApply: () => _applyPromo(cart.subtotal),
                  onRemove: _removePromo,
                ),

                const SizedBox(height: 16),

                // ── Order summary ─────────────────────────────────────
                _SummaryCard(
                  subtotal: cart.subtotal,
                  shipping: _shipping,
                  discount: discount,
                  promoCode: promo.result?.code,
                ),

                const SizedBox(height: 12),

                // Clear cart link
                Center(
                  child: GestureDetector(
                    onTap: _confirmClear,
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
          _CheckoutBar(grandTotal: grandTotal),
        ],
      ),
    );
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
// Promo code field
// ─────────────────────────────────────────────────────────────────────────────

class _PromoField extends StatelessWidget {
  final TextEditingController controller;
  final PromoState promo;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  const _PromoField({
    required this.controller,
    required this.promo,
    required this.onApply,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    // ── Applied: show green success chip instead of input ─────────────────
    if (promo.isApplied) {
      return _AppliedPromoChip(
        result: promo.result!,
        onRemove: onRemove,
      );
    }

    final hasError = promo.hasError;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Input row
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: TbColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasError ? TbColors.pink : TbColors.line,
              width: hasError ? 1.5 : 1.0,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
          child: Row(
            children: [
              // Icon
              Icon(
                Icons.sell_outlined,
                size: 18,
                color: hasError ? TbColors.pink : TbColors.ink3,
              ),
              const SizedBox(width: 10),

              // Text input — LTR because codes are ASCII uppercase
              Expanded(
                child: TextField(
                  controller: controller,
                  textDirection: TextDirection.ltr,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TbColors.ink,
                    letterSpacing: 0.06,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'كود الخصم',
                    hintStyle: TextStyle(
                      fontFamily: TbFonts.arabic,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: TbColors.ink3,
                      letterSpacing: 0,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
                  ),
                  onSubmitted: (_) => onApply(),
                ),
              ),

              // Apply button
              _ApplyBtn(
                loading: promo.isLoading,
                onTap: onApply,
              ),
            ],
          ),
        ),

        // Error message — animates in/out
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: 8, right: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 14,
                          color: TbColors.pink,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          promo.errorMessage!,
                          style: const TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: TbColors.pink,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Applied promo chip
// ─────────────────────────────────────────────────────────────────────────────

class _AppliedPromoChip extends StatelessWidget {
  final PromoResult result;
  final VoidCallback onRemove;

  const _AppliedPromoChip({
    required this.result,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TbColors.mintSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TbColors.mint.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          // Check circle
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: TbColors.mint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: TbColors.ink,
            ),
          ),
          const SizedBox(width: 12),

          // Code + savings text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  result.code,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: TbColors.ink,
                    letterSpacing: 0.06,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'وفّرت ${fmtYER(result.discount, 'ar')} 🎉',
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: TbColors.ink2,
                  ),
                ),
              ],
            ),
          ),

          // Remove ×
          GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: TbColors.mint.withOpacity(0.22),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 14,
                color: TbColors.ink2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inline Apply button
// ─────────────────────────────────────────────────────────────────────────────

class _ApplyBtn extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _ApplyBtn({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: loading ? TbColors.line : TbColors.ink,
          borderRadius: BorderRadius.circular(10),
        ),
        child: loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(TbColors.ink3),
                ),
              )
            : const Text(
                'تطبيق',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TbColors.cream,
                ),
              ),
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
          _ProductThumb(imageUrl: item.imageUrl),
          const SizedBox(width: 12),
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
                const SizedBox(height: 8),

                // Price + stepper
                Row(
                  children: [
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
                    _QtyPill(
                      qty: item.quantity,
                      onDecrement: onDecrement,
                      onIncrement: onIncrement,
                    ),
                  ],
                ),

                // Unit price hint
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
                placeholder: (_, __) =>
                    const ColoredBox(color: TbColors.line),
                errorWidget: (_, __, ___) => const _ThumbPlaceholder(),
              )
            : const _ThumbPlaceholder(),
      ),
    );
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: TbColors.bg,
      child: Center(
        child:
            Icon(Icons.child_care_rounded, color: TbColors.line, size: 32),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantity pill  ( − qty + )
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
          _PillBtn(
            onTap: onDecrement,
            filled: false,
            child: qty == 1
                ? const Icon(Icons.delete_outline_rounded,
                    size: 14, color: TbColors.ink2)
                : const Icon(Icons.remove_rounded,
                    size: 14, color: TbColors.ink),
          ),
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

  const _PillBtn(
      {required this.child,
      required this.onTap,
      required this.filled});

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
      child: const SizedBox(
        width: 32,
        height: 32,
        child: Icon(Icons.close_rounded, size: 18, color: TbColors.ink3),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order summary card
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final int subtotal;
  final int shipping;
  final int discount;
  final String? promoCode;

  const _SummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.discount,
    this.promoCode,
  });

  int get _total =>
      (subtotal - discount + shipping).clamp(0, 999999999);

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
            value: fmtYER(subtotal, 'ar'),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: 'التوصيل',
            value: fmtYER(shipping, 'ar'),
          ),

          // Discount row — visible only when promo is applied
          if (discount > 0) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              label: promoCode != null ? 'خصم ($promoCode)' : 'الخصم',
              value: '- ${fmtYER(discount, 'ar')}',
              valueColor: TbColors.mint,
            ),
          ],

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
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? TbColors.ink : TbColors.ink2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: bold ? 20 : 14,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? TbColors.ink,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Checkout bar (sticky)
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutBar extends StatelessWidget {
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
        16, 12, 16,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: AppButton(
        label: 'إتمام الطلب · ${fmtYER(grandTotal, 'ar')}',
        variant: AppButtonVariant.accent,
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 18,
          color: Colors.white,
        ),
        onTap: () => context.go('/checkout'),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Clear-cart confirmation sheet
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
          24, 24, 24, 24 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: TbColors.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TbColors.pink.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.delete_outline_rounded,
                color: TbColors.pink, size: 28),
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
            'سيتم حذف جميع المنتجات من سلتك.\nهذا الإجراء لا يمكن التراجع عنه.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 14,
              color: TbColors.ink2,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'إلغاء',
                  variant: AppButtonVariant.ghost,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
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