# informal-trade

## Purpose
Comércio Informal entre colonos (`/market/informal`, GDD §8 + §25 + §26). Troca direta sem
garantias do sistema — o calote é mecânica real; a proteção é a reputação. Frontend/mock.

## Requirements

### Requirement: Ofertas com sinal de confiança
O sistema SHALL listar ofertas (swap Você recebe ↔ Você envia) com índice de **Confiança
Comercial (0–1000, §26.2)**, avaliação ★ e chip "Risco de calote" quando o índice < 500.
Lido via `MarketRepository.loadInformalBoard` (`assets/fixtures/informal.json`).

#### Scenario: Oferta arriscada
- **WHEN** o ofertante tem Confiança Comercial 210
- **THEN** o card tem borda vermelha, tag "Risco de calote" e botão de negociar atenuado

### Requirement: Logística física e tributo único (§25)
O sistema SHALL exibir, por oferta, o veículo (Furgão 6m³/Caminhão 30m³), a distância em
slots e o tempo/energia estimados (§25.6), e o **tributo de transporte na entrega** (3/2/1%,
§25), com isenção para mesma federação.

#### Scenario: Tributo de transporte
- **WHEN** o jogador envia 180 Energia (primário) a 22 slots
- **THEN** mostra "~5,5 min · ~5,5 kWh" e "5.4 Energia (3%, §25)"

### Requirement: Acordo de Troca (§26.5)
O sistema SHALL oferecer o Acordo de Troca ("aperto de mão digital") e, no histórico, marcar
calote com acordo expirado como denúncia pré-preenchida.

#### Scenario: Histórico de calote
- **WHEN** uma troca terminou em calote com acordo expirado
- **THEN** mostra "Acordo de Troca expirado — denúncia pré-preenchida (§26.5)"

### Requirement: Troca transacional (backend, §8)
O sistema SHALL lastrear as ofertas em registros reais (`InformalOffer`) servidos por `GET /informal` e, ao
aceitar (`POST /informal/:id/accept`), fazer a **troca atômica** de recursos — o jogador envia o `want` e
recebe o `give`; o ofertante faz o inverso — sem escrow. A oferta é encerrada após a troca.

#### Scenario: Aceitar oferta
- **WHEN** o jogador aceita uma oferta e tem os recursos do `want`
- **THEN** o backend troca os recursos atomicamente, atualiza o HUD e encerra a oferta
