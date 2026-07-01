# Fertways — Roadmap de Desenvolvimento Frontend (incremental)

> **Modo de trabalho:** uma página por vez, na ordem abaixo. Para cada página:
> 1. Implementação completa (tela + seam de repositório mock + fixtures + i18n pt/es/en + ícones vetoriais).
> 2. Revisão/validação (funcional, consistente, integrada).
> 3. **Gerar relatório PDF** completo da etapa em `docs/reports/` (regra do projeto — ver `docs/reports/README.md`).
> 4. **Aguardar validação do usuário** antes de iniciar a próxima.
>
> Alterações em outras páginas só o **mínimo necessário** (componentes/rotas/navegação compartilhados).
>
> **Escopo:** frontend/visual apenas — sem backend. Tudo atrás de interfaces de repositório trocáveis pela API real.
> **Stack:** Flutter + Flame · Riverpod · go_router · tokens DTCG (Solar Frontier) · sem emoji.

---

## Legenda de status
- ✅ Concluído e verificado
- 🟡 Parcial (existe mas precisa de evolução)
- ⬜ A fazer
- ⛔ Bloqueado (depende de conteúdo do GDD)

## Critério de pronto (Definition of Done) — vale para toda página
- [ ] `flutter analyze` → **No issues found**
- [ ] `flutter build web --pwa-strategy=none --no-tree-shake-icons` → **✓ Built**
- [ ] Seam de repositório: interface em `domain/repositories` + impl mock em `data/mock` + fixture(s) JSON + provider em `data/providers.dart`
- [ ] Estados explícitos: **loading / empty / error / sucesso** (latência/erro simulados no mock)
- [ ] Sem valores hard-coded (cores/spacing/tipografia via `DsTokens`/Theme) · sem emoji (ícones Material/vetoriais)
- [ ] Textos via chaves ARB (pt-BR default, es, en)
- [ ] Responsivo: desktop multi-painel + mobile/touch adaptativo (≥48dp de toque; web via WebView)
- [ ] Integrado à navegação (`go_router`) e ao HUD/estado compartilhado quando aplicável
- [ ] **Relatório PDF da etapa** gerado em `docs/reports/` (`./gen-pdf.sh`)

---

## Fundação (já entregue) — base do incremento
| # | Item | Status | Notas |
|---|------|--------|-------|
| F1 | Tema/tokens "Solar Frontier" (`lib/app/theme/`) | ✅ | claro/futurista, AA verificado |
| F2 | Shell adaptativo (`features/shell/app_shell.dart`) + go_router | ✅ | NavigationRail + bottom action bar |
| F3 | Mapa-mundo Flame (`features/world_map/`) + arte de Marte + 8 sprites | ✅ | pan/zoom/tap, painéis de detalhe/construção |
| F4 | HUD de recursos (`features/hud/resource_hud.dart`) | ✅ | barra superior Fert$ + 5 recursos |
| F5 | Capital — 20 slots (`features/capital/capital_screen.dart`) | ✅ | grid, slot livre/instalar |
| F6 | i18n pt/es/en (ARB) | ✅ | base pronta para novas chaves |
| F7 | **Mapa-PLANETA** (macro MMO): colônias+zonas neutras+espaçoporto+marcos, bioma por região, câmera com fit/trava, toque→Capital | ✅ | redesign de F3; arte do terreno pendente (usuário gera) |

---

## BLOCO A — Completar as abas visíveis da navegação
> Objetivo: zerar todos os `PlaceholderScreen`. App 100% navegável sem stubs.

### A1 — Mercado Central  `/market`  ✅  · GDD §13 (Economia/Loja) + §8 (Comércio Informal)
- ✅ Tela `/market` (substituiu placeholder): **tickers** dos 5 recursos (preço + variação %),
  **filtros** por recurso + lado (Comprar/Vender), **lista de ordens** com qty/preço/total,
  trader (nome·setor·★avaliação) e **chip "Risco"** quando reputação < 3.5 (sinal de calote §8).
  `MarketRepository`/`MockMarketRepository`/`market.json`/`marketBoardProvider`. Negociar = mock (SnackBar).
- Futuro: tela de detalhe da ordem, criar ordem, histórico, `ReputationRepository` cheio.

### A2 — Espaçoporto  `/spaceport`  ✅  · GDD §3 (Espaçoporto e Planetas NPC)
- ✅ 5 planetas NPC (Kalidor/Veyra/Auryn/Solène/Drakmoor) com distância, **risco** (chip cor), Exporta/Importa, "Enviar carga"; chip de frota (Cargueiros). `SpaceportRepository`/`spaceport.json`/`spaceportProvider`.

### A3 — Perfil público  `/profile`  ✅  · GDD §5 (Progressão) + §8/§9 (reputação)
- ✅ Avatar, título/setor/federação, **★0–5 + avaliações recebidas** (§8.4), nível/XP, **escada de progressão 1–100** (§5, atual=Pioneiro), estatísticas. `ProfileRepository`/`profile.json`/`profileProvider`.
- ✅ **R2 (reconciliação v29):** **Reputação = 4 índices** independentes 0–1000 (Confiança Comercial/
  Conduta Social/Status Cívico/Honra Militar, §26.2, com "Afeta:" e barra por saúde) + **Diário do Colono**
  (§24.3: marco + nota pessoal + selo Privado/Público). ★ mantido como média das avaliações de comércio.
  Relatório `docs/reports/06-...pdf`.

**➡️ Marco A ✅ ATINGIDO:** navegação principal completa (Mapa · Capital · Mercado · Espaçoporto · Perfil) — **sem placeholders**.

### A4 — Reconciliação ao GDD v24  ✅  (números reais)
- ✅ HUD: +**Oxigênio**, "Metais Ferrosos"→**Ligas Metálicas**, +**Componentes Eletrônicos** (`player.json`).
- ✅ Colônia: produção pela fórmula §19 (`Base×1.5^(N-1)`, níveis ≤5); Gerador de Atmosfera (O₂); Aquífero Profundo (+90% §19.7).
- ✅ Mercado: preços-base do §22 (frações de Fert$, `unitPrice` double).

### §15 — Ranking de Guerras  ✅  (era ⛔, desbloqueado pelo v24)
- ✅ Tela `/capital/rankings` (do Ministério da Segurança e Guerra): **Ranking Geral** (pesos §15.3 25/20/20/15/10/10%) + **6 sub-rankings** (§15.2), leaderboard com **VOCÊ** + federações. `RankingRepository`/`rankings.json`.
- ✅ **R3 (reconciliação v29):** **normalização por percentil** (§27.13) — Ranking Geral em **escala 0–100**
  (soma ponderada de percentis, com exemplo no cabeçalho); cada entrada de sub-ranking mostra
  **percentil no servidor**; saque convertido a Fert$ equivalente. Relatório `docs/reports/07-...pdf`.

---

## BLOCO B — Profundidade econômica, social e administrativa
> Entradas a partir do que já existe (Capital, HUD, Perfil, Mercado) + novos pontos de acesso.

### 📐 Modelo (GDD v21 — fonte atual; `FERTWAYS_GDD_v21.html`)
Três lugares distintos (3 níveis):
- **Planeta** (mapa macro) — sua Colônia + vizinhas + zonas neutras + espaçoporto.
- **Colônia = Slot do colono** (v21 §17) — base com **CONSTRUÇÕES**: produção (Captação de
  Água, Oficina, Fazenda, Reator, Refinaria Química), estrutura (Estrutura de Sobrevivência,
  Gerador de Atmosfera), militar (Quartel), transporte (Central de Transportes, Plataforma de
  Pouso) + **slots livres** + **especialização** (1 de 15). Produz os 5 recursos do HUD.
- **Capital** (§2.1) — os **20 slots de instituição de GOVERNO** (Admin, Tributos, Reputações…),
  públicos (Cargos Neutros). Separada da colônia; alcançada pelo botão "Capital".
- Fluxo: Planeta → tocar colônia → **Colônia/Slot** (`/map/colony`) → botão "Capital" → `/capital`.
- Recurso extra vem das **zonas neutras** (ocupar c/ Robô Minerador → extrair → Caminhão, §7/§16).
- ✅ **Colônia/Slot CONSTRUÍDA (v21)**: `colony_buildings`/`colony.json`/`colony_game`/`colony_screen`.
- **Lacunas do GDD v21 (não inventar):** §15 Ranking de Guerras, §18 Recursos Completos,
  §19 Balanceamento, §20 Custos de Construção — títulos no índice, corpo vazio.

### B0 — Zonas Neutras: ocupar / extrair / transportar  ✅  · GDD §7 + §16 + §17.4
- ✅ Tela `/map/zone` (drill-in do planeta, `state.extra` = MapNode): **Ocupar** (Robôs por nível,
  20+lvl*20), **Depósito** (10 níveis, barra), **Estruturas** do §17.4 (Posto de Comando, Depósito,
  Extração, Abrigo, Muralha, Torre de Vigia, Refinaria de Campo), **Transporte** aos 4 destinos.
- Painel da zona no mapa → "Gerenciar zona" abre a tela. Ações mock (SnackBar).
- Futuro: estado real (livre/ocupada), recrutar robôs no Quartel, ataques (4 tipos).

### B1 — Ministérios da Capital  ✅  · GDD §2 (slots) + §14
- ✅ Cada slot instalado da Capital abre uma **tela de ministério** (`/capital/ministry`, drill-in
  do shell, `state.extra` = `InstitutionSlot`). Layout comum `MinistryScaffold` (voltar + identidade
  do slot + função §2.1 + chip de nível) + corpo por `kind`.
- ✅ Painéis: **Finanças/Tesouro** (saldo/PIB/receita/despesa + fluxo de caixa), **Tributos**
  (alíquotas §8.3 3/2/1% + isenção federação + arrecadações), **Pesquisas/Notícias** (Gagarin §12.1 +
  feed Gagarin/Evento/Oficial), **Administração** (leis/punições/recompensas + cargos §14),
  **Segurança/Guerra** (guerras/tratados + atalho ao Ranking §15), **Estacionamento** (20 vagas,
  taxa/hora, ocupação), **Transportes** (registro de placas §16.3 + depreciação §16.4), **Depósito
  Central** (capacidade por recurso), **Central de Transportes** (10 níveis §19.5). **Reputações** =
  stub que aponta para B5 (sem dados falsos).
- Seam: `MinistryRepository`/`MockMinistryRepository`/`ministries.json`/`ministriesProvider`. Ações
  de escrita = mock (SnackBar). i18n: pt hard-coded (consistente com rankings/zone — dívida conhecida).
- Futuro: ações reais (evoluir/instalar), Reputações completo (B5), Cargos públicos (B8), Frota (B7).

### B2 — Comércio Informal + Antifraude  ✅  · GDD §8
- ✅ Tela `/market/informal` (drill-in do Mercado, botão "Comércio informal" no header). **Banner
  antifraude §8.1** (sem garantias/árbitro; calote real). Abas: **Ofertas · Histórico · Como funciona**.
- ✅ Ofertas: swap **Você recebe ↔ Você envia**, **reputação 0–5★** + nº avaliações, **chip "Risco de
  calote"** (<3.5, borda+botão atenuados) vs **"Verificado"** (≥4.8), badge federação + **isenção**,
  **preview de tributo §8.3** (3/2/1% calculado sobre o envio), stats **negociações/sucesso/calotes**.
  Filtros: Tudo/Confiáveis/Federação.
- ✅ Histórico: trocas sucesso/calote + **avaliação dada** + denúncia (→ B5). "Como funciona" = fluxos
  §8.2 (sucesso vs calote) + card de tributação §8.3.
- Seam: estende `MarketRepository.loadInformalBoard()` → `informal.json` → `informalBoardProvider`;
  `informal_trade.dart` (InformalBoard/Offer/TradeLeg/History). `resource_visual.dart` compartilhado
  com o Mercado (DRY). Ações = mock (SnackBar). i18n pt hard-coded (dívida conhecida).
- Futuro: propor/aceitar troca real, `ReputationRepository` cheio, avaliação pós-troca interativa.
- ✅ **R1 (reconciliação v29):** §25 logística física (tributo único na entrega; veículo obrigatório
  Furgão 6m³/Caminhão 30m³; distância→tempo/energia §25.6); **Confiança Comercial 0–1000** (§26.2)
  na oferta; **Acordo de Troca** "aperto de mão digital" (§26.5) na ação, em "Como funciona" e no
  histórico (acordo expirado → denúncia pré-preenchida). Relatório `docs/reports/05-...pdf`.

### B3 — Sistema de Mensagens  ✅  · GDD §10
- ✅ Tela `/map/messages` (drill-in; acessível pela ação "Mensagens" da barra inferior). **5 canais**
  (Global/Região/Federação/MP/Vizinhança) com seletor + badge de não-lidas; cabeçalho com escopo +
  **indicador de moderação §10.2** (públicos = automática; Federação/MP = só denúncia manual).
- ✅ Thread com bolhas (suas à direita), **denúncia por mensagem** (→ Reputações §9), **tag de idioma +
  nota §10.4** (mostrado no idioma do remetente), compositor (envio mock).
- Seam: `ChatRepository`/`MockChatRepository`/`chat.json`/`chatProvider`. Relatório `docs/reports/10-...pdf`.
- Futuro: enviar/denunciar reais, tradução automática (§10.4), histórico de MP como evidência (§10.3).

### B4 — Federações  ✅  · GDD §4
- ✅ Tela `/profile/federation` (drill-in do Perfil; chip da federação no Perfil ficou clicável com chevron).
  **Identidade**: emblema + nome/tag `[PBO]` + lema + chip "12/12 membros" + cargos (Líder/Diplomata).
- ✅ **Tesouro**: saldo do fundo (Fert$) "mantido na Capital (§4)", **barra da taxa de contribuição** na
  faixa **1–10%** (padrão **3%**) e aporte do jogador no dia. **Tributação & Mercado (§4)**: interna
  grátis até **35%**/35% acima · **50%** entre aliadas · antimonopólio dinâmico **20%→10%**.
- ✅ **Membros (até 12)**: avatar + presença, "VOCÊ", badge de cargo, setor·nível e aporte diário,
  ordenados por cargo→contribuição; **aliadas** com badge "−50% troca"; atalho "Abrir chat" (§10).
- Seam: `FederationRepository`/`MockFederationRepository`/`federation.json`/`federationProvider`;
  `federation.dart` (Federation/FederationMember/FederationAlly/FederationRole). Ações = futuras.
  Relatório `docs/reports/11-b4-federacoes.pdf`.
- Futuro: entrar/sair/fundar, contribuir/sacar do fundo, diplomacia (propor/aceitar aliança), admin do Líder.

### B5 — Ministério das Reputações (Justiça)  ✅  · GDD §9
- ✅ Slot Reputações do `/capital/ministry` (antes stub) virou o painel completo: **dashboard** (KPIs em
  aberto/resolvidas/apeladas/conciliadores + fila com filtro Abertas/Resolvidas/Apeladas/Todas) e **detalhe
  inline** do caso. **Fluxo §9.2** de 5 passos (Abertura→Triagem automática→Conciliador→Decisão→IA futura)
  com o passo atual destacado.
- ✅ **Estados auditáveis** (status pill): em triagem · em análise · julgado · punido · apelado · improcedente.
  Detalhe traz **evidências** (texto/captura/log/histórico, mín. obrigatória §26.8), **conciliador** (ou
  equipe nos graves), **decisão/punição §9.4** (advertência·redução·silêncio·restrição·bloqueio/Persona Non
  Grata) com selo de apelação, **histórico auditável** (timeline) e **ações admin** mock. **Conciliadores
  §9.3/§26.7**: casos/reversões + Ativo/Suspenso. Denúncia pré-preenchida por Acordo de Troca expirado (§26.5).
- Seam: `ReputationRepository`/`MockReputationRepository`/`disputes.json`/`disputesProvider`; `dispute.dart`
  (Dispute/DisputeBoard/Conciliator/Evidence/DisputeEvent + enums). Painel em `reputation_panel.dart`
  (stub `ReputationStubPanel`+`_FlowStep` removidos). Relatório `docs/reports/12-b5-reputacoes.pdf`.
- Futuro: ações reais (atribuir/decidir/punir), upload de evidência, triagem por IA (§9.2 passo 5).

### B6 — Progressão, Missões, Conquistas e Eventos  ✅  · GDD §5 + §6
- ✅ Tela `/map/missions` (drill-in; acessível pela ação "Missões" da barra inferior). **3 abas**
  (Missões · Conquistas · Eventos) + **resumo** (diárias X/3, sequência, nº para resgatar, conquistas).
- ✅ **Missões** agrupadas pelos **7 tipos §6** (Tutoria 5×dias 1–3 com divulgação progressiva · Diária 3/dia
  pool 30+ com **1 rejeição** "Trocar" · Semanal Qua→Ter · Narrativa · Federação 2/sem · Guerra pool contínuo ·
  Evento): barra de progresso, recompensa (Fert$/XP/itens), janela, estados Disponível/Em progresso/Pronta
  (Resgatar)/Resgatada/Bloqueada.
- ✅ **Conquistas** Bronze/Prata/Ouro/Platina (cor por tier; obtida vs cadeado+barra). **Eventos** ativos
  (Gagarin §12.1 · tempestade · guerra §27 · mercado) com tipo/cor e tempo restante. Progressão 1–100 (§5)
  permanece no Perfil (não duplicada).
- Seam: `MissionRepository`/`MockMissionRepository`/`missions.json`/`missionBoardProvider`; `mission.dart`
  (Mission/Achievement/GameEvent/MissionBoard + enums). Ações = mock. Relatório `docs/reports/13-b6-missoes.pdf`.
- Futuro: resgatar/trocar reais (creditar recompensa), pool dinâmico de diárias, capítulos de narrativa.

### B7 — Frota + Ministério dos Transportes  ✅  · GDD §16 + §21
- ✅ Tela `/map/fleet` (drill-in; botão "Frota" na Colônia, ao lado de "Capital"). **8 tipos de veículo §21**
  (Furgão 6m³ · Caminhão 30m³ · Drone · Robô Minerador · Nave Longa Distância · Nave Transporte Planetária ·
  Tanque de Combustível · Cargueiro). **Resumo**: hangar X/Y, em trânsito, p/ manutenção, capacidade total m³.
- ✅ Cada veículo: placa, capacidade, horas de uso, **situação** (Ocioso/Em trânsito/Carregando/Manutenção/
  **Bloqueado**), **barra de condição** por saúde, **depreciação §16.4** (só Furgão/Caminhão, com limite
  crítico → bloqueio) ou "sem depreciação", tarefa atual e ações **Manutenção (Fert$)/Despachar/Sucatear** (mock).
  Lista ordenada por urgência. Registro de placas (§16.3) permanece no Ministério dos Transportes (não duplicado).
- Seam: `FleetRepository`/`MockFleetRepository`/`fleet.json`/`fleetProvider`; `fleet.dart` (Vehicle/FleetBoard +
  enums VehicleKind/VehicleStatus). Relatório `docs/reports/14-b7-frota.pdf`.
- Futuro: manutenção/despacho/sucateamento reais; ligar despacho à logística §25; painel admin de sucateamento.

### B8 — Cargos Públicos Neutros + Admin  ✅  · GDD §14
- ✅ Tela `/capital/offices` (drill-in da Capital; botão "Gerir" da Administração Pública). **Aba Cargos**:
  cartão de **elegibilidade §14.3** (7 critérios cumpridos/pendentes) + os **5 cargos** (Conciliador · Fiscal
  de Mercado · Atendente do Espaçoporto · Repórter · Auxiliar de Tesouro) com instituição, descrição, salário,
  **índice §26.6**, vagas/ocupantes (desde+desempenho) e **Candidatar-se** (habilitado só se elegível).
- ✅ **Aba Administração §14.4**: candidaturas pendentes (selo Elegível/Não elegível; Aprovar desabilitado p/
  inelegível) + Aprovar/Recusar; ocupantes atuais com Suspender/Demitir; pagamentos recentes (salário/bônus).
- Seam: `PublicOfficeRepository`/`MockPublicOfficeRepository`/`offices.json`/`publicOfficeProvider`;
  `public_office.dart` (PublicOffice/OfficeHolder/OfficeCandidate/OfficePayment/EligibilityCriterion/Board +
  enum OfficeKind). Ações = mock. Relatório `docs/reports/15-b8-cargos.pdf`.
- Futuro: candidatar-se/aprovar/suspender/demitir reais; elegibilidade derivada do estado real do jogador.

### B9 — Leilões  ✅  · GDD §13
- ✅ Tela `/market/auctions` (drill-in do Mercado; botão "Leilões" no header). **Casa de leilões de peças
  únicas** que desbloqueiam no **Nível 100 (Lenda)** — como o colono está no nível 14, é uma **prévia com
  lances bloqueados** (banner com barra 14/100 + nota Persona Non Grata §9.4 / Confiança Comercial §26.2).
- ✅ **Aba Ativos**: lotes com raridade (única/lendária/rara, cor por tier), cronômetro (Ativo/Encerrando),
  lance atual (Fert$), nº de lances, líder ("Você lidera"), próximo lance mín. e botão **Dar lance**
  (desabilitado "Nível 100" enquanto travado). **Aba Histórico**: encerrados (vencedor/dia/preço final).
- Seam: `AuctionRepository`/`MockAuctionRepository`/`auctions.json`/`auctionHouseProvider`; `auction.dart`
  (AuctionItem/AuctionRecord/AuctionHouse + enums). Relatório `docs/reports/16-b9-leiloes.pdf`.
- **Fora de escopo:** loja AbacatePay (PIX/cartão = dinheiro real) — backend adiado, sem fluxo de pagamento.
- Futuro: dar lance real, cronômetro com contagem regressiva, loja AbacatePay quando houver backend.

### B10 — Centro de Notificações  ✅  · transversal
- ✅ Tela `/map/notifications` (drill-in; **sino do HUD** agora clicável com **badge de não-lidas** lendo o
  provider). Agrega eventos de todos os sistemas (guerra §27, Reputações §9, Gagarin §12.1, mercado, missões
  §6, federação §4, cargos §14, leilões §13, frota §16).
- ✅ **Severidade por cor + forma** (ícone distinto por nível: círculo-i/check/triângulo/octógono — não só
  cor) + legenda; **filtros** Todas/Não lidas/Importantes com contagem; cartões com selo de severidade, chip
  de origem, ponto de não-lida e **ação com deep-link** (ex.: "Ver frota"→`/map/fleet`, "Ver missões"→
  `/map/missions`, "Ver cargos"→`/capital/offices`, "Ver leilões"→`/market/auctions`).
- Seam: `NotificationRepository`/`MockNotificationRepository`/`notifications.json`/`notificationsProvider`;
  `notification.dart` (AppNotification/NotificationCenter + enums). Relatório `docs/reports/17-b10-notificacoes.pdf`.
- Futuro: marcar-como-lida real, push em tempo real, agrupamento por dia.

**➡️ Bloco B CONCLUÍDO** (B0–B10). Próximo: Bloco C (C1 Exploração Lunar/Gagarin — previews T2).

---

## BLOCO C — Temporada 2 / Bloqueados
### C1 — Exploração Lunar / Telescópio Gagarin (previews T2)  ⬜  · GDD §12
- Apenas previews/teasers e estrutura — conteúdo jogável é T2.

### C2 — Ranking de Guerras  ✅  · GDD §15 (preenchido no v24)
- **Desbloqueado e construído** — ver "§15 — Ranking de Guerras" no Bloco A4 acima. (Era bloqueio de design; o v24 §15.1–15.3 definiu 6 sub-rankings + pesos do Ranking Geral.)

---

## Ordem de execução proposta
**A1 → A2 → A3** (zera placeholders) → **B1 → B2 → B3 → B4 → B5 → B6 → B7 → B8 → B9 → B10** → **C1 → C2 (scaffold)**.

Cada item é uma entrega revisável. A ordem dentro do Bloco B pode ser reordenada conforme prioridade do produto.
