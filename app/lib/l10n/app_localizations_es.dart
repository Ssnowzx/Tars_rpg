// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Fertways';

  @override
  String get navMap => 'Mapa';

  @override
  String get navCapital => 'Capital';

  @override
  String get navMarket => 'Mercado';

  @override
  String get navSpaceport => 'Espaciopuerto';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Perfil';

  @override
  String get hudCurrency => 'Fert\$';

  @override
  String get hudResourcesLabel => 'Recursos';

  @override
  String get capitalTitle => 'Capital';

  @override
  String capitalSlotsSummary(int used, int total) {
    return '$used de $total instituciones instaladas';
  }

  @override
  String get capitalEmptySlot => 'Espacio libre';

  @override
  String get capitalBuildAction => 'Instalar';

  @override
  String get stateLoading => 'Cargando…';

  @override
  String get stateError => 'No se pudo cargar. Toca para reintentar.';

  @override
  String get comingSoon => 'En construcción';

  @override
  String get actionBuild => 'Construir';

  @override
  String get actionRecruit => 'Reclutar';

  @override
  String get actionMissions => 'Misiones';

  @override
  String get actionMessages => 'Mensajes';

  @override
  String get statusOnline => 'En línea';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String comingSoonAction(String label) {
    return '$label — próximamente';
  }

  @override
  String get authTaglineLogin => 'Entra para gestionar tu colonia.';

  @override
  String get authTaglineRegister => 'Crea tu colonia en Fertways.';

  @override
  String get authEmail => 'Correo';

  @override
  String get authNickname => 'Apodo';

  @override
  String get authPassword => 'Contraseña';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authRegister => 'Registrarse';

  @override
  String get authSwitchToLogin => '¿Ya tienes cuenta? Entrar';

  @override
  String get authSwitchToRegister => '¿Nuevo colono? Crear cuenta';

  @override
  String get authValidation =>
      'Completa correo, contraseña (mín. 8) y apodo (mín. 3 al registrarte).';
}
