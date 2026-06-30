import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import 'router.dart';
import 'theme/ds_theme.dart';

/// Raiz do app: tema claro/escuro a partir dos tokens (dark-first),
/// i18n pt/es/en, navegação go_router.
class FertwaysApp extends StatelessWidget {
  const FertwaysApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: FwTheme.light,
      darkTheme: FwTheme.dark,
      themeMode: ThemeMode.light, // direção Solar Frontier (claro)
      routerConfig: appRouter,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
