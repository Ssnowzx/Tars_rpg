import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ds_colors.dart';
import 'ds_tokens.dart';

/// Constroi os dois [ThemeData] (claro padrao / escuro) a partir dos tokens
/// "Solar Frontier". Tipografia: Inter para UI; Rajdhani aplicado pontualmente
/// nos widgets (nome da colonia, numeros).
abstract final class FwTheme {
  static ThemeData get light => _build(FwColorScheme.light, DsTokens.light);
  static ThemeData get dark => _build(FwColorScheme.dark, DsTokens.dark);

  static ThemeData _build(ColorScheme scheme, DsTokens tokens) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: tokens.surfacePage,
      extensions: [tokens],
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: Size(0, tokens.controlMd),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: .2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(tokens.radiusButton),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: tokens.borderDefault),
          borderRadius: BorderRadius.circular(tokens.radiusCard),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusMd),
        ),
        selectedIconTheme: IconThemeData(color: scheme.primary),
        unselectedIconTheme: IconThemeData(color: tokens.textSecondary),
        selectedLabelTextStyle: TextStyle(
          color: scheme.primary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
        unselectedLabelTextStyle: TextStyle(color: tokens.textSecondary, fontSize: 11),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: tokens.borderDefault, thickness: 1, space: 1),
    );
  }
}
