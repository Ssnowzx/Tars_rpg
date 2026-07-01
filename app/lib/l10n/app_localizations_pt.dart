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

  @override
  String get actionBuild => 'Construir';

  @override
  String get actionRecruit => 'Recrutar';

  @override
  String get actionMissions => 'Missões';

  @override
  String get actionMessages => 'Mensagens';

  @override
  String get statusOnline => 'Online';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String comingSoonAction(String label) {
    return '$label — em breve';
  }

  @override
  String get authTaglineLogin => 'Entre para gerir sua colônia.';

  @override
  String get authTaglineRegister => 'Crie sua colônia em Fertways.';

  @override
  String get authEmail => 'E-mail';

  @override
  String get authNickname => 'Nickname';

  @override
  String get authPassword => 'Senha';

  @override
  String get authLogin => 'Entrar';

  @override
  String get authRegister => 'Registrar';

  @override
  String get authSwitchToLogin => 'Já tem conta? Entrar';

  @override
  String get authSwitchToRegister => 'Novo colono? Criar conta';

  @override
  String get authValidation =>
      'Preencha e-mail, senha (mín. 8) e nickname (mín. 3 no registro).';
}
