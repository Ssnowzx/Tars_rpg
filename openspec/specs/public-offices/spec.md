# public-offices

## Purpose
Cargos Públicos Neutros (`/capital/offices`, GDD §14): os 5 cargos, elegibilidade, índice de
reputação por cargo e painel administrativo. Drill-in da Capital (botão "Gerir" da Administração
Pública). Frontend/mock (`PublicOfficeRepository` → `offices.json`).

## Requirements

### Requirement: Cinco cargos e índice por cargo (§14 / §26.6)
O sistema SHALL listar os 5 cargos (Conciliador, Fiscal de Mercado, Atendente do Espaçoporto,
Repórter, Auxiliar de Tesouro) com instituição, salário, índice de reputação ligado (§26.6),
vagas/ocupantes e ação Candidatar-se.

#### Scenario: Cargo com vaga
- **WHEN** um cargo tem vaga aberta
- **THEN** mostra "N vaga(s)" e o botão Candidatar-se

### Requirement: Elegibilidade (§14.3)
O sistema SHALL exibir os 7 critérios de elegibilidade (cumpridos vs pendentes) e o veredito;
Candidatar-se fica habilitado apenas quando todos são cumpridos.

#### Scenario: Jogador elegível
- **WHEN** todos os 7 critérios estão cumpridos
- **THEN** mostra "Você está elegível" e habilita Candidatar-se

### Requirement: Painel administrativo (§14.4)
O sistema SHALL prover candidaturas pendentes (Aprovar/Recusar, com Aprovar desabilitado para
inelegíveis), ocupantes atuais (Suspender/Demitir) e pagamentos recentes.

#### Scenario: Candidato inelegível
- **WHEN** um candidato não é elegível
- **THEN** o botão Aprovar fica desabilitado
