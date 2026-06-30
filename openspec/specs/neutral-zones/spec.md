# neutral-zones

## Purpose
Gestão de uma **Zona Neutra** (`/map/zone`, GDD §7 + §16 + §17.4): o loop econômico real de
recurso — ocupar (Robô Minerador) → extrair (depósito 10 níveis) → transportar (Caminhão/
Nave aos 4 destinos). Alcançada ao tocar numa zona neutra no mapa-planeta. Frontend/mock.

## Requirements

### Requirement: Status e ocupação
O sistema SHALL exibir o recurso da zona, o nível do depósito (barra, 0–10), o status
(livre) e a quantidade de Robôs Mineradores necessária para ocupar (varia por nível,
20–150+), com ação "Ocupar zona" (mock).

#### Scenario: Abrir uma zona
- **WHEN** o jogador toca numa zona neutra e usa "Gerenciar zona"
- **THEN** a tela mostra recurso, depósito Nv x/10, robôs necessários e ação de ocupar
- **AND** sem zona selecionada (acesso direto), mostra estado vazio com link ao mapa

### Requirement: Estruturas da zona (§17.4)
O sistema SHALL listar as estruturas construíveis da zona (Posto de Comando, Depósito de
Recursos, Estrutura de Extração, Abrigo de Robôs, Muralha, Torre de Vigia, Refinaria de
Campo) com nível e ação construir/melhorar (mock).

#### Scenario: Estrutura a construir
- **WHEN** uma estrutura está no nível 0
- **THEN** mostra "Construir"; caso contrário "Melhorar"

### Requirement: Transporte aos 4 destinos
O sistema SHALL oferecer envio da carga (Caminhão de Carga / Nave de Transporte) a um dos
4 destinos: Mercado, Slot, Jogador, Federação (mock).

#### Scenario: Enviar carga
- **WHEN** o jogador escolhe um destino
- **THEN** dá feedback "enviar carga → <destino> — em breve"
