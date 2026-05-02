// lib/presentation/screens/checkout/checkout_screen.dart
// REPLACE: my_app/lib/presentation/screens/checkout/checkout_screen.dart

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/utils/format.dart';
import 'package:my_app/models/cart_item.dart';
import 'package:my_app/presentation/providers/cart_provider.dart';
import 'package:my_app/presentation/providers/promo_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/presentation/widgets/common/AppTextField.dart';
import 'package:my_app/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Constants — Yemen cities & payment methods
// ─────────────────────────────────────────────────────────────────────────────

class _YemenCity {
  final String ar;
  final String en;
  const _YemenCity(this.ar, this.en);
}

const _kCities = [
  _YemenCity('صنعاء',    "Sana'a"),
  _YemenCity('عدن',      'Aden'),
  _YemenCity('تعز',      "Ta'iz"),
  _YemenCity('الحديدة',  'Hodeidah'),
  _YemenCity('إب',       'Ibb'),
  _YemenCity('المكلا',   'Mukalla'),
  _YemenCity('حضرموت',  'Hadhramaut'),
  _YemenCity('ذمار',     'Dhamar'),
  _YemenCity('حجة',      'Hajjah'),
  _YemenCity('مأرب',     "Ma'rib"),
  _YemenCity('شبوة',     'Shabwah'),
  _YemenCity('البيضاء',  'Al-Bayda'),
  _YemenCity('لحج',      'Lahij'),
  _YemenCity('أبين',     'Abyan'),
  _YemenCity('ريمة',     'Raymah'),
  _YemenCity('عمران',    'Amran'),
  _YemenCity('صعدة',     "Sa'dah"),
  _YemenCity('الجوف',    'Al-Jawf'),
  _YemenCity('المهرة',   'Al-Mahrah'),
  _YemenCity('سقطرى',   'Socotra'),
  _YemenCity('الضالع',   'Ad-Dali'),
];

class _PaymentMethod {
  final String id;       // backend value: jaib | cremi | bank
  final String ar;
  final String en;
  final String emoji;
  final Color  color;
  final String account;
  const _PaymentMethod({
    required this.id,
    required this.ar,
    required this.en,
    required this.emoji,
    required this.color,
    required this.account,
  });
}

const _kPayments = [
  _PaymentMethod(
    id:      'jaib',
    ar:      'محفظة جيب',
    en:      'Jaib Wallet',
    emoji:   '📱',
    color:   TbColors.yellow,
    account: '+967 77 123 4567',
  ),
  _PaymentMethod(
    id:      'cremi',
    ar:      'كريمي',
    en:      'Cremi',
    emoji:   '💳',
    color:   TbColors.pink,
    account: '+967 73 998 0011',
  ),
  _PaymentMethod(
    id:      'bank',
    ar:      'حوالة بنكية',
    en:      'Bank Transfer',
    emoji:   '🏦',
    color:   TbColors.blue,
    account: 'IBAN: YE12 3456 7890',
  ),
];

// Flat shipping — matches cart screen constant
const int _kShipping = 1500;

// ─────────────────────────────────────────────────────────────────────────────
// Checkout screen root
// ─────────────────────────────────────────────────────────────────────────────

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  // ── Step state ────────────────────────────────────────────────────────────
  int _step = 1; // 1 = Address, 2 = Payment, 3 = Summary & confirm

  // ── Step 1 — Address ──────────────────────────────────────────────────────
  final _nameCtrl    = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  final _addressCtrl = TextEditingController();
  _YemenCity? _selectedCity;

  // Per-field errors
  String? _nameError;
  String? _phoneError;
  String? _addressError;
  String? _cityError;

  // ── Step 2 — Payment ──────────────────────────────────────────────────────
  _PaymentMethod? _selectedPayment;
  String? _paymentError;

  // ── Step 3 — Submitting ───────────────────────────────────────────────────
  bool _submitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateStep1() {
    final nameErr    = _nameCtrl.text.trim().isEmpty   ? 'الاسم مطلوب' : null;
    final phoneRaw   = _phoneCtrl.text.trim();
    final phoneErr   = phoneRaw.isEmpty
        ? 'رقم الهاتف مطلوب'
        : !RegExp(r'^[\d\s\+]{7,15}$').hasMatch(phoneRaw)
            ? 'أدخل رقم هاتف صحيح'
            : null;
    final addrErr    = _addressCtrl.text.trim().isEmpty ? 'العنوان مطلوب' : null;
    final cityErr    = _selectedCity == null ? 'اختر المدينة' : null;

    setState(() {
      _nameError    = nameErr;
      _phoneError   = phoneErr;
      _addressError = addrErr;
      _cityError    = cityErr;
    });

    return nameErr == null && phoneErr == null &&
           addrErr == null && cityErr == null;
  }

  bool _validateStep2() {
    final err = _selectedPayment == null ? 'اختر طريقة الدفع' : null;
    setState(() => _paymentError = err);
    return err == null;
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _onNext() {
    if (_step == 1) {
      if (_validateStep1()) setState(() => _step = 2);
    } else if (_step == 2) {
      if (_validateStep2()) setState(() => _step = 3);
    } else {
      _submitOrder();
    }
  }

  void _onBack() {
    if (_step == 1) {
      context.pop();
    } else {
      setState(() => _step--);
    }
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  void _submitOrder() {
    // Actual API call wired here in production.
    // For now navigate to order-placed confirmation.
    setState(() => _submitting = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      setState(() => _submitting = false);
      ref.read(cartProvider.notifier).clearCart();
      ref.read(promoProvider.notifier).clear();
      context.go('/placed/TB-${DateTime.now().millisecondsSinceEpoch % 10000}');
    });
  }

  // ── Step labels ───────────────────────────────────────────────────────────

  String get _nextLabel => switch (_step) {
        1 => 'التالي: طريقة الدفع',
        2 => 'التالي: مراجعة الطلب',
        _ => 'تأكيد الطلب',
      };

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart  = ref.watch(cartProvider);
    final promo = ref.watch(promoProvider);

    final discount   = promo.discountAmount;
    final grandTotal = (cart.subtotal - discount + _kShipping)
        .clamp(0, 999999999);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ────────────────────────────────────────────────
              _CheckoutHeader(step: _step, onBack: _onBack),

              // ── Step indicator ────────────────────────────────────────
              _StepIndicator(current: _step),

              // ── Scrollable body ───────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: switch (_step) {
                        1 => _AddressStep(
                              nameCtrl:    _nameCtrl,
                              phoneCtrl:   _phoneCtrl,
                              addressCtrl: _addressCtrl,
                              selectedCity: _selectedCity,
                              nameError:   _nameError,
                              phoneError:  _phoneError,
                              addressError: _addressError,
                              cityError:   _cityError,
                              onCitySelected: (c) => setState(() {
                                _selectedCity = c;
                                _cityError = null;
                              }),
                            ),
                        2 => _PaymentStep(
                              selected: _selectedPayment,
                              error:    _paymentError,
                              onSelect: (p) => setState(() {
                                _selectedPayment = p;
                                _paymentError = null;
                              }),
                            ),
                        _ => _SummaryStep(
                              cart:       cart,
                              promo:      promo,
                              discount:   discount,
                              grandTotal: grandTotal,
                              name:       _nameCtrl.text.trim(),
                              phone:      _phoneCtrl.text.trim(),
                              city:       _selectedCity?.ar ?? '',
                              address:    _addressCtrl.text.trim(),
                              payment:    _selectedPayment!,
                            ),
                      },
                    ),
                  ),
                ),
              ),

              // ── Bottom action bar ─────────────────────────────────────
              _BottomBar(
                label:      _nextLabel,
                loading:    _submitting,
                grandTotal: grandTotal,
                step:       _step,
                onTap:      _onNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header
// ─────────────────────────────────────────────────────────────────────────────

class _CheckoutHeader extends StatelessWidget {
  final int step;
  final VoidCallback onBack;
  const _CheckoutHeader({required this.step, required this.onBack});

  static const _titles = ['عنوان التوصيل', 'طريقة الدفع', 'مراجعة الطلب'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: TbColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: TbColors.line),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: TbColors.ink,
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _titles[step - 1],
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: TbColors.ink,
              ),
            ),
          ),

          // Step counter badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: TbColors.bg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: TbColors.line),
            ),
            child: Text(
              '$step / 3',
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 12,
                fontWeight: FontWeight.w700,
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
// Step indicator dots
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current;
  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: List.generate(3, (i) {
          final stepNum = i + 1;
          final done    = stepNum < current;
          final active  = stepNum == current;

          return Expanded(
            child: Row(
              children: [
                // Circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done || active ? TbColors.ink : TbColors.card,
                    border: Border.all(
                      color: done || active ? TbColors.ink : TbColors.line,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: TbColors.cream)
                        : Text(
                            '$stepNum',
                            style: TextStyle(
                              fontFamily: TbFonts.arabic,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? TbColors.cream
                                  : TbColors.ink3,
                            ),
                          ),
                  ),
                ),

                // Connector line (skip after last)
                if (i < 2)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 2,
                      color: done ? TbColors.ink : TbColors.line,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 — Delivery address
// ─────────────────────────────────────────────────────────────────────────────

class _AddressStep extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final TextEditingController addressCtrl;
  final _YemenCity? selectedCity;
  final String? nameError;
  final String? phoneError;
  final String? addressError;
  final String? cityError;
  final ValueChanged<_YemenCity> onCitySelected;

  const _AddressStep({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.addressCtrl,
    required this.selectedCity,
    required this.nameError,
    required this.phoneError,
    required this.addressError,
    required this.cityError,
    required this.onCitySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Name ───────────────────────────────────────────────────────
        AppTextField(
          label:           'الاسم الكامل',
          hint:            'مثال: أم عبدالله',
          controller:      nameCtrl,
          error:           nameError,
          keyboardType:    TextInputType.name,
          textInputAction: TextInputAction.next,
          prefix: const Icon(Icons.person_outline_rounded,
              size: 20, color: TbColors.ink3),
        ),
        const SizedBox(height: 14),

        // ── Phone ──────────────────────────────────────────────────────
        AppTextField(
          label:           'رقم الهاتف',
          hint:            '+967 77 000 0000',
          controller:      phoneCtrl,
          error:           phoneError,
          keyboardType:    TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.allow(
              RegExp(r'[\d\s\+\-]'))],
          prefix: const Icon(Icons.phone_outlined,
              size: 20, color: TbColors.ink3),
        ),
        const SizedBox(height: 20),

        // ── City dropdown ──────────────────────────────────────────────
        _SectionLabel(label: 'المدينة', error: cityError),
        const SizedBox(height: 10),
        _CityDropdown(
          selected:   selectedCity,
          hasError:   cityError != null,
          onSelected: onCitySelected,
        ),
        const SizedBox(height: 20),

        // ── Street address ─────────────────────────────────────────────
        AppTextField(
          label:           'العنوان التفصيلي',
          hint:            'الحي، الشارع، المبنى...',
          controller:      addressCtrl,
          error:           addressError,
          keyboardType:    TextInputType.streetAddress,
          textInputAction: TextInputAction.done,
          maxLines:        3,
          prefix: const Icon(Icons.location_on_outlined,
              size: 20, color: TbColors.ink3),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City dropdown — tappable card that opens a bottom-sheet picker
// ─────────────────────────────────────────────────────────────────────────────

class _CityDropdown extends StatelessWidget {
  final _YemenCity? selected;
  final bool hasError;
  final ValueChanged<_YemenCity> onSelected;

  const _CityDropdown({
    required this.selected,
    required this.hasError,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: TbColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasError ? TbColors.pink : TbColors.line,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_city_outlined,
              size: 20,
              color: hasError ? TbColors.pink : TbColors.ink3,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected?.ar ?? 'اختر المدينة',
                style: TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 15,
                  fontWeight: selected != null
                      ? FontWeight.w500
                      : FontWeight.w400,
                  color: selected != null ? TbColors.ink : TbColors.ink3,
                ),
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: hasError ? TbColors.pink : TbColors.ink3,
            ),
          ],
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<_YemenCity>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _CityPickerSheet(
        cities:   _kCities,
        selected: selected,
      ),
    ).then((city) {
      if (city != null) onSelected(city);
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City picker bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _CityPickerSheet extends StatefulWidget {
  final List<_YemenCity> cities;
  final _YemenCity? selected;

  const _CityPickerSheet({required this.cities, required this.selected});

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  List<_YemenCity> get _filtered => widget.cities
      .where((c) =>
          c.ar.contains(_query) ||
          c.en.toLowerCase().contains(_query.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: TbColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            const SizedBox(height: 12),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: TbColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'اختر المدينة',
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: TbColors.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                autofocus: true,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 14,
                  color: TbColors.ink,
                ),
                decoration: InputDecoration(
                  hintText: 'بحث...',
                  hintStyle: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    color: TbColors.ink3,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: TbColors.ink3, size: 20),
                  filled: true,
                  fillColor: TbColors.bg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TbColors.line),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: TbColors.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: TbColors.ink, width: 1.5),
                  ),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            const SizedBox(height: 8),

            // City list
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.45,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: _filtered.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: TbColors.line),
                itemBuilder: (_, i) {
                  final city    = _filtered[i];
                  final isActive = city.ar == widget.selected?.ar;

                  return InkWell(
                    onTap: () => Navigator.of(context).pop(city),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              city.ar,
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 15,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? TbColors.ink
                                    : TbColors.ink2,
                              ),
                            ),
                          ),
                          if (isActive)
                            const Icon(Icons.check_rounded,
                                size: 18, color: TbColors.ink),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 — Payment method
// ─────────────────────────────────────────────────────────────────────────────

class _PaymentStep extends StatelessWidget {
  final _PaymentMethod? selected;
  final String? error;
  final ValueChanged<_PaymentMethod> onSelect;

  const _PaymentStep({
    required this.selected,
    required this.error,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
        const Text(
          'اختر طريقة الدفع',
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: TbColors.ink,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'حوّل المبلغ إلى الحساب المحدد ثم ارفع صورة الإيصال في الخطوة التالية.',
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: 13,
            color: TbColors.ink3,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Payment cards
        ..._kPayments.map(
          (p) => _PaymentCard(
            method:   p,
            isActive: selected?.id == p.id,
            onTap:    () => onSelect(p),
          ),
        ),

        // Error
        if (error != null) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 14, color: TbColors.pink),
              const SizedBox(width: 6),
              Text(
                error!,
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 12,
                  color: TbColors.pink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 16),

        // How payment works info banner
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TbColors.yellow.withOpacity(0.15),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: TbColors.yellow.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('💡', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'بعد اختيار طريقة الدفع، حوّل المبلغ إلى الحساب الموضح، '
                  'ثم ارفع صورة إيصال التحويل لتأكيد طلبك.',
                  style: TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 13,
                    color: TbColors.ink,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final _PaymentMethod method;
  final bool isActive;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.method,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: TbColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isActive ? TbColors.ink : TbColors.line,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Coloured icon circle
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: method.color,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  method.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Name + account
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.ar,
                    style: const TextStyle(
                      fontFamily: TbFonts.arabic,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: TbColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    method.account,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: TbColors.ink3,
                      letterSpacing: 0.02,
                    ),
                  ),
                ],
              ),
            ),

            // Radio dot
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? TbColors.ink : Colors.transparent,
                border: Border.all(
                  color: isActive ? TbColors.ink : TbColors.line,
                  width: isActive ? 0 : 2,
                ),
              ),
              child: isActive
                  ? const Icon(Icons.check_rounded,
                      size: 13, color: TbColors.cream)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 — Order summary & confirm
// ─────────────────────────────────────────────────────────────────────────────

class _SummaryStep extends StatelessWidget {
  final CartState cart;
  final PromoState promo;
  final int discount;
  final int grandTotal;
  final String name;
  final String phone;
  final String city;
  final String address;
  final _PaymentMethod payment;

  const _SummaryStep({
    required this.cart,
    required this.promo,
    required this.discount,
    required this.grandTotal,
    required this.name,
    required this.phone,
    required this.city,
    required this.address,
    required this.payment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Delivery info card ─────────────────────────────────────────
        _SectionCard(
          title: 'بيانات التوصيل',
          icon: Icons.location_on_outlined,
          child: Column(
            children: [
              _InfoRow(label: 'الاسم', value: name),
              _InfoRow(label: 'الهاتف', value: phone),
              _InfoRow(label: 'المدينة', value: city),
              _InfoRow(label: 'العنوان', value: address, last: true),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Payment method card ────────────────────────────────────────
        _SectionCard(
          title: 'طريقة الدفع',
          icon: Icons.payment_outlined,
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: payment.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(payment.emoji,
                      style: const TextStyle(fontSize: 18)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payment.ar,
                      style: const TextStyle(
                        fontFamily: TbFonts.arabic,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: TbColors.ink,
                      ),
                    ),
                    Text(
                      payment.account,
                      style: const TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                        color: TbColors.ink3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Items list ─────────────────────────────────────────────────
        _SectionCard(
          title: 'المنتجات (${cart.count})',
          icon: Icons.shopping_bag_outlined,
          child: Column(
            children: [
              ...cart.items.asMap().entries.map((e) {
                final isLast = e.key == cart.items.length - 1;
                return _OrderItemRow(item: e.value, isLast: isLast);
              }),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Price breakdown ────────────────────────────────────────────
        _SectionCard(
          title: 'ملخص السعر',
          icon: Icons.receipt_long_outlined,
          child: Column(
            children: [
              _PriceRow(
                  label: 'المجموع الفرعي',
                  value: fmtYER(cart.subtotal, 'ar')),
              const SizedBox(height: 6),
              _PriceRow(
                  label: 'التوصيل',
                  value: fmtYER(_kShipping, 'ar')),
              if (discount > 0) ...[
                const SizedBox(height: 6),
                _PriceRow(
                  label: promo.result != null
                      ? 'خصم (${promo.result!.code})'
                      : 'الخصم',
                  value: '- ${fmtYER(discount, 'ar')}',
                  valueColor: TbColors.mint,
                ),
              ],
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(color: TbColors.line, height: 1),
              ),
              _PriceRow(
                label: 'الإجمالي',
                value: fmtYER(grandTotal, 'ar'),
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Payment instruction banner ─────────────────────────────────
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: TbColors.mintSoft,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: TbColors.mint.withOpacity(0.4)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('📋', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'حوّل مبلغ ${fmtYER(grandTotal, 'ar')} إلى حساب '
                  '${payment.ar} (${payment.account}) '
                  'ثم اضغط "تأكيد الطلب". سيُطلب منك رفع الإيصال بعد التأكيد.',
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 13,
                    color: TbColors.ink,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Small widgets used inside Step 3 ─────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TbColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: TbColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: TbColors.ink2),
              const SizedBox(width: 7),
              Text(
                title,
                style: const TextStyle(
                  fontFamily: TbFonts.arabic,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: TbColors.ink2,
                  letterSpacing: 0.02,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _InfoRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 13,
                color: TbColors.ink3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontFamily: TbFonts.arabic,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: TbColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final CartItem item;
  final bool isLast;

  const _OrderItemRow({required this.item, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 44,
              height: 44,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) =>
                          const ColoredBox(color: TbColors.line),
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: TbColors.bg),
                    )
                  : const ColoredBox(color: TbColors.bg),
            ),
          ),
          const SizedBox(width: 10),

          // Name + size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: TbColors.ink,
                  ),
                ),
                Text(
                  'المقاس: ${item.size} · ×${item.quantity}',
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 11,
                    color: TbColors.ink3,
                  ),
                ),
              ],
            ),
          ),

          // Line total
          Text(
            fmtYER(item.lineTotal, 'ar'),
            style: const TextStyle(
              fontFamily: TbFonts.arabic,
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: TbColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _PriceRow({
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
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
            color: bold ? TbColors.ink : TbColors.ink2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: bold ? 18 : 13,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? TbColors.ink,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section label with optional error
// ─────────────────────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  final String? error;

  const _SectionLabel({required this.label, this.error});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: TbFonts.arabic,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: TbColors.ink2,
          ),
        ),
        if (error != null) ...[
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: TbColors.pink.withOpacity(0.1),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                  color: TbColors.pink.withOpacity(0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 11, color: TbColors.pink),
                const SizedBox(width: 4),
                Text(
                  error!,
                  style: const TextStyle(
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sticky bottom action bar
// ─────────────────────────────────────────────────────────────────────────────

class _BottomBar extends StatelessWidget {
  final String label;
  final bool loading;
  final int grandTotal;
  final int step;
  final VoidCallback onTap;

  const _BottomBar({
    required this.label,
    required this.loading,
    required this.grandTotal,
    required this.step,
    required this.onTap,
  });

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
      child: Row(
        children: [
          // Grand total pill — only shown on step 3
          if (step == 3) ...[
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
                  fmtYER(grandTotal, 'ar'),
                  style: const TextStyle(
                    fontFamily: TbFonts.arabic,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: TbColors.ink,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
          ],

          // Action button
          Expanded(
            child: AppButton(
              label: label,
              loading: loading,
              variant: step == 3
                  ? AppButtonVariant.accent
                  : AppButtonVariant.primary,
              icon: step < 3
                  ? const Icon(Icons.arrow_back_rounded,
                      size: 18, color: TbColors.cream)
                  : const Icon(Icons.check_rounded,
                      size: 18, color: Colors.white),
              onTap: onTap,
            ),
          ),
        ],
      ),
    );
  }
}