// lib/presentation/screens/shop/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/providers/products_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/theme.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  String? _selectedSize;
  int _qty = 1;
  bool _liked = false;
  bool _sizeError = false; // shows red hint when user taps Add without size

  static const _lang = 'ar';

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _hexToColor(String hex) {
    final h = hex.replaceFirst('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }

  int? _discountPct(Product p) {
    final old = p.oldPrice;
    if (old == null || old <= p.price) return null;
    return (((old - p.price) / old) * 100).round();
  }

  void _addToCart(Product p) {
    // ── Size validation ──────────────────────────────────────────────────
    if (_selectedSize == null) {
      setState(() => _sizeError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.info_outline_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text(
                'يرجى اختيار المقاس أولاً',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: TbColors.ink2,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // ── Add to cart ───────────────────────────────────────────────────────
    ref.read(cartProvider.notifier).add(p.id, _selectedSize!, qty: _qty);

    // ── Snackbar confirmation ─────────────────────────────────────────────
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'تمت الإضافة إلى السلة 🛍️',
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                context.go('/cart');
              },
              style: TextButton.styleFrom(foregroundColor: TbColors.yellow),
              child: const Text(
                'عرض السلة',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: TbColors.ink,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Reuse productsProvider family — find by id from cached list
    // Fallback: fetch all and find. For a real app you'd have a singleProductProvider.
    final productsAsync =
        ref.watch(productsProvider(const ProductFilter()));

    return productsAsync.when(
      loading: () => const Scaffold(
        backgroundColor: TbColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: TbColors.pink),
        ),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: TbColors.bg,
        appBar: AppBar(backgroundColor: TbColors.bg),
        body: Center(
          child: Text(e.toString(),
              style: const TextStyle(color: TbColors.ink2)),
        ),
      ),
      data: (products) {
        final product =
            products.where((p) => p.id == widget.productId).firstOrNull;

        if (product == null) {
          return Scaffold(
            backgroundColor: TbColors.bg,
            appBar: AppBar(backgroundColor: TbColors.bg),
            body: const Center(
              child: Text('المنتج غير موجود',
                  style: TextStyle(
                      fontFamily: TbFonts.arabic,
                      color: TbColors.ink2,
                      fontSize: 16)),
            ),
          );
        }

        return _ProductDetailView(
          product: product,
          lang: _lang,
          selectedSize: _selectedSize,
          qty: _qty,
          liked: _liked,
          sizeError: _sizeError,
          onSizeSelected: (s) =>
              setState(() { _selectedSize = s; _sizeError = false; }),
          onQtyChanged: (q) => setState(() => _qty = q),
          onLikeToggled: () => setState(() => _liked = !_liked),
          onAddToCart: () => _addToCart(product),
          hexToColor: _hexToColor,
          discountPct: _discountPct(product),
        );
      },
    );
  }
}

// ── Main view widget ──────────────────────────────────────────────────────────

class _ProductDetailView extends StatelessWidget {
  final Product product;
  final String lang;
  final String? selectedSize;
  final int qty;
  final bool liked;
  final bool sizeError;
  final ValueChanged<String> onSizeSelected;
  final ValueChanged<int> onQtyChanged;
  final VoidCallback onLikeToggled;
  final VoidCallback onAddToCart;
  final Color Function(String) hexToColor;
  final int? discountPct;

  const _ProductDetailView({
    required this.product,
    required this.lang,
    required this.selectedSize,
    required this.qty,
    required this.liked,
    required this.sizeError,
    required this.onSizeSelected,
    required this.onQtyChanged,
    required this.onLikeToggled,
    required this.onAddToCart,
    required this.hexToColor,
    required this.discountPct,
  });

  String get _name =>
      lang == 'ar' ? product.nameAr : product.nameEn;
  String get _desc =>
      lang == 'ar' ? product.descAr : product.descEn;
  String? get _tag =>
      lang == 'ar' ? product.tagAr : product.tagEn;

  @override
  Widget build(BuildContext context) {
    final bg = hexToColor(product.color);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: Column(
          children: [
            // ── Scrollable content ────────────────────────────────────────
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // ── Hero image area ─────────────────────────────────────
                  SliverToBoxAdapter(
                    child: Stack(
                      children: [
                        // Background
                        Container(
                          height: 360,
                          decoration: BoxDecoration(
                            color: bg.withOpacity(0.25),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32)),
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32)),
                            child: product.img != null
                                ? CachedNetworkImage(
                                    imageUrl: product.img!,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    placeholder: (_, __) =>
                                        Container(color: bg.withOpacity(0.25)),
                                    errorWidget: (_, __, ___) => Center(
                                      child: Icon(
                                        Icons.child_care_rounded,
                                        size: 80,
                                        color: bg.withOpacity(0.6),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.child_care_rounded,
                                      size: 80,
                                      color: bg.withOpacity(0.6),
                                    ),
                                  ),
                          ),
                        ),

                        // Back button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          right: 16,
                          child: _CircleBtn(
                            onTap: () => context.pop(),
                            child: const Icon(Icons.arrow_forward_ios_rounded,
                                size: 18, color: TbColors.ink),
                          ),
                        ),

                        // Like button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 8,
                          left: 16,
                          child: _CircleBtn(
                            onTap: onLikeToggled,
                            child: Icon(
                              liked
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              size: 20,
                              color: liked ? TbColors.pink : TbColors.ink,
                            ),
                          ),
                        ),

                        // Discount badge
                        if (discountPct != null)
                          Positioned(
                            bottom: 16,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: TbColors.pink,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '-$discountPct%',
                                style: const TextStyle(
                                  fontFamily: TbFonts.arabic,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── Content ─────────────────────────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Tag + rating row
                        Row(
                          children: [
                            if (_tag != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: TbColors.yellow,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  _tag!,
                                  style: const TextStyle(
                                    fontFamily: TbFonts.arabic,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: TbColors.ink,
                                    letterSpacing: 0.04,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            const Icon(Icons.star_rounded,
                                size: 16, color: TbColors.yellowDeep),
                            const SizedBox(width: 4),
                            const Text(
                              '4.6',
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: TbColors.ink,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              '(128)',
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 12,
                                color: TbColors.ink3,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Name
                        Text(
                          _name,
                          style: const TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: TbColors.ink,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Age + stock
                        Text(
                          'الفئة العمرية: ${product.age} سنة · متوفر: ${product.stock}',
                          style: const TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 13,
                            color: TbColors.ink3,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              fmtYER(product.price, lang),
                              style: const TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: TbColors.pink,
                              ),
                            ),
                            if (product.oldPrice != null) ...[
                              const SizedBox(width: 10),
                              Text(
                                fmtYER(product.oldPrice!, lang),
                                style: const TextStyle(
                                  fontFamily: TbFonts.arabic,
                                  fontSize: 16,
                                  color: TbColors.ink3,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Size selector ─────────────────────────────────
                        Row(
                          children: [
                            const Text(
                              'المقاس',
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: TbColors.ink2,
                                letterSpacing: 0.04,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'دليل المقاسات',
                              style: const TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: TbColors.pink,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Size chips with error highlight
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.sizes.map((s) {
                            final isSelected = selectedSize == s;
                            return GestureDetector(
                              onTap: () => onSizeSelected(s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 11),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? TbColors.ink
                                      : TbColors.card,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: sizeError && !isSelected
                                        ? TbColors.pink
                                        : isSelected
                                            ? TbColors.ink
                                            : TbColors.line,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  s,
                                  style: TextStyle(
                                    fontFamily: TbFonts.arabic,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: isSelected
                                        ? TbColors.cream
                                        : TbColors.ink,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        // Error hint text
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: sizeError
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.error_outline_rounded,
                                          size: 14, color: TbColors.pink),
                                      SizedBox(width: 6),
                                      Text(
                                        'يرجى اختيار المقاس قبل الإضافة',
                                        style: TextStyle(
                                          fontFamily: TbFonts.arabic,
                                          fontSize: 12,
                                          color: TbColors.pink,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),

                        const SizedBox(height: 22),

                        // ── Quantity stepper ──────────────────────────────
                        Row(
                          children: [
                            const Text(
                              'الكمية',
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: TbColors.ink2,
                              ),
                            ),
                            const Spacer(),
                            _QtyStepper(
                              qty: qty,
                              max: product.stock,
                              onChanged: onQtyChanged,
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ── Description ───────────────────────────────────
                        const Text(
                          'الوصف',
                          style: TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: TbColors.ink2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _desc,
                          style: const TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 14,
                            color: TbColors.ink2,
                            height: 1.65,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // ── Delivery info ─────────────────────────────────
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: TbColors.mintSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.local_shipping_outlined,
                                  size: 22, color: TbColors.ink),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'توصيل لجميع مدن اليمن',
                                    style: TextStyle(
                                      fontFamily: TbFonts.arabic,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: TbColors.ink,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '٢-٤ أيام عمل',
                                    style: TextStyle(
                                      fontFamily: TbFonts.arabic,
                                      fontSize: 12,
                                      color: TbColors.ink2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),

            // ── Sticky bottom bar ────────────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: TbColors.card,
                border:
                    Border(top: BorderSide(color: TbColors.line)),
              ),
              padding: EdgeInsets.fromLTRB(
                18,
                12,
                18,
                12 + MediaQuery.of(context).padding.bottom,
              ),
              child: Row(
                children: [
                  // Total price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'الإجمالي',
                        style: TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 11,
                          color: TbColors.ink3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        fmtYER(product.price * qty, lang),
                        style: const TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: TbColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Add to cart button
                  Expanded(
                    child: AppButton(
                      label: 'أضف إلى السلة',
                      onTap: onAddToCart,
                      icon: const Icon(
                        Icons.shopping_bag_outlined,
                        size: 18,
                        color: TbColors.cream,
                      ),
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────────────────────

class _CircleBtn extends StatelessWidget {
  final VoidCallback onTap;
  final Widget child;
  const _CircleBtn({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _QtyStepper extends StatelessWidget {
  final int qty;
  final int max;
  final ValueChanged<int> onChanged;
  const _QtyStepper(
      {required this.qty, required this.max, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TbColors.card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: TbColors.line),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Minus
          _StepBtn(
            icon: Icons.remove_rounded,
            active: qty > 1,
            onTap: () { if (qty > 1) onChanged(qty - 1); },
            filled: false,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$qty',
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: TbColors.ink,
              ),
            ),
          ),
          // Plus
          _StepBtn(
            icon: Icons.add_rounded,
            active: qty < max,
            onTap: () { if (qty < max) onChanged(qty + 1); },
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool filled;
  final VoidCallback onTap;
  const _StepBtn(
      {required this.icon,
      required this.active,
      required this.filled,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled
              ? (active ? TbColors.ink : TbColors.line)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled
              ? (active ? TbColors.cream : TbColors.ink3)
              : (active ? TbColors.ink : TbColors.ink3),
        ),
      ),
    );
  }
}