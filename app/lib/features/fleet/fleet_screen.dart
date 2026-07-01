import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../data/providers.dart';
import '../../domain/models/fleet.dart';

({String name, IconData icon, Color color}) _kindMeta(VehicleKind k, DsTokens t) => switch (k) {
      VehicleKind.van => (name: 'Furgão', icon: Icons.airport_shuttle_outlined, color: t.info),
      VehicleKind.truck => (name: 'Caminhão de Carga', icon: Icons.local_shipping_outlined, color: t.info),
      VehicleKind.drone => (name: 'Drone de Carga', icon: Icons.air, color: t.teal),
      VehicleKind.longHauler => (name: 'Nave de Longa Distância', icon: Icons.rocket_launch_outlined, color: t.federation),
      VehicleKind.miningRobot => (name: 'Robô Minerador', icon: Icons.precision_manufacturing_outlined, color: t.solar),
      VehicleKind.planetaryTransport => (name: 'Nave de Transporte Planetária', icon: Icons.flight_takeoff_outlined, color: t.federation),
      VehicleKind.fuelTanker => (name: 'Tanque de Combustível', icon: Icons.local_gas_station_outlined, color: t.warning),
      VehicleKind.freighter => (name: 'Cargueiro Interplanetário', icon: Icons.inventory_2_outlined, color: t.federation),
    };

({String label, Color color, IconData icon}) _statusMeta(VehicleStatus s, DsTokens t) => switch (s) {
      VehicleStatus.idle => (label: 'Ocioso', color: t.textSecondary, icon: Icons.pause_circle_outline),
      VehicleStatus.inTransit => (label: 'Em trânsito', color: t.info, icon: Icons.local_shipping_outlined),
      VehicleStatus.loading => (label: 'Carregando', color: t.solar, icon: Icons.downloading_outlined),
      VehicleStatus.maintenance => (label: 'Manutenção', color: t.warning, icon: Icons.build_outlined),
      VehicleStatus.critical => (label: 'Bloqueado', color: t.deltaDown, icon: Icons.error_outline),
    };

Color _conditionColor(int condition, DsTokens t) {
  if (condition < 20) return t.deltaDown;
  if (condition < 50) return t.warning;
  return t.success;
}

int _statusOrder(VehicleStatus s) => switch (s) {
      VehicleStatus.critical => 0,
      VehicleStatus.maintenance => 1,
      VehicleStatus.loading => 2,
      VehicleStatus.inTransit => 3,
      VehicleStatus.idle => 4,
    };

/// Frota do colono (GDD v29 §21 + §16.4). Lista de veículos com capacidade,
/// condição/depreciação por horas de uso, situação operacional e ações de
/// despacho/manutenção/sucateamento. Drill-in do shell (mantém HUD/nav).
class FleetScreen extends ConsumerStatefulWidget {
  const FleetScreen({super.key});

  @override
  ConsumerState<FleetScreen> createState() => _FleetScreenState();
}

class _FleetScreenState extends ConsumerState<FleetScreen> {
  void _toast(String m) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(m), behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 2)),
      );

  /// Manutenção real (§16.4): cobra o custo no backend e restaura a condição.
  Future<void> _maintain(Vehicle v) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(fleetRepositoryProvider).maintain(v.id);
      ref.invalidate(fleetProvider);
      ref.invalidate(resourcesProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('${v.plate}: manutenção concluída (Fert\$ ${v.maintenanceCost}).'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível fazer a manutenção de ${v.plate} (saldo insuficiente?).'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  /// Sucateamento real: remove o veículo e libera a vaga do hangar.
  Future<void> _scrap(Vehicle v) async {
    final messenger = ScaffoldMessenger.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Sucatear ${v.plate}?'),
        content: const Text('O veículo será removido permanentemente da frota, liberando a vaga do hangar.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Sucatear')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(fleetRepositoryProvider).scrap(v.id);
      ref.invalidate(fleetProvider);
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('${v.plate} foi sucateado.'),
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(
        content: Text('Não foi possível sucatear ${v.plate}.'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final fleet = ref.watch(fleetProvider);

    return ColoredBox(
      color: t.surfacePage,
      child: fleet.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(fleetProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Não foi possível carregar a frota. Tocar para tentar de novo.'),
          ),
        ),
        data: (board) {
          final vehicles = [...board.vehicles]
            ..sort((a, b) => _statusOrder(a.status).compareTo(_statusOrder(b.status)));
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _Header(),
              _Summary(board: board),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 840),
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(t.space4, t.space2, t.space4, t.space6),
                      children: [
                        for (final v in vehicles)
                          _VehicleCard(
                            vehicle: v,
                            onMaintain: () => _maintain(v),
                            onDispatch: () => _toast('Despacho de carga entra com o sistema de logística (§25).'),
                            onScrap: () => _scrap(v),
                          ),
                        SizedBox(height: t.space2),
                        const _DepreciationNote(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space2),
      child: Row(
        children: [
          InkWell(
            onTap: () => context.go('/map/colony'),
            borderRadius: BorderRadius.circular(t.radiusSm),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
            ),
          ),
          SizedBox(width: t.space2),
          const Icon(Icons.local_shipping_outlined, size: 22, color: FwPalette.rust600),
          SizedBox(width: t.space2),
          Text('Frota',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 22, color: FwPalette.gray900)),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  const _Summary({required this.board});
  final FleetBoard board;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: t.space4, vertical: t.space1),
      child: Wrap(
        spacing: t.space2,
        runSpacing: t.space1,
        children: [
          _Chip(icon: Icons.garage_outlined, color: t.federation, text: 'Hangar ${board.garageUsed}/${board.garageCapacity}'),
          _Chip(icon: Icons.local_shipping_outlined, color: t.info, text: '${board.inTransit} em trânsito'),
          if (board.needsMaintenance > 0)
            _Chip(icon: Icons.build_outlined, color: t.warning, text: '${board.needsMaintenance} p/ manutenção'),
          _Chip(icon: Icons.inventory_2_outlined, color: t.solar, text: '${board.totalCapacity} m³ total'),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(text, style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 11.5, color: color)),
        ],
      ),
    );
  }
}

class _VehicleCard extends StatelessWidget {
  const _VehicleCard({
    required this.vehicle,
    required this.onMaintain,
    required this.onDispatch,
    required this.onScrap,
  });
  final Vehicle vehicle;
  final VoidCallback onMaintain;
  final VoidCallback onDispatch;
  final VoidCallback onScrap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    final kind = _kindMeta(vehicle.kind, t);
    final status = _statusMeta(vehicle.status, t);
    final condColor = _conditionColor(vehicle.condition, t);
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border(
          left: BorderSide(color: vehicle.isBlocked ? t.deltaDown : kind.color, width: 3),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: kind.color.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(t.radiusMd)),
                child: Icon(kind.icon, size: 20, color: kind.color),
              ),
              SizedBox(width: t.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(kind.name,
                        style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: FwPalette.gray900)),
                    Text('Placa ${vehicle.plate} · ${vehicle.capacityM3} m³ · ${vehicle.activeHours}h de uso',
                        style: TextStyle(fontSize: 11.5, color: t.textSecondary)),
                  ],
                ),
              ),
              SizedBox(width: t.space2),
              _Pill(label: status.label, color: status.color, icon: status.icon),
            ],
          ),
          SizedBox(height: t.space3),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: vehicle.condition / 100,
                    minHeight: 7,
                    backgroundColor: t.surfaceSunken,
                    valueColor: AlwaysStoppedAnimation<Color>(condColor),
                  ),
                ),
              ),
              SizedBox(width: t.space2),
              Text('Condição ${vehicle.condition}%',
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: condColor)),
            ],
          ),
          SizedBox(height: t.space1),
          Row(
            children: [
              Icon(vehicle.depreciates ? Icons.trending_down : Icons.verified_outlined,
                  size: 12, color: t.textSecondary),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(
                  vehicle.depreciates
                      ? 'Deprecia por uso (§16.4) · limite crítico ${vehicle.criticalThreshold}%'
                      : 'Sem depreciação por horas (§16.4)',
                  style: TextStyle(fontSize: 10.5, color: t.textSecondary),
                ),
              ),
            ],
          ),
          SizedBox(height: t.space2),
          Row(
            children: [
              Icon(Icons.assignment_outlined, size: 13, color: t.textSecondary),
              SizedBox(width: t.space1),
              Expanded(
                child: Text(vehicle.assignment,
                    style: TextStyle(fontSize: 12, color: vehicle.isBlocked ? t.deltaDown : FwPalette.gray800)),
              ),
            ],
          ),
          SizedBox(height: t.space2),
          Wrap(
            spacing: t.space2,
            runSpacing: t.space1,
            children: [
              if (vehicle.needsMaintenance || vehicle.condition < 100)
                FilledButton.tonalIcon(
                  onPressed: onMaintain,
                  style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: t.warning.withValues(alpha: 0.16),
                      foregroundColor: t.warning),
                  icon: const Icon(Icons.build_outlined, size: 15),
                  label: Text(vehicle.maintenanceCost > 0 ? 'Manutenção · Fert\$ ${vehicle.maintenanceCost}' : 'Manutenção'),
                ),
              if (vehicle.status == VehicleStatus.idle)
                OutlinedButton.icon(
                  onPressed: onDispatch,
                  style: OutlinedButton.styleFrom(visualDensity: VisualDensity.compact),
                  icon: const Icon(Icons.send_outlined, size: 15),
                  label: const Text('Despachar'),
                ),
              TextButton.icon(
                onPressed: onScrap,
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, foregroundColor: t.textSecondary),
                icon: const Icon(Icons.delete_outline, size: 15),
                label: const Text('Sucatear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepreciationNote extends StatelessWidget {
  const _DepreciationNote();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(color: t.surfaceSunken, borderRadius: BorderRadius.circular(t.radiusMd)),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: t.textSecondary),
          SizedBox(width: t.space2),
          Expanded(
            child: Text(
              'Furgão e Caminhão depreciam por horas de uso ativo (§16.4); abaixo do limite crítico ficam '
              'bloqueados até a manutenção. As placas são registradas no Ministério dos Transportes (§16.3).',
              style: TextStyle(fontSize: 11.5, height: 1.35, color: t.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 11, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}
