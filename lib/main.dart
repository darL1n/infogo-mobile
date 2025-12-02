import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app_initializer.dart';
import 'package:mobile/app_router.dart';
import 'package:mobile/providers/locale_provider.dart';
import 'package:provider/provider.dart';

import 'package:mobile/config/theme.dart';
import 'package:mobile/widgets/custom_scroll_behavior.dart';
import 'package:mobile/l10n/app_localizations.dart';

void main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      final router = AppRouter.createRouter();
      final providers = await AppInitializer.init();

      runApp(
        MultiProvider(
          providers: providers,
          child: InfoGoMobileApp(router: router),
        ),
      );
    },
    (error, stack) {
      debugPrint('❌ Uncaught zone error: $error');
    },
  );
}

class InfoGoMobileApp extends StatelessWidget {
  final GoRouter router;

  const InfoGoMobileApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleProvider>(
      builder: (context, localeProvider, _) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: 'Местный Гид',
          theme: appTheme,
          scrollBehavior: NoGlowScrollBehavior(),
          routerConfig: router,          // используем уже созданный router
          locale: localeProvider.locale, // <- выбранный язык

          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        );
      },
    );
  }
}