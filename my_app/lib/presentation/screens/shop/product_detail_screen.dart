// lib/presentation/screens/shop/product_detail_screen.dart
// REPLACE: my_app/lib/presentation/screens/shop/product_detail_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/providers/products_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/presentation/widgets/common/stars.dart';
import 'package:my_app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Entry point
// ─────────────────────────────────────────────────────────────────────────────

class ProductDetailScreen extends ConsumerWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Reuse the same products family provider with an empty filter and find the product.
    // In production you'd have a dedicated single-product provider; this keeps it simple.
    final productsAsync =
        ref.watch(productsProvider(const ProductFilter()));

    return productsAsync.when(
      loading: () => const _LoadingScaffold(),
      error: (e, _) => _ErrorScaffold(message: e.toString()),
      data: (products) {
        final product =
            products.firstWhere((p) => p.id == productId, orElse: () => products.first);
        return _ProductDetailView(product: product);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main view
// ─────────────────────────────────────────────────────────────────────────────

class _ProductDetailView extends ConsumerStatefulWidget {
  final Product product;
  const _ProductDetailView({required this.product});

  @override
  ConsumerState<_ProductDetailView> createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends ConsumerState<_ProductDetailView>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();

  // Shake animation key for the size selector when validation fails
  final GlobalKey _sizeSectionKey = GlobalKey();

  int _currentPage = 0;
  String? _selectedSize;
  int _qty = 1;
  bool _liked = false;
  bool _descExpanded = false;

  // Validation
  bool _sizeError = false;   // true when user taps Add without picking a size

  // Loading state for the AppButton
  bool _addingToCart = false;

  // Shake animation controller
  late final AnimationController _shakeAnim;
  late final Animation<double> _shakeOffset;

  @override
  void initState() {
    super.initState();
    // Do NOT pre-select a size — user must make a deliberate choice.
    // (Pre-selection masked the validation requirement in the previous version.)

    _shakeAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Oscillates left/right: 0 → −8 → +8 → −6 → +6 → 0
    _shakeOffset = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: -6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -6, end: 6), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeAnim, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shakeAnim.dispose();
    super.dispose();
  }

  // ── Computed helpers ──────────────────────────────────────────────────────

  Color get _accentBg {
    final hex = widget.product.color.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  int? get _discountPct {
    final old = widget.product.oldPrice;
    if (old == null || old <= widget.product.price) return null;
    return (((old - widget.product.price) / old) * 100).round();
  }

  // ── Image list — in real app multiple images come from the API.
  //    For now we show the single image repeated to demonstrate PageView.
  List<String?> get _images {
    return [
      widget.product.img,
      widget.product.img,
      widget.product.img,
    ];
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  /// Validates size then adds to cart. Fires async work via unawaited call
  /// so it matches VoidCallback for AppButton.onTap.
  void _addToCart() {
    _doAddToCart();
  }

  Future<void> _doAddToCart() async {
    // ── Validation: size must be selected ──────────────────────────────────
    if (_selectedSize == null) {
      setState(() => _sizeError = true);

      // Shake the size section to draw attention
      await _shakeAnim.forward(from: 0);

      // Scroll to size section so it's visible
      final ctx = _sizeSectionKey.currentContext;
      if (ctx != null) {
        await Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          alignment: 0.3,
        );
      }
      return;
    }

    // ── Add to cart ────────────────────────────────────────────────────────
    setState(() => _addingToCart = true);

    // Brief delay so loading spinner is visible (pure UX polish).
    await Future.delayed(const Duration(milliseconds: 350));

    ref.read(cartProvider.notifier).add(
          widget.product.id,
          _selectedSize!,
          qty: _qty,
        );

    setState(() => _addingToCart = false);

    if (!mounted) return;

    // ── Snackbar confirmation ──────────────────────────────────────────────
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: TbColors.mint,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: TbColors.ink,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تمت الإضافة إلى السلة',
                      style: TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: TbColors.cream,
                      ),
                    ),
                    Text(
                      'المقاس $_selectedSize · ${_qty > 1 ? '$_qty قطع' : 'قطعة واحدة'}',
                      style: const TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 12,
                        color: TbColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: TbColors.ink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'عرض السلة',
            textColor: TbColors.yellow,
            onPressed: () => context.go('/cart'),
          ),
        ),
      );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cartCount = ref.watch(cartProvider).count;
    final totalLinePrice = p.price * _qty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: Stack(
          children: [
            // ── Scrollable content ───────────────────────────────────────
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Image gallery ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _ImageGallery(
                    images: _images,
                    accentBg: _accentBg,
                    pageController: _pageController,
                    currentPage: _currentPage,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    liked: _liked,
                    onLikeToggle: () => setState(() => _liked = !_liked),
                    onBack: () => context.pop(),
                    cartCount: cartCount,
                    tagAr: p.tagAr,
                    discountPct: _discountPct,
                  ),
                ),

                // ── Product info card ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: TbColors.bg,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                    transform: Matrix4.translationValues(0, -24, 0),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Tag + rating row
                          Row(
                            children: [
                              if (p.tagAr != null)
                                _Tag(label: p.tagAr!),
                              const Spacer(),
                              const Stars(value: 4.6, count: 128),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Name
                          Text(
                            p.nameAr,
                            style: const TextStyle(
                              fontFamily: TbFonts.arabic,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: TbColors.ink,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Sub-info
                          Text(
                            'الفئة العمرية: ${p.age} سنة · متوفر: ${p.stock} قطعة',
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
                                fmtYER(p.price, 'ar'),
                                style: const TextStyle(
                                  fontFamily: TbFonts.arabic,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: TbColors.pink,
                                ),
                              ),
                              if (p.oldPrice != null) ...[
                                const SizedBox(width: 10),
                                Text(
                                  fmtYER(p.oldPrice!, 'ar'),
                                  style: const TextStyle(
                                    fontFamily: TbFonts.arabic,
                                    fontSize: 15,
                                    color: TbColors.ink3,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                if (_discountPct != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: TbColors.pink,
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      '-${_discountPct}%',
                                      style: const TextStyle(
                                        fontFamily: TbFonts.arabic,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),

                          const SizedBox(height: 24),
                          const _Divider(),
                          const SizedBox(height: 20),

                          // Size selector (with shake + error state)
                          AnimatedBuilder(
                            animation: _shakeOffset,
                            builder: (context, child) => Transform.translate(
                              offset: Offset(_shakeOffset.value, 0),
                              child: child,
                            ),
                            child: _SizeSelector(
                              key: _sizeSectionKey,
                              sizes: p.sizes,
                              selected: _selectedSize,
                              hasError: _sizeError,
                              onSelect: (s) => setState(() {
                                _selectedSize = s;
                                _sizeError = false; // clear error on pick
                              }),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const _Divider(),
                          const SizedBox(height: 20),

                          // Quantity stepper
                          _QuantityStepper(
                            qty: _qty,
                            maxStock: p.stock,
                            onDecrement: () {
                              if (_qty > 1) setState(() => _qty--);
                            },
                            onIncrement: () {
                              if (_qty < p.stock) setState(() => _qty++);
                            },
                          ),

                          const SizedBox(height: 20),
                          const _Divider(),
                          const SizedBox(height: 20),

                          // Description
                          _Description(
                            text: p.descAr,
                            expanded: _descExpanded,
                            onToggle: () =>
                                setState(() => _descExpanded = !_descExpanded),
                          ),

                          const SizedBox(height: 20),

                          // Delivery banner
                          _DeliveryBadge(),

                          // Bottom padding so FAB doesn't cover content
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Sticky bottom bar ────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomBar(
                totalPrice: totalLinePrice,
                selectedSize: _selectedSize,
                loading: _addingToCart,
                // Null during loading prevents double-tap; _addToCart handles
                // the no-size case internally via validation + shake.
                onAddToCart: _addingToCart ? null : _addToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Image Gallery
// ─────────────────────────────────────────────────────────────────────────────

class _ImageGallery extends StatelessWidget {
  final List<String?> images;
  final Color accentBg;
  final PageController pageController;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final bool liked;
  final VoidCallback onLikeToggle;
  final VoidCallback onBack;
  final int cartCount;
  final String? tagAr;
  final int? discountPct;

  const _ImageGallery({
    required this.images,
    required this.accentBg,
    required this.pageController,
    required this.currentPage,
    required this.onPageChanged,
    required this.liked,
    required this.onLikeToggle,
    required this.onBack,
    required this.cartCount,
    this.tagAr,
    this.discountPct,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final galleryH = screenW * 1.1; // ~16:17 ish

    return SizedBox(
      height: galleryH,
      child: Stack(
        children: [
          // Background colour
          Positioned.fill(
            child: Container(color: accentBg.withOpacity(0.3)),
          ),

          // PageView of images
          PageView.builder(
            controller: pageController,
            onPageChanged: onPageChanged,
            itemCount: images.length,
            itemBuilder: (_, i) {
              final url = images[i];
              if (url == null) {
                return Center(
                  child: Icon(Icons.child_care_rounded,
                      size: 64, color: accentBg.withOpacity(0.6)),
                );
              }
              return CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                placeholder: (_, __) =>
                    Container(color: accentBg.withOpacity(0.3)),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.child_care_rounded,
                      size: 64, color: accentBg.withOpacity(0.6)),
                ),
              );
            },
          ),

          // Gradient overlay (bottom fade into bg)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    TbColors.bg.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Top controls — back + cart
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 14,
            right: 14,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CircleBtn(
                  onTap: onBack,
                  child: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 18, color: TbColors.ink),
                ),
                Row(
                  children: [
                    // Cart with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _CircleBtn(
                          onTap: () => Navigator.of(context)
                              .pushNamed('/cart')
                              .catchError((_) {}),
                          child: const Icon(Icons.shopping_bag_outlined,
                              size: 20, color: TbColors.ink),
                        ),
                        if (cartCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: TbColors.pink,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  '$cartCount',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    height: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Like button
                    _CircleBtn(
                      onTap: onLikeToggle,
                      child: Icon(
                        liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: liked ? TbColors.pink : TbColors.ink,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Badges — tag (top left) + discount (top left below)
          if (tagAr != null)
            Positioned(
              bottom: 36,
              right: 18,
              child: _Tag(label: tagAr!),
            ),
          if (discountPct != null)
            Positioned(
              bottom: discountPct != null && tagAr != null ? 68 : 36,
              right: 18,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: TbColors.pink,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '-$discountPct%',
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Page indicator dots
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(images.length, (i) {
                final active = i == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 22 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? TbColors.ink : TbColors.ink3.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Size Selector
// ─────────────────────────────────────────────────────────────────────────────

class _SizeSelector extends StatelessWidget {
  final List<String> sizes;
  final String? selected;
  final bool hasError;
  final ValueChanged<String> onSelect;

  const _SizeSelector({
    super.key,
    required this.sizes,
    required this.selected,
    required this.hasError,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Text(
                  'المقاس',
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: TbColors.ink2,
                    letterSpacing: 0.04,
                  ),
                ),
                // Inline validation hint
                if (hasError) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: TbColors.pink.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: TbColors.pink.withOpacity(0.4), width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.error_outline_rounded,
                            size: 12, color: TbColors.pink),
                        SizedBox(width: 4),
                        Text(
                          'اختر مقاساً',
                          style: TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: TbColors.pink,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            GestureDetector(
              onTap: () {}, // size guide placeholder
              child: const Text(
                'دليل المقاسات',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TbColors.pink,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: sizes.map((s) {
            final active = selected == s;
            return GestureDetector(
              onTap: () => onSelect(s),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                constraints: const BoxConstraints(minWidth: 56),
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: active ? TbColors.ink : TbColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    // Error state: non-selected chips get a pink border
                    color: active
                        ? TbColors.ink
                        : hasError
                            ? TbColors.pink.withOpacity(0.5)
                            : TbColors.line,
                    width: active ? 1.5 : (hasError ? 1.5 : 1.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    s,
                    style: TextStyle(
                      fontFamily: TbFonts.arabic,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: active ? TbColors.cream : TbColors.ink,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quantity Stepper
// ─────────────────────────────────────────────────────────────────────────────

class _QuantityStepper extends StatelessWidget {
  final int qty;
  final int maxStock;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const _QuantityStepper({
    required this.qty,
    required this.maxStock,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'الكمية',
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TbColors.ink2,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: TbColors.card,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: TbColors.line),
          ),
          child: Row(
            children: [
              _StepBtn(
                icon: Icons.remove_rounded,
                onTap: onDecrement,
                filled: false,
              ),
              SizedBox(
                width: 36,
                child: Center(
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
              ),
              _StepBtn(
                icon: Icons.add_rounded,
                onTap: onIncrement,
                filled: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  const _StepBtn(
      {required this.icon, required this.onTap, required this.filled});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: filled ? TbColors.ink : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 18,
          color: filled ? TbColors.cream : TbColors.ink,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Description
// ─────────────────────────────────────────────────────────────────────────────

class _Description extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _Description({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الوصف',
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: TbColors.ink2,
            letterSpacing: 0.04,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedCrossFade(
          firstChild: Text(
            text,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 14,
              color: TbColors.ink2,
              height: 1.65,
            ),
          ),
          secondChild: Text(
            text,
            style: const TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 14,
              color: TbColors.ink2,
              height: 1.65,
            ),
          ),
          crossFadeState:
              expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 220),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onToggle,
          child: Text(
            expanded ? 'عرض أقل' : 'عرض المزيد',
            style: const TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: TbColors.pink,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Delivery Banner
// ─────────────────────────────────────────────────────────────────────────────

class _DeliveryBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: TbColors.mintSoft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping_outlined,
              size: 22, color: TbColors.ink),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom Bar (sticky)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final int totalPrice;
  final String? selectedSize;
  final bool loading;
  // VoidCallback to match AppButton's onTap type — the async work
  // is handled inside _addToCart in the parent state.
  final VoidCallback? onAddToCart;

  const _BottomBar({
    required this.totalPrice,
    required this.selectedSize,
    required this.loading,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TbColors.card,
        border: Border(top: BorderSide(color: TbColors.line)),
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── Total price block ──────────────────────────────────────
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                fmtYER(totalPrice, 'ar'),
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: TbColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),

          // ── AppButton — always tappable; validation runs inside handler ─
          Expanded(
            child: AppButton(
              label: selectedSize == null
                  ? 'اختر مقاساً أولاً'
                  : 'أضف إلى السلة',
              loading: loading,
              onTap: onAddToCart,
              variant: selectedSize == null
                  ? AppButtonVariant.ghost
                  : AppButtonVariant.primary,
              icon: selectedSize == null
                  ? const Icon(Icons.straighten_rounded,
                      size: 18, color: TbColors.ink)
                  : const Icon(Icons.shopping_bag_outlined,
                      size: 18, color: TbColors.cream),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Tag extends StatelessWidget {
  final String label;
  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TbColors.yellow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: TbFonts.arabic,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: TbColors.ink,
          letterSpacing: 0.04,
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _CircleBtn({required this.child, required this.onTap});

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
          boxShadow: [
            BoxShadow(
              color: TbColors.ink.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      color: TbColors.line,
      thickness: 1,
      height: 1,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading / Error scaffolds
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingScaffold extends StatelessWidget {
  const _LoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: TbColors.bg,
      body: Center(
        child: CircularProgressIndicator(color: TbColors.pink, strokeWidth: 2.5),
      ),
    );
  }
}

class _ErrorScaffold extends StatelessWidget {
  final String message;
  const _ErrorScaffold({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TbColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_rounded,
                  size: 56, color: TbColors.line),
              const SizedBox(height: 12),
              Text(message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: TbFonts.arabic,
                      fontSize: 14,
                      color: TbColors.ink2)),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: TbColors.pink,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text('رجوع',
                      style: TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}