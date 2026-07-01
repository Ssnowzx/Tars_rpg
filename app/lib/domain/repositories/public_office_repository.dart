import '../models/public_office.dart';

/// Costura dos Cargos Públicos Neutros (mock hoje, API depois) — §14.
abstract interface class PublicOfficeRepository {
  Future<PublicOfficeBoard> loadOffices();
}
