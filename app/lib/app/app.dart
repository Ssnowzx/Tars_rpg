import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/locale_controller.dart';
import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/ds_theme.dart';

/// Raiz do app: tema claro/escuro a partir dos tokens (dark-first),
/// i18n pt/es/en (idioma trocável em `localeProvider`), navegação go_router.
class FertwaysApp extends ConsumerWidget {
  const FertwaysApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: FwTheme.light,
      darkTheme: FwTheme.dark,
      themeMode: ThemeMode.light, // direção Solar Frontier (claro)
      locale: locale,
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
