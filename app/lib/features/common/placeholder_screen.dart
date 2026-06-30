import 'package:flutter/material.dart';

import '../../app/theme/ds_tokens.dart';
import '../../l10n/app_localizations.dart';

/// Tela stub para rotas ainda não construídas (Mercado, Espaçoporto, Chat,
/// Perfil, …). Substituir por feature real nas fases 6+ do plano.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.icon = Icons.construction_outlined});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).extension<DsTokens>()!;
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: t.textSecondary),
            SizedBox(height: t.space3),
            Text(l10n.comingSoon, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
