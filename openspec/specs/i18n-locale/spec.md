# i18n-locale

## Purpose
Internacionalização e troca de idioma (§11): PT-BR/ES/EN são requisito de lançamento. O app tem
scaffolding gen-l10n (ARB) e agora um **idioma trocável ao vivo** via `localeProvider` (estado mutável)
+ seletor no HUD (ícone de globo). A camada de chrome sempre-visível (nav rail, barra de ações inferior,
status "Online", "em breve", estados comuns) está traduzida nos três idiomas. Frontend/mock. Extrair as
strings do corpo de cada tela (hoje pt-BR hard-coded) é o backlog incremental de i18n.

## Requirements

### Requirement: Troca de idioma ao vivo (§11)
O sistema SHALL permitir trocar entre PT-BR, ES e EN em tempo de execução, sem recriar a conta, e a
troca SHALL refletir imediatamente na interface localizada.

#### Scenario: Selecionar English
- **WHEN** o jogador escolhe "English" no seletor de idioma do HUD
- **THEN** a nav rail e a barra de ações passam a exibir os rótulos em inglês na hora

### Requirement: Chrome traduzido nos três idiomas
O sistema SHALL fornecer, em PT-BR/ES/EN, os rótulos da navegação, das ações da barra inferior
(Construir/Recrutar/Pesquisar/Relatórios/Missões/Mensagens), do status "Online" e das mensagens comuns
("em breve", carregando, erro).

#### Scenario: Rótulos de navegação
- **WHEN** o idioma ativo é ES
- **THEN** a navegação mostra "Mapa/Capital/Mercado/Espaciopuerto/Perfil"

### Requirement: Persistência do idioma
O sistema SHALL persistir o idioma escolhido entre sessões (SharedPreferences) e restaurá-lo no boot. A tela
de login/registro SHALL ser localizada (PT/ES/EN) com seletor de idioma acessível antes de entrar.

#### Scenario: Idioma sobrevive ao reload
- **WHEN** o jogador escolhe English e recarrega o app
- **THEN** a tela de login volta em inglês (idioma persistido no storage)

### Requirement: Roteamento independe do rótulo traduzido
O sistema SHALL rotear as ações por chave estável (não pelo texto traduzido), de modo que a navegação
funcione em qualquer idioma.

#### Scenario: Ação "Mensagens" em inglês
- **WHEN** o idioma é EN e o jogador toca "Messages"
- **THEN** o app navega para `/map/messages` normalmente
