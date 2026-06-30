# messages

## Purpose
Sistema de Mensagens (`/map/messages`, GDD §10): cinco canais com escopos e moderação
distintas, denúncia por mensagem e operação multilíngue. Frontend/mock.

## Requirements

### Requirement: Cinco canais (§10.1)
O sistema SHALL listar os 5 canais (Global, Região, Federação, Mensagem Privada, Vizinhança)
com ícone por tipo e badge de não-lidas, lidos via `ChatRepository.loadChat`
(`assets/fixtures/chat.json`).

#### Scenario: Seletor de canais
- **WHEN** a tela de Mensagens abre
- **THEN** mostra os 5 canais; o primeiro (ou o selecionado) exibe sua thread

### Requirement: Indicador de moderação (§10.2)
O sistema SHALL indicar moderação automática nos canais públicos e "sem filtro automático —
só denúncia manual" em Federação e Mensagem Privada. Cada mensagem alheia tem botão de denúncia.

#### Scenario: Canal de federação
- **WHEN** o Chat de Federação é selecionado
- **THEN** mostra "Sem filtro automático — só denúncia manual (§10.2)"

### Requirement: Multilíngue (§10.4)
O sistema SHALL marcar mensagens em idioma diferente com uma tag de idioma e a nota
"mostrado no idioma do remetente".

#### Scenario: Mensagem em inglês
- **WHEN** uma mensagem tem idioma "en"
- **THEN** exibe a tag "EN" e a nota §10.4
