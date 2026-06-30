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
}
