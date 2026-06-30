# market

## Purpose
Mercado Central (`/market`, GDD §13 + §8): ordens de compra/venda dos recursos com sinais
de confiança do vendedor (avaliação 0–5, §8). Preços-base seguem o §22. Frontend/mock.

## Requirements

### Requirement: Tickers e ordens
O sistema SHALL exibir tickers por recurso (preço-base + variação %) e uma lista de ordens
(lado compra/venda, recurso, quantidade, preço unitário, total), lida via
`MarketRepository.loadBoard` (mock: `assets/fixtures/market.json`).

#### Scenario: Carregamento
- **WHEN** o Mercado é aberto
- **THEN** mostra tickers + ordens; loading/erro tratados

### Requirement: Preços conforme §22
O sistema SHALL usar os preços-base do §22 (frações de Fert$, ex.: Água 0,0062; Componentes
Eletrônicos 0,0333) e formatar com casas decimais; total = quantidade × preço unitário.

#### Scenario: Total de uma ordem
- **WHEN** uma ordem é de 1200 Água a 0,0062 Fert$/un
- **THEN** o total exibido é 7.44 Fert$

### Requirement: Sinal de confiança / risco (§8)
O sistema SHALL exibir a avaliação ★ do trader e um chip "Risco" quando a reputação for
baixa (< 3.5), no ponto da transação.

#### Scenario: Vendedor arriscado
- **WHEN** o trader tem avaliação 2.6
- **THEN** a estrela aparece em vermelho e um chip "Risco" é mostrado

### Requirement: Filtros
O sistema SHALL filtrar as ordens por recurso e por lado (Comprar/Vender), com "Tudo".

#### Scenario: Filtrar por recurso
- **WHEN** o jogador seleciona "Ligas Metálicas"
- **THEN** apenas ordens desse recurso são listadas
