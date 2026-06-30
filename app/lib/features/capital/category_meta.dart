import 'package:flutter/material.dart';

import '../../app/theme/ds_colors.dart';
import '../../app/theme/ds_tokens.dart';
import '../../domain/models/institution_slot.dart';

/// Codificação visual de uma categoria de instituição da Capital — sempre
/// cor + ícone + rótulo juntos (nunca cor sozinha). Compartilhada pelo grid
/// da Capital e pelos painéis de ministério.
class CategoryMeta {
  const CategoryMeta(this.label, this.icon, this.color);
  final String label;
  final IconData icon;
  final Color color;
}

CategoryMeta categoryMeta(SlotCategory c, DsTokens t) => switch (c) {
      SlotCategory.administration =>
        CategoryMeta('Administração', Icons.account_balance_outlined, t.info),
      SlotCategory.economy => CategoryMeta('Economia', Icons.payments_outlined, t.warning),
      SlotCategory.military => CategoryMeta('Segurança', Icons.shield_outlined, t.federation),
      SlotCategory.research => CategoryMeta('Pesquisa', Icons.science_outlined, t.info),
      SlotCategory.reputation =>
        CategoryMeta('Reputação', Icons.verified_user_outlined, t.success),
      SlotCategory.transport =>
        const CategoryMeta('Transporte', Icons.local_shipping_outlined, FwPalette.rust600),
      SlotCategory.empty => CategoryMeta('Livre', Icons.add, t.textSecondary),
    };
