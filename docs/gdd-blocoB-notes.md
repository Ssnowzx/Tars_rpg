# GDD v29 — Notas para Bloco B (referência de implementação)

> Extraído fielmente de `FERTWAYS_GDD_v29.html` para guiar B4–B9. Use como base; confira o GDD para números.

## §4 Federações (B4)
- Membros: máx **12**. Cargos: **Líder** (voto de Minerva) + **Diplomata**.
- Fundo: **1–10% da produção diária (padrão 3%)**. Fica na Capital.
- Tributação interna: **gratuito até 35%** da produção diária; acima: **35% de tributo**.
- Entre aliadas: **50% de desconto**. Limite antimonopólio dinâmico **20%→10%**.

## §9 Ministério das Reputações (B5) — slot 7
- 9.2 Fluxo (5 passos): Abertura (texto+screenshots+denunciado) → Triagem automática (logs; simples→conciliador, grave→equipe) → Conciliador analisa (texto/screenshots/logs/histórico) → Decisão (improcedente/advertência/redução/silêncio; graves→equipe) → Futuro IA.
- 9.3 Conciliador: Neutro Registrado; pago em Fert$ por caso; decisões apeláveis.
- 9.4 Punições: Advertência · Redução de reputação · Silêncio temporário · Restrição comercial · Bloqueio de leilões (Persona Non Grata).
- Painel admin: triagem, atribuir conciliadores, logs de comércio, aplicar punições, gerir conciliadores, denúncias abertas/resolvidas/apeladas, IA futura.
- §26.5 Acordo de Troca expirado → denúncia pré-preenchida. §26.7 Conciliador: 50 Fert$/dia + 3 só se decisão não revertida; suspensão por reversões. §26.8 impedimento (própria federação / transação <30 dias), evidência mínima obrigatória, prazo 48h, padrão de decisão (§9.4).

## §5/§6 Progressão, Missões, Conquistas (B6)
- §5 escada 1–100 (Sobrevivente→…→Lenda de Fertways) — já no Perfil.
- §6 Missões: Tutoria (5, dias 1–3), Diária (3/dia, pool 30+, 1 rejeição), Semanal (Qua→Ter), Narrativa, Federação (2/sem), Guerra (pool contínuo), Evento, Conquista (Bronze/Prata/Ouro/Platina).

## §16/§21 Frota e Transportes (B7)
- §16.3 Registro de placas (já no ministério Transportes). §16.4 depreciação por horas de uso (Furgão/Caminhão).
- §21 Veículos: Furgão (6m³), Caminhão (30m³), Drone, Nave Longa Distância, Robô Minerador (ciclo), Infiltrador/Predador (secretas), Nave Transporte Planetária, Tanque Combustível, Cargueiro. §25.4/§25.6 capacidade/tempo/energia.

## §14 Cargos Públicos (B8)
- 5 cargos: Conciliador (Min. Reputações, 50 Fert$/dia + 3/denúncia) · Fiscal de Mercado · Atendente do Espaçoporto · Repórter · Auxiliar de Tesouro (os 4 últimos: fixo+bônus, sem número).
- 14.3 Elegibilidade (todos juntos): sem <3★ 7 dias; sem <3★ últimas 7 negociações; top 35% terraformação; sem restrição comercial 7 dias; não bloqueado de leilões; reputação mínima; 10 missões diárias.
- 26.6 Índice por cargo: Conciliador (Conduta Social+Status Cívico); Fiscal (Confiança Comercial); Atendente/Repórter (Conduta Social); Auxiliar (Status Cívico).
- 14.4 Painel admin: salário/bônus, criar cargos, editar critérios, candidatos, aprovar/suspender/demitir, desempenho, pagamentos.

## §13 Leilões (B9) — sem seção dedicada; regras espalhadas
- Desbloqueia no Nível 100 (Lenda) — "leilões de peças únicas".
- Bloqueio de leilões = Persona Non Grata (§9.4); Confiança Comercial baixa bloqueia (§26.2).
- Loja AbacatePay (PIX/cartão; nada pago dá vantagem). Pacotes: Sobrevivente 500/R$4,90 … Lenda 35.000+12.000/R$149,90. Assinaturas: Colono Plus 1.500/mês … Lenda Plus 8.000/mês.

## §10 Notificações (B10) — transversal
- Centro in-app, badges, severidade por cor + forma. (Eventos vêm de Pesquisas/Notícias §12.1 Gagarin, guerras §27, mercado, denúncias §9.)

## §26 Reputação (4 índices, já no Perfil — referência)
- Confiança Comercial / Conduta Social / Status Cívico / Honra Militar (0–1000), isolados. Avaliar só ≥500 Fert$ (§26.3). Acordo de Troca §26.5.
