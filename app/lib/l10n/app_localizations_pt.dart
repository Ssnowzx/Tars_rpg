// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Fertways';

  @override
  String get navMap => 'Mapa';

  @override
  String get navCapital => 'Capital';

  @override
  String get navMarket => 'Mercado';

  @override
  String get navSpaceport => 'Espaçoporto';

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
    return '$used de $total instituições instaladas';
  }

  @override
  String get capitalEmptySlot => 'Slot livre';

  @override
  String get capitalBuildAction => 'Instalar';

  @override
  String get stateLoading => 'Carregando…';

  @override
  String get stateError =>
      'Não foi possível carregar. Toque para tentar de novo.';

  @override
  String get comingSoon => 'Em construção';
}
