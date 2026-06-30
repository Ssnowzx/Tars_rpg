import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/ds_tokens.dart';
import '../../../data/providers.dart';
import '../../../domain/models/institution_slot.dart';
import '../../../domain/models/ministry.dart';
import 'ministry_panels.dart';
import 'ministry_widgets.dart';

/// Tela de detalhe de uma instituição da Capital (GDD §2.1). Recebe o slot
/// tocado por `state.extra` e despacha para o painel do ministério conforme
/// `slot.kind`. Drill-in do shell — mantém HUD e nav.
class MinistryScreen extends ConsumerWidget {
  const MinistryScreen({super.key, required this.slot});

  final InstitutionSlot? slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = slot;
    if (current == null) return const _MissingSlot();
    return MinistryScaffold(
      slot: current,
      body: _body(context, ref, ministryKindFrom(current.kind)),
    );
  }

  Widget _body(BuildContext context, WidgetRef ref, MinistryKind kind) {
    // Painéis que não dependem de dados assíncronos.
    if (kind == MinistryKind.reputation) return const ReputationStubPanel();
    if (kind == MinistryKind.unknown) return const GenericPanel();

    final async = ref.watch(ministriesProvider);
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => Center(
        child: TextButton.icon(
          onPressed: () => ref.invalidate(ministriesProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Não foi possível carregar. Tocar para tentar de novo.'),
        ),
      ),
      data: (m) => switch (kind) {
        MinistryKind.treasury => TreasuryPanel(data: m.treasury),
        MinistryKind.tributes => TaxPanel(data: m.tributes),
        MinistryKind.research => ResearchPanel(data: m.research),
        MinistryKind.administration => AdminPanel(data: m.administration),
        MinistryKind.security => SecurityPanel(data: m.security),
        MinistryKind.parking => ParkingPanel(data: m.parking),
        MinistryKind.transport => TransportPanel(data: m.transport),
        MinistryKind.depot => DepotPanel(data: m.depot),
        MinistryKind.centralTransport => CentralTransportPanel(data: m.centralTransport),
        _ => const GenericPanel(),
      },
    );
  }
}

class _MissingSlot extends StatelessWidget {
  const _MissingSlot();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return ColoredBox(
      color: t.surfacePage,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_outlined, size: 40, color: t.textSecondary),
            SizedBox(height: t.space3),
            Text('Instituição não encontrada.', style: TextStyle(color: t.textSecondary)),
            SizedBox(height: t.space3),
            FilledButton(
              onPressed: () => context.go('/capital'),
              child: const Text('Voltar à Capital'),
            ),
          ],
        ),
      ),
    );
  }
}
