# reputation-justice

## Purpose
Ministério das Reputações / Justiça (slot Reputações do `/capital/ministry`, GDD §9):
denúncias com estados auditáveis, fluxo de conciliação, conciliadores e punições. Frontend/mock
(`ReputationRepository` → `disputes.json`).

## Requirements

### Requirement: Fila de denúncias com estados auditáveis (§9)
O sistema SHALL listar denúncias com filtro (Abertas/Resolvidas/Apeladas/Todas) e status auditável
(em triagem · em análise · julgado · punido · apelado · improcedente).

#### Scenario: Dashboard de justiça
- **WHEN** a tela do ministério abre no slot Reputações
- **THEN** mostra KPIs (em aberto/resolvidas/apeladas/conciliadores) e a fila filtrável

### Requirement: Fluxo de 5 passos (§9.2)
O sistema SHALL detalhar cada denúncia com o fluxo Abertura → Triagem automática → Conciliador
analisa → Decisão → (IA futura), destacando o passo atual, com evidências (texto/captura/log/histórico).

#### Scenario: Caso em análise
- **WHEN** um caso está "em análise"
- **THEN** o passo "Conciliador analisa" aparece como atual

### Requirement: Punições e conciliadores (§9.4 / §9.3 / §26.7)
O sistema SHALL exibir a decisão/punição (advertência · redução · silêncio · restrição · bloqueio de
leilões/Persona Non Grata) e os conciliadores (casos/reversões, Ativo/Suspenso).

#### Scenario: Caso apelado
- **WHEN** um caso punido está em apelação
- **THEN** a decisão mostra a punição e o selo "Em apelação"
