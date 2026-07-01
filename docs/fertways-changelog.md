# Fertways — Evolução / Changelog de design e build

Registro cronológico das decisões e marcos (frontend). Mais recente no topo.

## 2026-07-01

### Etapa 22 — De-mock POR JOGADOR + Mercado transacional + ações reais
- **Frota/Missões/Federação agora por jogador** (não mais config compartilhado): colono recém-registrado
  começa limpo; o jogador de demonstração (Vale) mantém o conteúdo rico via seed.
  - Frota: registros `Vehicle` por dono + `Colony.fleetSlots`; `GET /fleet`; frota inicial no registro
    (Furgão + Robô Minerador). Ações reais: **Manutenção** (cobra Fert$, restaura condição) e **Sucateamento**.
  - Missões: board em `Player.missionState` (JSON); novo = board fresco (streak 0, conquistas travadas);
    **resgate real** `POST /missions/:id/claim` credita Fert$ pelo livro-razão.
  - Federação: filiação = `FederationMember`; não-membro vê estado vazio ("Você ainda não está em uma
    federação"); `GET /federation`.
- **Mercado Central transacional**: `GET /market/board` (ordens reais com ids reais) + botão **Comprar**
  (`POST /market/listings/:id/buy`, diálogo de quantidade, escrow, taxa 3%, livro-razão) + botão **Vender**
  (`POST /market/listings`). Vendedores NPC semeados. HUD/board atualizam após a operação.
- **Perfil/Leilões por jogador**: `/me` traz federação+setor (chip da federação real); `GET /auctions` mostra
  o nível real do jogador.
- **Limpeza**: `app/lib/data/mock/*` removido (código morto).
- Migração Prisma `per_player_fleet_missions_federation`; novos módulos NestJS fleet/missions/federation/auctions.
- **Validação**: `jest` 11/11 · `flutter analyze` limpo · `build web` ✓ · clique-a-clique de TODAS as telas OK
  (sem erro de fromJson) · isolamento por jogador confirmado via API e no Chrome (Vale vs. NovatoTest).
- Relatório: `docs/reports/22-backend-per-player.{html,pdf}`.
- Dívidas: ações do Comércio Informal (Acordo/Negociar) e lances de Leilão seguem board/preview.

### Integração frontend ↔ backend — FRONTEND TOTALMENTE DES-MOCKADO
- Cliente Flutter conectado ao backend NestJS: `dio` + auth (JWT/refresh, LoginScreen, gate no roteador),
  token em SharedPreferences. `providers.dart` binda **todos** os repositórios a implementações `Api…` —
  **zero mock em runtime**.
- Dinâmico (endpoints próprios): auth, /resources, /colony+/me, /spaceport, /me→perfil, /notifications,
  /lunar, /terraform, /build-queue (fila real autoritativa: colônia POSTa /colony/build|upgrade), /market
  (escrow+ledger). Mercado com escrow + taxa 3% + livro-razão Fert$.
- Config estática (canônica do jogo) via **GET /config/:key**: seed lê os 14 fixtures de referência
  (market, informal, auctions, missionsBoard, fleet, federation, disputes, rankings, offices, chat, capital,
  ministries, planet, combat) → `ServerConfig`; 11 Api repos fazem `Model.fromJson(get('/config/:key'))`.
- Contratos mapeados por agentes (fromJson exato, sem perda). analyze limpo + build web ✓. **Tudo em main.**
- Pendências: verificação visual das telas recém-ligadas; fleet/missions/federation → dados por-jogador;
  ações de trade → /market/buy; remover `lib/data/mock/*` (dead code).

### GDD v33 Mestre Integral adotado como fonte de verdade
- **`FERTWAYS_GDD_v33_MESTRE_INTEGRAL_SEM_SUPRESSOES.html`** supera a v29. Edição **aditiva**: v3.0
  integral (Parte II) + v3.2 sanitizada (Parte I) + **§0 tabela de precedência** (12 conflitos resolvidos)
  + **§28** correções. Implementar sempre as **decisões vigentes do §0**, não o registro antigo.
- Deltas v33 sobre telas existentes — **reconciliados**: §28.1 Gagarin em órbita (no C1) · **Central de
  Transportes** reframada de "caminhões-base incluídos" para **"vagas de frota"** (o nível libera vagas;
  veículo é fabricado/adquirido à parte — §0 supera §19.5/§28.5; `TransportLevel.trucks`→`slots`) ·
  **Proteção de novato = 8 dias** (§28.4 supera §27.11 "20 dias"; `combat.dart` + `zone_screen.dart`).
  **N/A:** §28.8 Mercado Local (tabela de custo não exibida) · Predador (unidade não modelada).

### Bloco C — C5 i18n PT-BR/ES/EN CONCLUÍDO (Bloco C completo)
- Idioma trocável ao vivo: `data/locale_controller.dart` (`NotifierProvider<LocaleController, Locale?>`) →
  `app.dart` (ConsumerWidget) → `MaterialApp.locale`. Seletor no HUD (`_LanguageMenu`, ícone de globo:
  Português/Español/English, marca no atual). Troca reflete na hora, sem recarregar.
- Chrome traduzido nos 3 idiomas (ARB pt/es/en): nav rail, ações da barra inferior (Construir/Recrutar/
  Pesquisar/Relatórios/Missões/Mensagens), "Online", "em breve" e estados comuns. Barra inferior roteia por
  chave estável (`_ShellAction`), não pelo texto. Números do HUD (intl) acompanham o locale (14.280 ↔ 14,280).
- Relatório PDF `docs/reports/21` + spec OpenSpec `i18n-locale`. **Dívida:** strings do corpo de cada tela
  seguem pt-BR (extração incremental grande) · persistência do idioma entre sessões. **Bloco C (C1–C5) completo.**

### Bloco C — C4 Fluxos reais de construção/upgrade CONCLUÍDO
- **Primeiro estado mutável do app**: `build_queue.dart` (QueuedBuild com getters vivos + `buildSeconds`
  curva 1.5×) + `data/build_queue_controller.dart` (`NotifierProvider<BuildQueueController, BuildQueueState>`
  + Timer 1s; enqueue/cancel/finishAll; obras concluídas saem sozinhas). Riverpod era 100% read-only.
- `construction_panel.dart` (antes definido mas nunca montado) virou ConsumerWidget que lê a fila e
  mostra contagem regressiva ao vivo + cancelar + "Concluir agora" + fila dupla (2 vagas, §20.2). Montado na
  Colônia. Enfileiram: `colony_screen.dart` (build+upgrade, agora ConsumerStatefulWidget) e `zone_screen.dart`
  (estruturas §17.4, agora ConsumerWidget). Relatório PDF `docs/reports/20` + spec OpenSpec `construction-queue`.
- Dívidas: dedução de recursos (resources read-only) · nível persistente ao concluir · upgrades de ministério.

### Bloco C — C3 Terraformação Global CONCLUÍDO
- Nova tela `/map/terraform` (drill-in do Mapa): `terraform.dart` (TerraformState/TerraformTrack + enum
  TerraformIndicator)/`TerraformRepository`/`terraform.json`/`terraformProvider` → `terraform_screen.dart`.
- §04 + §12.3: três indicadores públicos (atmosfera/ciclo hídrico/biosfera) rumo a 75% (o menor determina
  o gatilho); "Sua contribuição" com teto diário **anti-farming**, total e recompensa **+Status Cívico**
  (nunca vantagem econômica); gatilho da T2 = "Janela de Órbita Lunar". Relatório PDF `docs/reports/19` +
  spec OpenSpec `terraformation`. Entradas: chip "Terraformação" no mapa + botão na tela lunar (C1).

### Bloco C — C1 Exploração Lunar / Telescópio Gagarin CONCLUÍDO
- Vertical slice completo (modelo → repo → mock → `lunar.json` → provider → tela → rota drill-in
  `/spaceport/lunar` → 2 entradas) + validação (analyze limpo, build web ✓) + **relatório PDF**
  `docs/reports/18-c1-exploracao-lunar.html/.pdf` + spec OpenSpec `lunar-exploration`.
- Conteúdo (§12 + §28.1–28.2): status do **Telescópio Gagarin** com gatilho de ativação (50 jogadores
  OU 45 dias), **boletins** por categoria, catálogo das **8 luas** (homenagem ↔ atmosfera ↔ recurso
  raro), **marco de 75% de terraformação** = gatilho T2 + evento "Janela de Órbita Lunar", e **prévia
  bloqueada** das bases lunares (só T2, §12.4). 8 recursos raros adicionados a `resource_visual.dart`.
- Entradas: cartão no **Espaçoporto** + atalho na **Central de Pesquisas e Notícias** (Capital slot 3).

## 2026-06-30

### Decisão: cliente WEB-ONLY (remoção do Android)
- Removida a pasta `app/android/` — o build Android exigia Android SDK + JDK, que sobrecarregam a
  **VPS de deploy** (server.tars.art.br). O cliente passa a ser **web-only**; o empacotamento mobile
  será feito depois via **WebView** (wrapper nativo separado apontando pro web build).
- Efeito prático: a VPS só precisa de `flutter build web` (sem SDK/JDK Android). Docs, `app/README.md`
  e a memória (`fertways-stack`) atualizados. NÃO recriar `android/`/`ios/` no projeto Flutter.

### Bloco B — profundidade (B0–B10) CONCLUÍDO
- Cada etapa = vertical slice (modelo → repositório → mock → fixture → provider → tela → rota → entrada)
  + validação (analyze limpo, build web ✓, test) + **relatório PDF** em `docs/reports/` + spec OpenSpec.
- **B0** Zonas Neutras · **B1** Ministérios da Capital · **B2** Comércio Informal + Antifraude ·
  **B3** Mensagens (§10) · **B4** Federações (§4) · **B5** Reputações/Justiça (§9) ·
  **B6** Missões/Conquistas/Eventos (§6) · **B7** Frota (§21/§16.4) · **B8** Cargos Públicos (§14) ·
  **B9** Leilões (§13, gate Nível 100) · **B10** Centro de Notificações (transversal, cor+forma).
- Padrão consolidado: **drill-ins** dentro do shell (mantêm HUD/nav); ações de escrita = mock (SnackBar);
  i18n pt hard-coded (dívida conhecida). Loja AbacatePay (dinheiro real) fora de escopo (backend adiado).

### GDD v29 adotado + reconciliação (R1–R3, Economia §24, Combate §27)
- **v29 vira a fonte** (supera v24; §1–§22 mantêm os números, v29 adiciona §24–§27).
- **R1** Comércio Informal reconciliado (§25 logística física, §26.5 Acordo de Troca). **R2** Perfil
  (§26 4 índices 0–1000 + §24.3 Diário). **R3** Rankings (§27.13 percentil).
- **Economia §24** (Metal Bruto, Mina Local, Destilaria, receitas §24.5, subsídio §24.7, preços §24.8)
  no HUD/Colônia/Mercado. **Combate §27** (Sentinela, rodadas, saque, novatos) na tela de Zona.

### GDD v24 adotado + reconciliação + Marco A
- **v24 vira a fonte** (supera v21/v17). Economia completa: §15 Guerras, §18 Recursos,
  §19 Produção, §20 Custos, §21 Veículos, §22 Preços — todos preenchidos.
- **Reconciliação aos números reais:** HUD ganha **Oxigênio**, "Metais Ferrosos" →
  **Ligas Metálicas**, + **Componentes Eletrônicos**. Colônia usa produção §19
  (`Base×1.5^(N-1)`, níveis ≤5; Gerador de Atmosfera, Aquífero Profundo +90% §19.7).
  Mercado usa preços-base §22 (frações de Fert$, `unitPrice` virou `double`).
- **§15 Ranking de Guerras** (era bloqueio de design no v17/v21) → **construído**:
  `/capital/rankings` (do Min. Segurança e Guerra), Ranking Geral (pesos §15.3) + 6 sub.
- **A2 Espaçoporto** (`/spaceport`) e **A3 Perfil** (`/profile`) construídos → **Marco A
  atingido**: as 5 abas sem placeholder.

### Correção de modelo #2 (Colônia ↔ Capital) — v21 §17
- Releitura: a Colônia do colono é um **Slot com CONSTRUÇÕES** (Fazenda, Captação, Reator,
  Oficina, Refinaria, Gerador de Atmosfera) + especialização. A **Capital** é o **governo**
  (20 instituições). Tela `/map/colony` reconstruída com as construções reais do §17 (não
  "lotes"). "Entrar na Capital" mantido (botão).

### Correção de modelo #1 (Colônia = lotes ❌) — revertida
- 1ª tentativa: "Colônia com lotes de recurso" (anel de água/metais/... ao redor da Capital)
  — convenção Travian/Ikariam, **não existe no GDD** (palavras lote/terreno/campo ausentes).
  Resíduo: recurso vem das **zonas neutras** (Robô Minerador). Arquivos arquivados em
  `docs/t2-shelf/colony-view/` (reuso p/ bases lunares T2). Tela `/map/zone` construída.

### Mapa-Planeta (redesign do `/map`)
- `/map` deixou de ser "colônia radial mock" e virou **mapa-PLANETA macro** (decisão do
  usuário): sua colônia + vizinhas + zonas neutras + espaçoporto + marcos, com **biomas por
  bússola** e câmera **cover** (sem borda preta) + pan travado. Arte do terreno: **v6**
  (`mars-solar-frontier-map-v6.png`, gerada pelo usuário, biomas alinhados à bússola).
- Polish: lotes livres claimáveis, realce de seleção, feedback (SnackBar), rótulos de marco.

### Fundação (início)
- App Flutter+Flame, tema Solar Frontier (claro/futurista), shell adaptativo + go_router,
  HUD de recursos, Capital (20 slots), i18n base pt/es/en. Tokens DTCG → tema.

## Princípios aprendidos (não repetir erros)
1. **Sempre validar o modelo no GDD antes de construir** (lote vs construção; colônia vs
   Capital) — o usuário pega divergências. Quando o GDD tem lacuna, **não inventar**.
2. **Cada nova versão de GDD** (v17→v21→v24) pode encher lacunas e mudar números → reconciliar.
3. **Cache de asset no http.server** local: usar porta nova por mudança de fixture (uma viva).
4. **Arte:** ao trocar, mover a antiga para `docs/visual-history/` e documentar.
5. **Cada etapa concluída** gera relatório PDF em `docs/reports/` (`gen-pdf.sh`) + spec OpenSpec.
6. **Ambiente ≠ código:** falha de "No Android SDK" na VPS era ambiente, não bug — levou à decisão
   web-only. Confirmar sempre se um erro é do código ou da máquina antes de mexer no projeto.
7. **go_router (web):** navegar por URL entre sub-rotas irmãs pode não trocar a tela; `context.go`
   pelo botão real funciona. Preferir testar a navegação pelo elemento, não pela barra de endereço.
