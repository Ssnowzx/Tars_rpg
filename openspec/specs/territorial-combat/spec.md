# territorial-combat

## Purpose
Combate territorial das zonas neutras (seção na tela `/map/zone`, GDD §27). Unidade Sentinela,
forças, previsão por cenário, saque e manutenção. Frontend/mock.

## Requirements

### Requirement: Forças ofensiva e defensiva (§27.3)
O sistema SHALL calcular Força Defensiva = Σ defesa × (1 + bônus de construção) e Força
Ofensiva = Σ ataque das Sentinelas, a partir de `CombatRepository.loadCombat`
(`assets/fixtures/combat.json`). Sentinela §27.1; Robô Minerador defende com 25% (§27.2).

#### Scenario: Defesa com bônus
- **WHEN** a guarnição soma 1686 de defesa e o bônus de construção é 35%
- **THEN** a Força Defensiva exibida é 2276

### Requirement: Previsão por cenário (§27.5)
O sistema SHALL classificar a estimativa pela razão ataque÷defesa: ≥1,6 vantagem do atacante
(~4 rodadas); 0,7–1,6 equilibrado (~12 rodadas); <0,7 vantagem do defensor.

#### Scenario: Forças equilibradas
- **WHEN** ataque 2430 vs defesa 2276 (razão 1,07)
- **THEN** mostra "Forças equilibradas · ~12 rodadas (~120 min)"

### Requirement: Saque, manutenção e proteção (§27.8/§27.11/§27.12)
O sistema SHALL exibir o saque de 50% ao vencer, o custo de manutenção diária e a proteção de
novatos; o botão "Atacar" é desabilitado quando há proteção de novato ou cooldown.

#### Scenario: Zona protegida
- **WHEN** a zona é de um novato (primeiros 20 dias)
- **THEN** o botão "Atacar zona" fica desabilitado
