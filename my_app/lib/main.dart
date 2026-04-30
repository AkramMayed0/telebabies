import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/app_theme.dart';
import 'package:my_app/core/router/app_router.dart';
import 'package:my_app/presentation/providers/settings_provider.dart';

void main() {
  runApp(const ProviderScope(child: TeleBabiesApp()));
}

class TeleBabiesApp extends ConsumerWidget {
  const TeleBabiesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(settingsProvider).lang;
    final isAr = lang == 'ar';

    return MaterialApp.router(
      title: 'TeleBabies',
      theme: AppTheme.build(lang: lang),
      routerConfig: ref.watch(routerProvider),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}
