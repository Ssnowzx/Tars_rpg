import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Idioma ativo do app (§11 i18n): PT-BR/ES/EN. Estado mutável — a troca no
/// menu do HUD reflete na hora. Padrão pt-BR; persistência entre sessões é
/// dívida (precisaria de storage local). `null` = seguir o dispositivo.
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() => const Locale('pt');

  void set(Locale? locale) => state = locale;
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
