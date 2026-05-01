// lib/presentation/screens/home/home_screen.dart
// REPLACE existing file

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/product.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/providers/products_provider.dart';
import 'package:my_app/theme.dart';
import 'package:my_app/presentation/widgets/common/product_card.dart';

// ── Filter chip data ──────────────────────────────────────────────────────────

class _Chip {
  final String id;
  final String label;
  const _Chip(this.id, this.label);
}

const _ageChips = [
  _Chip('0-2',  '٠-٢ سنة'),
  _Chip('2-4',  '٢-٤ سنة'),
  _Chip('4-6',  '٤-٦ سنة'),
  _Chip('6-10', '٦-١٠ سنة'),
];

const _genderChips = [
  _Chip('girls',  'بنات'),
  _Chip('boys',   'أولاد'),
  _Chip('unisex', 'للجنسين'),
];

const _typeChips = [
  _Chip('dress',   'فساتين'),
  _Chip('tshirt',  'تيشرتات'),
  _Chip('jacket',  'جواكت'),
  _Chip('pajama',  'بيجامات'),
  _Chip('shoes',   'أحذية'),
  _Chip('overall', 'بدلات'),
  _Chip('hat',     'قبعات'),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  // Active filter state — changes here rebuild the provider key
  String _searchQuery = '';
  String? _ageFilter;
  String? _genderFilter;
  String? _typeFilter;

  ProductFilter get _currentFilter => ProductFilter(
        search: _searchQuery.isEmpty ? null : _searchQuery,
        age:    _ageFilter,
        cat:    _genderFilter,
        type:   _typeFilter,
      );

  bool get _hasActiveFilter =>
      _ageFilter != null || _genderFilter != null || _typeFilter != null;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    // 400ms debounce so we don't fire on every keystroke
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _searchQuery = value.trim());
    });
  }

  void _toggleAge(String id) =>
      setState(() => _ageFilter = _ageFilter == id ? null : id);

  void _toggleGender(String id) =>
      setState(() => _genderFilter = _genderFilter == id ? null : id);

  void _toggleType(String id) =>
      setState(() => _typeFilter = _typeFilter == id ? null : id);

  void _clearFilters() => setState(() {
        _ageFilter = _genderFilter = _typeFilter = null;
        _searchController.clear();
        _searchQuery = '';
      });

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cartCount     = ref.watch(cartProvider).count;
    final productsAsync = ref.watch(productsProvider(_currentFilter));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: SafeArea(
          child: RefreshIndicator(
            color: TbColors.pink,
            onRefresh: () =>
                ref.read(productsProvider(_currentFilter).notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── App bar ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: _AppBar(cartCount: cartCount),
                ),

                // ── Search bar ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: _SearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                    ),
                  ),
                ),

                // ── Filter chips ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      _ChipRow(
                        label: 'العمر',
                        chips: _ageChips,
                        selected: _ageFilter,
                        onTap: _toggleAge,
                      ),
                      const SizedBox(height: 8),
                      _ChipRow(
                        label: 'الفئة',
                        chips: _genderChips,
                        selected: _genderFilter,
                        onTap: _toggleGender,
                      ),
                      const SizedBox(height: 8),
                      _ChipRow(
                        label: 'النوع',
                        chips: _typeChips,
                        selected: _typeFilter,
                        onTap: _toggleType,
                      ),
                      if (_hasActiveFilter)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: GestureDetector(
                            onTap: _clearFilters,
                            child: const Text(
                              'مسح الفلاتر',
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 12,
                                color: TbColors.pink,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ── Section header ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        const Text(
                          'وصل حديثاً',
                          style: TextStyle(
                            fontFamily: TbFonts.arabic,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: TbColors.ink,
                          ),
                        ),
                        const Spacer(),
                        // Show count only when data is ready
                        productsAsync.whenOrNull(
                          data: (products) => Text(
                            '${products.length} منتج',
                            style: const TextStyle(
                              fontFamily: TbFonts.arabic,
                              fontSize: 12,
                              color: TbColors.ink3,
                            ),
                          ),
                        ) ?? const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),

                // ── Content: loading / error / data / empty ────────────
                productsAsync.when(
                  loading: () => const _ShimmerGrid(),
                  error: (err, _) => SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorState(
                      message: err.toString(),
                      onRetry: () => ref
                          .read(productsProvider(_currentFilter).notifier)
                          .refresh(),
                    ),
                  ),
                  data: (products) => products.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(onClear: _clearFilters),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                          sliver: SliverGrid(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (_, i) => ProductCard(product: products[i], lang: 'ar'),
                              childCount: products.length,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final int cartCount;
  const _AppBar({required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Wordmark
          RichText(
            textDirection: TextDirection.rtl,
            text: const TextSpan(
              children: [
                TextSpan(
                  text: 'تيلي',
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TbColors.ink,
                    height: 1,
                  ),
                ),
                TextSpan(
                  text: 'بيبيز',
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: TbColors.pink,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          // Cart icon with badge
          GestureDetector(
            onTap: () => context.go('/cart'),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: TbColors.card,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: TbColors.line),
                  ),
                  child: const Icon(
                    Icons.shopping_bag_outlined,
                    color: TbColors.ink,
                    size: 22,
                  ),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      height: 18,
                      constraints: const BoxConstraints(minWidth: 18),
                      decoration: BoxDecoration(
                        color: TbColors.pink,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: TbColors.bg, width: 2),
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
          ),
        ],
      ),
    );
  }
}

// ── Search bar ────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchBar({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textDirection: TextDirection.rtl,
      style: const TextStyle(
        fontFamily: TbFonts.arabic,
        fontSize: 14,
        color: TbColors.ink,
      ),
      decoration: InputDecoration(
        hintText: 'ابحث عن ملابس الأطفال...',
        hintStyle: const TextStyle(
          fontFamily: TbFonts.arabic,
          color: TbColors.ink3,
          fontSize: 14,
        ),
        prefixIcon:
            const Icon(Icons.search_rounded, color: TbColors.ink3, size: 20),
        suffixIcon: controller.text.isNotEmpty
            ? GestureDetector(
                onTap: () {
                  controller.clear();
                  onChanged('');
                },
                child: const Icon(Icons.close_rounded,
                    color: TbColors.ink3, size: 18),
              )
            : null,
        filled: true,
        fillColor: TbColors.card,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TbColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TbColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: TbColors.ink, width: 1.5),
        ),
      ),
    );
  }
}

// ── Filter chip row ───────────────────────────────────────────────────────────

class _ChipRow extends StatelessWidget {
  final String label;
  final List<_Chip> chips;
  final String? selected;
  final ValueChanged<String> onTap;

  const _ChipRow({
    required this.label,
    required this.chips,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Text(
                '$label:',
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: TbColors.ink2,
                ),
              ),
            ),
          ),
          ...chips.map((c) {
            final active = selected == c.id;
            return GestureDetector(
              onTap: () => onTap(c.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                margin: const EdgeInsets.only(left: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: active ? TbColors.ink : TbColors.card,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? TbColors.ink : TbColors.line,
                  ),
                ),
                child: Text(
                  c.label,
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: active ? TbColors.cream : TbColors.ink2,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Shimmer grid (loading state) ──────────────────────────────────────────────

class _ShimmerGrid extends StatefulWidget {
  const _ShimmerGrid();

  @override
  State<_ShimmerGrid> createState() => _ShimmerGridState();
}

class _ShimmerGridState extends State<_ShimmerGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, __) => AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment(-1.0 + _ctrl.value * 2, 0),
                    end: Alignment(1.0 + _ctrl.value * 2, 0),
                    colors: const [
                      Color(0xFFEDE8DC),
                      Color(0xFFF5F1E8),
                      Color(0xFFEDE8DC),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image placeholder
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFE8E3D5),
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(15)),
                        ),
                      ),
                    ),
                    // Text placeholders
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 12,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: TbColors.line,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            height: 12,
                            width: 80,
                            decoration: BoxDecoration(
                              color: TbColors.line,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          childCount: 6, // 6 placeholder cards
        ),
      ),
    );
  }
}



// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onClear;
  const _EmptyState({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, size: 56, color: TbColors.line),
          const SizedBox(height: 12),
          const Text(
            'لا توجد منتجات مطابقة',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: TbColors.ink2,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'جرب تغيير الفلاتر أو كلمة البحث',
            style: TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 13,
              color: TbColors.ink3,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onClear,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: TbColors.ink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'مسح الفلاتر',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TbColors.cream,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Error state ───────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off_rounded, size: 56, color: TbColors.line),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 14,
              color: TbColors.ink2,
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: TbColors.pink,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}