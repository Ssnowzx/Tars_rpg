# Fertways — cliente Flutter + Flame (frontend)

Esqueleto da fundação visual de **Fertways: The Next Colony** (MMO de estratégia
econômica/colônia). Escopo: **frontend/visual apenas**, com **mock data** — sem backend.
Ver o briefing de UX/UI em `../brief-ux-ui-fertways.md` e o plano por fases em
`~/.claude/plans/`.

## Pré-requisitos

- Flutter **>= 3.27** (Dart >= 3.6). Validado com **Flutter 3.44.4** (stable):
  `flutter analyze` sem issues, `flutter test` 3/3 e `flutter build web` OK.

## Como rodar

```bash
cd app
flutter pub get        # baixa flame, riverpod, go_router, google_fonts, intl
                       # e gera lib/l10n/app_localizations.dart (gen-l10n)
flutter analyze        # análise estática (esperado: No issues found!)
flutter test           # testes de parsing dos mocks (esperado: All tests passed!)
flutter run -d chrome  # web desktop (alvo primário)
# ou: flutter run -d <android-device>
```

> `google_fonts` busca Inter na primeira execução (precisa de rede). Para produção,
> bundlar os arquivos de fonte e trocar por `TextTheme` local.

## O que já existe (Fase 0 + Fase 4 do plano)

- **Tema a partir de tokens** — `lib/app/theme/` espelha
  `../design-system/tokens/colors.json` (paleta Marte verificada por contraste,
  light + dark). `ColorScheme` + `DsTokens` (ThemeExtension: espaçamento 4px,
  raios, motion, cores semânticas). Dark-first.
- **Ponte Flutter ↔ Flame** — `features/world_map/` renderiza o mapa/lote isométrico
  no Flame (`GameWidget`) e o **HUD de recursos** como `overlay` Flutter por cima.
- **Costura de mock data** — `domain/repositories/` (interfaces) → `data/mock/`
  (lê `assets/fixtures/*.json` com latência simulada) → `data/providers.dart`
  (Riverpod). Trocar mock por API num só lugar.
- **Shell adaptativo** — `NavigationRail` (desktop) / `NavigationBar` (Android),
  via `go_router` `StatefulShellRoute`.
- **Capital** — grid dos 20 slots de instituição com estados loading/erro.
- **i18n** — pt (default) / es / en em `lib/l10n/*.arb`.

## Ainda placeholders (fases 6+ do plano)

Mercado, Espaçoporto, Chat (5 canais), Perfil/avaliações, Reputações (denúncia +
Conciliador), Frota, Cargos Públicos, Leilões, Federações, Luas/Gagarin. O **Ranking
de Guerras** está bloqueado até o GDD §15 ser preenchido.

## Estrutura

```
lib/
├── main.dart                 # ProviderScope + FertwaysApp
├── app/
│   ├── app.dart              # MaterialApp.router (tema, i18n, rotas)
│   ├── router.dart           # go_router StatefulShellRoute
│   └── theme/                # ds_colors · ds_tokens · ds_theme (dos tokens DTCG)
├── domain/{models,repositories}
├── data/{mock,providers.dart}
├── features/{shell,hud,world_map,capital,common}
└── l10n/                     # app_pt/es/en.arb
assets/fixtures/              # player.json · capital.json (mock)
```

## Notas de verificação (honestidade)

- **Tokens**: verificados na fonte por `design-system/scripts/validate_tokens.py`,
  `validate_contrast.py` (AA, light+dark) e `check_no_emoji.py` — todos passam.
- **Dart/Flutter** (Flutter 3.44.4): `flutter analyze` → No issues found; `flutter test`
  → 3/3; `flutter build web` → ✓ Built build/web (compatível com Wasm). Plataformas
  web + android adicionadas via `flutter create . --platforms web,android`.
