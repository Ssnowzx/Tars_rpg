import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../app/theme/ds_tokens.dart';
import '../../../domain/models/institution_slot.dart';
import '../../../domain/models/ministry.dart';
import '../category_meta.dart';

/// Mostra um SnackBar para ações ainda mock (sem backend). Centraliza o
/// comportamento "ação simulada" usado pelos painéis de ministério.
void mockMinistryAction(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ),
  );
}

/// Esqueleto comum a todos os ministérios: cabeçalho (voltar + identidade do
/// slot + função §2.1 + nível) e a lista rolável do corpo específico.
class MinistryScaffold extends StatelessWidget {
  const MinistryScaffold({super.key, required this.slot, required this.body});

  final InstitutionSlot slot;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final meta = categoryMeta(slot.category, t);
    final kind = ministryKindFrom(slot.kind);

    return ColoredBox(
      color: t.surfacePage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(t.space4, t.space4, t.space4, t.space3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => context.go('/capital'),
                  borderRadius: BorderRadius.circular(t.radiusSm),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(Icons.arrow_back, size: 20, color: t.textSecondary),
                  ),
                ),
                SizedBox(width: t.space2),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: meta.color.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(t.radiusMd),
                  ),
                  child: Icon(meta.icon, size: 22, color: meta.color),
                ),
                SizedBox(width: t.space3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              slot.name ?? meta.label,
                              style: GoogleFonts.rajdhani(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 21,
                                  height: 1.05,
                                  color: FwPalette.gray900),
                            ),
                          ),
                          if (slot.level > 0) ...[
                            SizedBox(width: t.space2),
                            _LevelChip(level: slot.level, color: meta.color),
                          ],
                        ],
                      ),
                      SizedBox(height: t.space1),
                      Text(kind.function,
                          style: TextStyle(fontSize: 12.5, height: 1.3, color: t.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.color});
  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Text('Nível $level',
          style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 12, color: color)),
    );
  }
}

/// Cartão de seção com título (e ação opcional no canto). Base visual de todo
/// bloco de conteúdo dentro de um ministério.
class MinistrySection extends StatelessWidget {
  const MinistrySection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: t.space3),
      padding: EdgeInsets.all(t.space4),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusCard),
        border: Border.all(color: t.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title.toUpperCase(),
                    style: GoogleFonts.rajdhani(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        letterSpacing: 1.1,
                        color: FwPalette.gray500)),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: t.space1),
            Text(subtitle!, style: TextStyle(fontSize: 12.5, color: t.textSecondary)),
          ],
          SizedBox(height: t.space3),
          child,
        ],
      ),
    );
  }
}

/// Métrica destacada (rótulo + valor grande, ícone/cor opcionais).
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.icon, this.color});

  final String label;
  final String value;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final c = color ?? FwPalette.gray900;
    return Container(
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: t.surfaceSunken,
        borderRadius: BorderRadius.circular(t.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: c),
                SizedBox(width: t.space1),
              ],
              Expanded(
                child: Text(label,
                    style: TextStyle(fontSize: 11, color: t.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          SizedBox(height: t.space1),
          Text(value,
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.w700, fontSize: 18, color: c),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

/// Grade responsiva de [StatTile] (2 colunas no estreito, mais no largo).
class StatGrid extends StatelessWidget {
  const StatGrid({super.key, required this.tiles});
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return LayoutBuilder(
      builder: (context, c) {
        final columns = (c.maxWidth / 180).floor().clamp(2, 4);
        final width = (c.maxWidth - (columns - 1) * t.space2) / columns;
        return Wrap(
          spacing: t.space2,
          runSpacing: t.space2,
          children: [for (final tile in tiles) SizedBox(width: width, child: tile)],
        );
      },
    );
  }
}

/// Selo de status (texto curto colorido), sempre com cor + rótulo.
class StatusPill extends StatelessWidget {
  const StatusPill({super.key, required this.label, required this.color, this.icon});
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            SizedBox(width: t.space1),
          ],
          Text(label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }
}

/// Linha simples rótulo → valor (tabelas de detalhe).
class KeyValueRow extends StatelessWidget {
  const KeyValueRow({super.key, required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: t.space1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: t.textSecondary)),
          ),
          SizedBox(width: t.space3),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? FwPalette.gray900)),
        ],
      ),
    );
  }
}

/// Item de lista em "tile" com borda (linha de tabela/registro reutilizável).
class MinistryTile extends StatelessWidget {
  const MinistryTile({super.key, required this.child, this.accent});
  final Widget child;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: t.space2),
      padding: EdgeInsets.all(t.space3),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(t.radiusMd),
        border: Border(
          left: BorderSide(color: accent ?? t.borderDefault, width: accent != null ? 3 : 1),
          top: BorderSide(color: t.borderDefault),
          right: BorderSide(color: t.borderDefault),
          bottom: BorderSide(color: t.borderDefault),
        ),
      ),
      child: child,
    );
  }
}
