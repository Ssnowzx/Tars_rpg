import 'package:flutter_test/flutter_test.dart';

import 'package:fertways/domain/models/institution_slot.dart';
import 'package:fertways/domain/models/resources.dart';

void main() {
  group('Resources.fromJson', () {
    test('deve parsear moeda Fert\$ e estoques por tier', () {
      // ARRANGE
      final json = {
        'fertCoins': 184250,
        'stocks': [
          {'id': 'water', 'label': 'Água', 'amount': 12840, 'tier': 'primary'},
          {'id': 'components', 'label': 'Componentes', 'amount': 612, 'tier': 'rare'},
        ],
      };

      // ACT
      final resources = Resources.fromJson(json);

      // ASSERT
      expect(resources.fertCoins, 184250);
      expect(resources.stocks, hasLength(2));
      expect(resources.stocks.first.tier, ResourceTier.primary);
      expect(resources.stocks.last.tier, ResourceTier.rare);
    });
  });

  group('InstitutionSlot.fromJson', () {
    test('deve marcar slot como vazio quando installed for false', () {
      // ARRANGE
      final json = {'index': 11, 'category': 'empty', 'installed': false};

      // ACT
      final slot = InstitutionSlot.fromJson(json);

      // ASSERT
      expect(slot.isEmpty, isTrue);
      expect(slot.category, SlotCategory.empty);
    });

    test('deve parsear instituição instalada com categoria e nível', () {
      // ARRANGE
      final json = {
        'index': 1,
        'name': 'Administração Pública',
        'category': 'administration',
        'installed': true,
        'level': 5,
      };

      // ACT
      final slot = InstitutionSlot.fromJson(json);

      // ASSERT
      expect(slot.installed, isTrue);
      expect(slot.category, SlotCategory.administration);
      expect(slot.level, 5);
    });
  });
}
