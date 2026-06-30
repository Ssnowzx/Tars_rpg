// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Fertways';

  @override
  String get navMap => 'Map';

  @override
  String get navCapital => 'Capital';

  @override
  String get navMarket => 'Market';

  @override
  String get navSpaceport => 'Spaceport';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get hudCurrency => 'Fert\$';

  @override
  String get hudResourcesLabel => 'Resources';

  @override
  String get capitalTitle => 'Capital';

  @override
  String capitalSlotsSummary(int used, int total) {
    return '$used of $total institutions installed';
  }

  @override
  String get capitalEmptySlot => 'Empty slot';

  @override
  String get capitalBuildAction => 'Install';

  @override
  String get stateLoading => 'Loading…';

  @override
  String get stateError => 'Couldn\'t load. Tap to retry.';

  @override
  String get comingSoon => 'Coming soon';
}
