import 'package:flutter/material.dart';

/// Cores do Fertways — direção "Solar Frontier" (claro/quente). Espelho Dart de
/// `design-system/tokens/colors.json` (fonte única, verificada por
/// `scripts/validate_contrast.py`, AA light+dark). Regenerar via token-build se
/// o JSON mudar.
abstract final class FwPalette {
  // Neutros quentes areia -> ink
  static const gray50 = Color(0xFFFBFAF7);
  static const gray100 = Color(0xFFF7F6F3);
  static const gray200 = Color(0xFFEFEAE0);
  static const gray300 = Color(0xFFE6DECF);
  static const gray400 = Color(0xFFBBA98E);
  static const gray500 = Color(0xFF917F66);
  static const gray600 = Color(0xFF6E6151);
  static const gray700 = Color(0xFF4B4034);
  static const gray800 = Color(0xFF362C20);
  static const gray900 = Color(0xFF2A2118);
  static const gray950 = Color(0xFF1A140D);

  // Rust — marca
  static const rust50 = Color(0xFFFCF1EC);
  static const rust100 = Color(0xFFFBE0D2);
  static const rust200 = Color(0xFFF4BCA3);
  static const rust300 = Color(0xFFE1804E);
  static const rust500 = Color(0xFFCF5214);
  static const rust600 = Color(0xFFC1440E);
  static const rust700 = Color(0xFFA53909);
  static const rust800 = Color(0xFF7C2C0C);

  // Solar — âmbar/ouro
  static const solar100 = Color(0xFFFCE8C6);
  static const solar300 = Color(0xFFF6BC5E);
  static const solar400 = Color(0xFFF2A33C);
  static const solar500 = Color(0xFFE8941E);
  static const solar600 = Color(0xFFC0780F);
  static const solar700 = Color(0xFF97600D);

  // Teal — acento frio
  static const teal100 = Color(0xFFD2EAE6);
  static const teal200 = Color(0xFFA6D5CE);
  static const teal300 = Color(0xFF6BACA6);
  static const teal500 = Color(0xFF2C7E78);
  static const teal600 = Color(0xFF246661);
  static const teal700 = Color(0xFF1E534F);

  // Verde / vermelho (eco-sucesso / guerra-perigo, deltas)
  static const green500 = Color(0xFF2E9466);
  static const green600 = Color(0xFF257A55);
  static const green800 = Color(0xFF194D38);
  static const red500 = Color(0xFFCE3B2E);
  static const red600 = Color(0xFFB22C22);
  static const red700 = Color(0xFF91241C);

  static const purple600 = Color(0xFF7538C4);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
}

abstract final class FwColorScheme {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: FwPalette.rust600,
    onPrimary: FwPalette.white,
    primaryContainer: FwPalette.rust100,
    onPrimaryContainer: FwPalette.rust800,
    secondary: FwPalette.teal600,
    onSecondary: FwPalette.white,
    secondaryContainer: FwPalette.teal100,
    onSecondaryContainer: FwPalette.teal700,
    tertiary: FwPalette.solar400,
    onTertiary: FwPalette.gray900,
    tertiaryContainer: FwPalette.solar100,
    onTertiaryContainer: FwPalette.solar700,
    error: FwPalette.red600,
    onError: FwPalette.white,
    errorContainer: Color(0xFFFADBD6),
    onErrorContainer: Color(0xFF731F19),
    surface: FwPalette.gray50,
    onSurface: FwPalette.gray900,
    surfaceContainerHighest: FwPalette.gray200,
    outline: FwPalette.gray600,
    outlineVariant: FwPalette.gray200,
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: FwPalette.rust600,
    onPrimary: FwPalette.white,
    primaryContainer: FwPalette.rust800,
    onPrimaryContainer: FwPalette.rust100,
    secondary: FwPalette.teal300,
    onSecondary: FwPalette.gray950,
    secondaryContainer: FwPalette.teal700,
    onSecondaryContainer: FwPalette.teal100,
    tertiary: FwPalette.solar400,
    onTertiary: FwPalette.gray950,
    error: FwPalette.red500,
    onError: FwPalette.gray950,
    surface: FwPalette.gray950,
    onSurface: FwPalette.gray50,
    surfaceContainerHighest: FwPalette.gray800,
    outline: FwPalette.gray500,
    outlineVariant: FwPalette.gray800,
  );
}
