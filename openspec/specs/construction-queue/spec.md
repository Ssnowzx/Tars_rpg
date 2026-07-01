# construction-queue

## Purpose
Fila de construção real (§17/§20): substitui as ações mock (SnackBar "em breve") por estado mutável
com contagem regressiva ao vivo. É o **primeiro estado mutável** do app — um `NotifierProvider`
(`buildQueueProvider`) com um `Timer` de 1s. As ações de construir/evoluir da Colônia (`/map/colony`)
e das estruturas de Zona (`/map/zone`) enfileiram aqui; o painel "Construção em andamento" na Colônia
mostra progresso, contagem regressiva, cancelar e "Concluir agora". Frontend/mock — sem backend.

## Requirements

### Requirement: Fila mutável com contagem regressiva ao vivo
O sistema SHALL manter uma fila de obras em estado mutável, cada obra com tempo total e horário de
conclusão; o tempo restante e o progresso SHALL ser derivados do relógio a cada tick (1s), e obras
concluídas SHALL sair da fila automaticamente.

#### Scenario: Obra conclui
- **WHEN** o horário de conclusão de uma obra é atingido
- **THEN** a obra é removida da fila e a contagem de vagas usadas diminui

### Requirement: Enfileirar construir/evoluir (§17)
O sistema SHALL enfileirar a construção (slot livre) e a evolução (nível N→N+1) da Colônia e as
estruturas de Zona, com tempo estimado por nível (curva §20), em vez de mostrar SnackBar "em breve".

#### Scenario: Evoluir uma construção
- **WHEN** o jogador toca "Melhorar" numa construção
- **THEN** uma obra Nv N→N+1 entra na fila com contagem regressiva

### Requirement: Fila dupla nos primeiros 5 dias (§03/§20.2)
O sistema SHALL limitar a fila a 2 vagas (fila dupla) nos primeiros 5 dias de conta e recusar novas
obras quando cheia, informando o jogador.

#### Scenario: Fila cheia
- **WHEN** a fila já tem o número máximo de obras
- **THEN** a ação de enfileirar é recusada com aviso "Fila cheia"

### Requirement: Cancelar e concluir agora
O sistema SHALL permitir cancelar uma obra da fila e concluir todas instantaneamente (mock, sem custo
de aceleração — §13 veda pay-to-win).

#### Scenario: Cancelar obra
- **WHEN** o jogador toca o X de uma obra
- **THEN** a obra sai da fila e libera a vaga

### Requirement: Backend autoritativo com custo e produção (§19/§20)
A fila é autoritativa no backend (`/build-queue`, `/colony/build|upgrade`). Enfileirar SHALL debitar o custo
em recursos (Metal Bruto + Energia, curva 1.5×) e devolvê-lo ao cancelar; concluir SHALL elevar o nível e a
produção por hora do recurso (recalculando o `ResourceStock.perHour`). A mensagem de erro exibida SHALL ser a
real do servidor (recurso insuficiente ≠ fila cheia).

#### Scenario: Obra sobe a produção
- **WHEN** o jogador conclui a evolução de uma construção de produção
- **THEN** o nível e o perHour do recurso aumentam e o HUD passa a acumular mais rápido
