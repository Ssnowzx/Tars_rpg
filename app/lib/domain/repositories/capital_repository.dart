import '../models/institution_slot.dart';
import '../models/resources.dart';

/// Costura de repositório (brief §3.3): a UI só conhece esta interface.
/// Hoje uma implementação mock (fixtures); depois, a implementação de API —
/// sem mudar nenhuma tela.
abstract interface class CapitalRepository {
  Future<Resources> loadResources();
  Future<List<InstitutionSlot>> loadSlots();
}
