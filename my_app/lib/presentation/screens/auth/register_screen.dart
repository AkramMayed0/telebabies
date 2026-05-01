import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/router/routes.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/presentation/widgets/common/AppTextField.dart';
import 'package:my_app/presentation/widgets/common/tb_wordmark.dart';
import 'package:my_app/theme.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  // ── Controllers ───────────────────────────────────────────────────────────
  final _nameController            = TextEditingController();
  final _emailOrPhoneController    = TextEditingController();
  final _passwordController        = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ── Focus nodes ───────────────────────────────────────────────────────────
  final _nameFocus            = FocusNode();
  final _emailOrPhoneFocus    = FocusNode();
  final _passwordFocus        = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // ── UI state ──────────────────────────────────────────────────────────────
  bool _obscurePassword = true;
  bool _obscureConfirm  = true;
  bool _loading         = false;

  // Per-field validation errors (Arabic strings).
  String? _nameError;
  String? _emailOrPhoneError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Top-level API error (shown in a banner above the submit button).
  String? _apiError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailOrPhoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailOrPhoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  // ── Client-side validation ────────────────────────────────────────────────

  bool _validate() {
    final name         = _nameController.text.trim();
    final emailOrPhone = _emailOrPhoneController.text.trim();
    final password     = _passwordController.text;
    final confirm      = _confirmPasswordController.text;

    String? nameErr;
    String? emailOrPhoneErr;
    String? passwordErr;
    String? confirmErr;

    if (name.isEmpty) {
      nameErr = 'الاسم الكامل مطلوب';
    } else if (name.length < 2) {
      nameErr = 'أدخل اسمًا صحيحًا';
    }

    if (emailOrPhone.isEmpty) {
      emailOrPhoneErr = 'البريد الإلكتروني أو رقم الهاتف مطلوب';
    } else {
      final isEmail = emailOrPhone.contains('@');
      final isPhone = RegExp(r'^\+?[0-9]{7,15}$').hasMatch(emailOrPhone);
      if (!isEmail && !isPhone) {
        emailOrPhoneErr = 'أدخل بريدًا إلكترونيًا أو رقم هاتف صحيح';
      }
    }

    if (password.isEmpty) {
      passwordErr = 'كلمة المرور مطلوبة';
    } else if (password.length < 8) {
      passwordErr = 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (confirm.isEmpty) {
      confirmErr = 'يرجى تأكيد كلمة المرور';
    } else if (confirm != password) {
      confirmErr = 'كلمتا المرور غير متطابقتين';
    }

    setState(() {
      _nameError            = nameErr;
      _emailOrPhoneError    = emailOrPhoneErr;
      _passwordError        = passwordErr;
      _confirmPasswordError = confirmErr;
      _apiError             = null; // reset stale API error on re-validation
    });

    return nameErr == null &&
        emailOrPhoneErr == null &&
        passwordErr == null &&
        confirmErr == null;
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() { _loading = true; _apiError = null; });

    final ok = await ref.read(authProvider.notifier).register(
      name:     _nameController.text.trim(),
      email:    _emailOrPhoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(() => _apiError = ref.read(authProvider).error);
      return;
    }

    context.go(Routes.login);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _clearFieldError(void Function() fn) {
    fn();
    if (_apiError != null) setState(() => _apiError = null);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.bg,
        body: SafeArea(
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // ── Back button ─────────────────────────────────────
                      GestureDetector(
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(Routes.login),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: TbColors.card,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: TbColors.line),
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: TbColors.ink,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ── Brand ───────────────────────────────────────────
                      const TbWordmark(lang: 'ar', size: 26),

                      const SizedBox(height: 20),

                      // ── Heading ─────────────────────────────────────────
                      const Text(
                        'إنشاء حساب جديد',
                        style: TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: TbColors.ink,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'أدخل بياناتك لتسجيل حساب جديد',
                        style: TextStyle(
                          fontFamily: TbFonts.arabic,
                          fontSize: 14,
                          color: TbColors.ink3,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ── Name ────────────────────────────────────────────
                      AppTextField(
                        label: 'الاسم الكامل',
                        hint: 'مثال: أم عبدالله',
                        controller: _nameController,
                        focusNode: _nameFocus,
                        error: _nameError,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_emailOrPhoneFocus),
                        onChanged: (_) => _clearFieldError(
                          () { if (_nameError != null) setState(() => _nameError = null); },
                        ),
                        prefix: const Icon(
                          Icons.person_outline_rounded,
                          color: TbColors.ink3,
                          size: 20,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Email / Phone ────────────────────────────────────
                      AppTextField(
                        label: 'البريد الإلكتروني أو رقم الهاتف',
                        hint: 'example@email.com أو +9671234567',
                        controller: _emailOrPhoneController,
                        focusNode: _emailOrPhoneFocus,
                        error: _emailOrPhoneError,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_passwordFocus),
                        onChanged: (_) => _clearFieldError(
                          () { if (_emailOrPhoneError != null) setState(() => _emailOrPhoneError = null); },
                        ),
                        prefix: const Icon(
                          Icons.alternate_email_rounded,
                          color: TbColors.ink3,
                          size: 20,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Password ─────────────────────────────────────────
                      AppTextField(
                        label: 'كلمة المرور',
                        hint: '8 أحرف على الأقل',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        error: _passwordError,
                        obscureText: _obscurePassword,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => FocusScope.of(context)
                            .requestFocus(_confirmPasswordFocus),
                        onChanged: (_) => _clearFieldError(
                          () { if (_passwordError != null) setState(() => _passwordError = null); },
                        ),
                        prefix: const Icon(
                          Icons.lock_outline_rounded,
                          color: TbColors.ink3,
                          size: 20,
                        ),
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: TbColors.ink3,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ── Confirm Password ─────────────────────────────────
                      AppTextField(
                        label: 'تأكيد كلمة المرور',
                        hint: 'أعد إدخال كلمة المرور',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        error: _confirmPasswordError,
                        obscureText: _obscureConfirm,
                        keyboardType: TextInputType.visiblePassword,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _submit(),
                        onChanged: (_) => _clearFieldError(
                          () { if (_confirmPasswordError != null) setState(() => _confirmPasswordError = null); },
                        ),
                        prefix: const Icon(
                          Icons.lock_outline_rounded,
                          color: TbColors.ink3,
                          size: 20,
                        ),
                        suffix: GestureDetector(
                          onTap: () => setState(
                              () => _obscureConfirm = !_obscureConfirm),
                          child: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: TbColors.ink3,
                            size: 20,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── API error banner ─────────────────────────────────
                      // Only appears when the server returns an error.
                      AnimatedSize(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: _apiError != null
                            ? Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: TbColors.pink.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: TbColors.pink.withOpacity(0.35)),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: TbColors.pink,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _apiError!,
                                        style: const TextStyle(
                                          fontFamily: TbFonts.arabic,
                                          fontSize: 13,
                                          color: TbColors.pink,
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      // ── Submit button ────────────────────────────────────
                      AppButton(
                        label: 'إنشاء الحساب',
                        onTap: _loading ? null : _submit,
                        loading: _loading,
                        variant: AppButtonVariant.accent,
                      ),

                      const SizedBox(height: 20),

                      // ── Login link ───────────────────────────────────────
                      Center(
                        child: GestureDetector(
                          onTap: () => context.go(Routes.login),
                          child: RichText(
                            textDirection: TextDirection.rtl,
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: TbFonts.arabic,
                                fontSize: 14,
                                color: TbColors.ink3,
                              ),
                              children: [
                                TextSpan(text: 'لديك حساب بالفعل؟ '),
                                TextSpan(
                                  text: 'تسجيل الدخول',
                                  style: TextStyle(
                                    color: TbColors.pink,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}