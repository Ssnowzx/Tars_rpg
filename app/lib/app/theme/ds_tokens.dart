import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';

import 'ds_colors.dart';

/// Tokens nao-cobertos pelo [ColorScheme]: espacamento (base 4px), raios,
/// alturas de controle, motion (<=500ms) e cores semanticas extra (Solar Frontier).
/// Espelho de `design-system/tokens/{spacing,borders,sizing,motion,colors}.json`.
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  const DsTokens({
    required this.space1,
    required this.space2,
    required this.space3,
    required this.space4,
    required this.space6,
    required this.space8,
    required this.radiusSm,
    required this.radiusMd,
    required this.radiusLg,
    required this.radiusButton,
    required this.radiusCard,
    required this.controlMd,
    required this.controlLg,
    required this.touchTarget,
    required this.durationFast,
    required this.durationBase,
    required this.durationModerate,
    required this.easeOut,
    required this.easeInOut,
    required this.surfacePage,
    required this.surfaceSunken,
    required this.borderDefault,
    required this.borderStrong,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.info,
    required this.federation,
    required this.focusRing,
    required this.solar,
    required this.teal,
    required this.deltaUp,
    required this.deltaDown,
  });

  final double space1, space2, space3, space4, space6, space8;
  final double radiusSm, radiusMd, radiusLg, radiusButton, radiusCard;
  final double controlMd, controlLg, touchTarget;
  final Duration durationFast, durationBase, durationModerate;
  final Curve easeOut, easeInOut;

  final Color surfacePage;
  final Color surfaceSunken;
  final Color borderDefault;
  final Color borderStrong;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color info;
  final Color federation;
  final Color focusRing;
  final Color solar; // moeda / acento solar
  final Color teal; // acento frio
  final Color deltaUp; // producao positiva
  final Color deltaDown; // producao negativa

  static const light = DsTokens(
    space1: 4, space2: 8, space3: 12, space4: 16, space6: 24, space8: 32,
    radiusSm: 4, radiusMd: 6, radiusLg: 8, radiusButton: 6, radiusCard: 12,
    controlMd: 40, controlLg: 48, touchTarget: 48,
    durationFast: Duration(milliseconds: 100),
    durationBase: Duration(milliseconds: 200),
    durationModerate: Duration(milliseconds: 300),
    easeOut: Curves.easeOut,
    easeInOut: Curves.easeInOut,
    surfacePage: FwPalette.gray100,
    surfaceSunken: FwPalette.gray200,
    borderDefault: FwPalette.gray200,
    borderStrong: FwPalette.gray600,
    textSecondary: FwPalette.gray600,
    success: FwPalette.green600,
    warning: FwPalette.solar500,
    info: FwPalette.teal600,
    federation: FwPalette.purple600,
    focusRing: FwPalette.teal500,
    solar: FwPalette.solar500,
    teal: FwPalette.teal500,
    deltaUp: FwPalette.green600,
    deltaDown: FwPalette.red500,
  );

  static const dark = DsTokens(
    space1: 4, space2: 8, space3: 12, space4: 16, space6: 24, space8: 32,
    radiusSm: 4, radiusMd: 6, radiusLg: 8, radiusButton: 6, radiusCard: 12,
    controlMd: 40, controlLg: 48, touchTarget: 48,
    durationFast: Duration(milliseconds: 100),
    durationBase: Duration(milliseconds: 200),
    durationModerate: Duration(milliseconds: 300),
    easeOut: Curves.easeOut,
    easeInOut: Curves.easeInOut,
    surfacePage: FwPalette.gray950,
    surfaceSunken: FwPalette.black,
    borderDefault: FwPalette.gray800,
    borderStrong: FwPalette.gray500,
    textSecondary: FwPalette.gray400,
    success: FwPalette.green500,
    warning: FwPalette.solar400,
    info: FwPalette.teal300,
    federation: FwPalette.purple600,
    focusRing: FwPalette.teal300,
    solar: FwPalette.solar400,
    teal: FwPalette.teal300,
    deltaUp: FwPalette.green500,
    deltaDown: FwPalette.red500,
  );

  @override
  DsTokens copyWith({
    Color? surfacePage,
    Color? surfaceSunken,
    Color? borderDefault,
    Color? borderStrong,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? info,
    Color? federation,
    Color? focusRing,
    Color? solar,
    Color? teal,
    Color? deltaUp,
    Color? deltaDown,
  }) {
    return DsTokens(
      space1: space1, space2: space2, space3: space3, space4: space4,
      space6: space6, space8: space8,
      radiusSm: radiusSm, radiusMd: radiusMd, radiusLg: radiusLg,
      radiusButton: radiusButton, radiusCard: radiusCard,
      controlMd: controlMd, controlLg: controlLg, touchTarget: touchTarget,
      durationFast: durationFast, durationBase: durationBase,
      durationModerate: durationModerate, easeOut: easeOut, easeInOut: easeInOut,
      surfacePage: surfacePage ?? this.surfacePage,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      borderDefault: borderDefault ?? this.borderDefault,
      borderStrong: borderStrong ?? this.borderStrong,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      federation: federation ?? this.federation,
      focusRing: focusRing ?? this.focusRing,
      solar: solar ?? this.solar,
      teal: teal ?? this.teal,
      deltaUp: deltaUp ?? this.deltaUp,
      deltaDown: deltaDown ?? this.deltaDown,
    );
  }

  @override
  DsTokens lerp(ThemeExtension<DsTokens>? other, double t) {
    if (other is! DsTokens) return this;
    return DsTokens(
      space1: lerpDouble(space1, other.space1, t)!,
      space2: lerpDouble(space2, other.space2, t)!,
      space3: lerpDouble(space3, other.space3, t)!,
      space4: lerpDouble(space4, other.space4, t)!,
      space6: lerpDouble(space6, other.space6, t)!,
      space8: lerpDouble(space8, other.space8, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusButton: lerpDouble(radiusButton, other.radiusButton, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      controlMd: lerpDouble(controlMd, other.controlMd, t)!,
      controlLg: lerpDouble(controlLg, other.controlLg, t)!,
      touchTarget: lerpDouble(touchTarget, other.touchTarget, t)!,
      durationFast: t < 0.5 ? durationFast : other.durationFast,
      durationBase: t < 0.5 ? durationBase : other.durationBase,
      durationModerate: t < 0.5 ? durationModerate : other.durationModerate,
      easeOut: t < 0.5 ? easeOut : other.easeOut,
      easeInOut: t < 0.5 ? easeInOut : other.easeInOut,
      surfacePage: Color.lerp(surfacePage, other.surfacePage, t)!,
      surfaceSunken: Color.lerp(surfaceSunken, other.surfaceSunken, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderStrong: Color.lerp(borderStrong, other.borderStrong, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      federation: Color.lerp(federation, other.federation, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
      solar: Color.lerp(solar, other.solar, t)!,
      teal: Color.lerp(teal, other.teal, t)!,
      deltaUp: Color.lerp(deltaUp, other.deltaUp, t)!,
      deltaDown: Color.lerp(deltaDown, other.deltaDown, t)!,
    );
  }
}
