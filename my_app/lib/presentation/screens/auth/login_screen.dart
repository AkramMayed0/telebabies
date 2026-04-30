import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/core/router/routes.dart';
import 'package:my_app/presentation/providers/auth_provider.dart';
import 'package:my_app/presentation/widgets/common/AppButton.dart';
import 'package:my_app/presentation/widgets/common/AppTextField.dart';
import 'package:my_app/theme.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl   = TextEditingController();

  bool    _obscure  = true;
  bool    _loading  = false;
  String? _error;

  late final AnimationController _sheetAnim;
  late final Animation<Offset>   _sheetSlide;

  @override
  void initState() {
    super.initState();
    _sheetAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _sheetSlide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _sheetAnim, curve: Curves.easeOutCubic));
    _sheetAnim.forward();
  }

  @override
  void dispose() {
    _sheetAnim.dispose();
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final id  = _identifierCtrl.text.trim();
    final pwd = _passwordCtrl.text;

    if (id.isEmpty || pwd.isEmpty) {
      setState(() => _error = 'يرجى تعبئة جميع الحقول');
      return;
    }

    setState(() { _loading = true; _error = null; });

    final ok = await ref.read(authProvider.notifier).login(
      identifier: id,
      password: pwd,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(() => _error = ref.read(authProvider).error ?? 'بيانات الدخول غير صحيحة');
    }
    // On success go_router redirect handles navigation automatically.
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TbColors.pink,
        body: Stack(
          children: [
            const _HeroBg(),
            Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                const Expanded(child: _HeroContent()),
                SlideTransition(
                  position: _sheetSlide,
                  child: _Sheet(
                    identifierCtrl: _identifierCtrl,
                    passwordCtrl: _passwordCtrl,
                    obscure: _obscure,
                    onToggleObscure: () => setState(() => _obscure = !_obscure),
                    loading: _loading,
                    error: _error,
                    onSubmit: _submit,
                    onRegister: () => context.go(Routes.register),
                    onSkip: () => context.go(Routes.home),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero background blobs ─────────────────────────────────────────────────────

class _HeroBg extends StatelessWidget {
  const _HeroBg();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -50, left: -50,
          child: Container(
            width: 200, height: 200,
            decoration: BoxDecoration(
              color: TbColors.yellow.withValues(alpha: 0.55),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 200, right: -40,
          child: Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              color: TbColors.mint.withValues(alpha: 0.45),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Positioned(
          top: 90, right: 60,
          child: Icon(Icons.star_rounded, size: 24, color: TbColors.yellow),
        ),
        Positioned(
          top: 210, left: 48,
          child: Icon(Icons.add_rounded,
              size: 20, color: Colors.white.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

// ── Hero wordmark + tagline ───────────────────────────────────────────────────

class _HeroContent extends StatelessWidget {
  const _HeroContent();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.sentiment_satisfied_alt_rounded,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  children: [
                    const TextSpan(text: 'تيلي'),
                    TextSpan(
                      text: 'بيبيز',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'ملابس صغيرة،\nأحلام كبيرة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'تسوق أحدث ملابس الأطفال بأفضل الأسعار.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.55,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Bottom sheet form ─────────────────────────────────────────────────────────

class _Sheet extends StatelessWidget {
  final TextEditingController identifierCtrl;
  final TextEditingController passwordCtrl;
  final bool obscure;
  final VoidCallback onToggleObscure;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;
  final VoidCallback onRegister;
  final VoidCallback onSkip;

  const _Sheet({
    required this.identifierCtrl,
    required this.passwordCtrl,
    required this.obscure,
    required this.onToggleObscure,
    required this.loading,
    required this.error,
    required this.onSubmit,
    required this.onRegister,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: TbColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      padding: EdgeInsets.fromLTRB(
        22, 26, 22,
        22 + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'مرحباً بك 👋',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: TbColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'سجّل دخولك للمتابعة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13,
              color: TbColors.ink3,
            ),
          ),
          const SizedBox(height: 20),

          AppTextField(
            label: 'البريد الإلكتروني أو رقم الهاتف',
            hint: 'example@email.com',
            controller: identifierCtrl,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 14),

          AppTextField(
            label: 'كلمة المرور',
            hint: '••••••••',
            controller: passwordCtrl,
            obscureText: obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => onSubmit(),
            suffix: IconButton(
              icon: Icon(
                obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: TbColors.ink3,
                size: 20,
              ),
              onPressed: onToggleObscure,
            ),
            error: error,
          ),
          const SizedBox(height: 20),

          AppButton(
            label: 'تسجيل الدخول',
            loading: loading,
            onTap: onSubmit,
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ليس لديك حساب؟',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: TbColors.ink3,
                ),
              ),
              TextButton(
                onPressed: onRegister,
                style: TextButton.styleFrom(
                  foregroundColor: TbColors.pink,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                ),
                child: const Text(
                  'إنشاء حساب',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              minimumSize: const Size.fromHeight(40),
              foregroundColor: TbColors.ink3,
            ),
            child: const Text(
              'تصفح بدون تسجيل',
              style: TextStyle(fontFamily: 'Cairo', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
