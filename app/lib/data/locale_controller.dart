import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLocaleKey = 'localeCode';

/// Código de idioma carregado do storage no boot (sobrescrito em main). null =
/// nunca escolhido → segue o padrão.
final initialLocaleProvider = Provider<String?>((ref) => null);

/// Idioma ativo do app (§11 i18n): PT-BR/ES/EN. Estado mutável — a troca no
/// menu do HUD reflete na hora e **persiste entre sessões** (SharedPreferences).
class LocaleController extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.read(initialLocaleProvider);
    if (code != null && code.isNotEmpty) return Locale(code);
    return const Locale('pt');
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(_kLocaleKey);
    } else {
      await prefs.setString(_kLocaleKey, locale.languageCode);
    }
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale?>(LocaleController.new);
