# capital-ministries

## Purpose
Telas de ministério da Capital (`/capital/ministry`, GDD §2.1 + §14). Cada slot instalado
abre um painel sobre layout comum. Frontend/mock.

## Requirements

### Requirement: Despacho por slot
O sistema SHALL receber o `InstitutionSlot` tocado via `state.extra` e despachar o painel
conforme `slot.kind`, sobre o `MinistryScaffold` (voltar + identidade + função §2.1 + nível).
Dados lidos via `MinistryRepository.loadMinistries` (`assets/fixtures/ministries.json`).

#### Scenario: Abrir um ministério
- **WHEN** o jogador toca um slot instalado da Capital
- **THEN** abre a tela do ministério correspondente, mantendo HUD/nav

### Requirement: Painéis por instituição
O sistema SHALL prover painéis para Finanças/Tesouro, Tributos (§8.3), Pesquisas/Notícias
(§12.1), Administração (§14), Segurança/Guerra (+atalho ao Ranking §15), Estacionamento,
Transportes (§16.3/§16.4), Depósito e Central de Transportes (§19.5).

#### Scenario: Tesouro
- **WHEN** o painel de Finanças/Tesouro é aberto
- **THEN** mostra saldo, PIB, receita/despesa e o fluxo de caixa do dia

### Requirement: Reputações como stub para B5
O sistema SHALL exibir o fluxo de justiça (§9) e apontar para o Bloco B5, sem dados falsos.

#### Scenario: Reputações
- **WHEN** o slot Ministério das Reputações é aberto
- **THEN** mostra os passos do fluxo e a nota "tela completa no B5"
