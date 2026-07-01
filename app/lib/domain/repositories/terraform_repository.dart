import '../models/terraform.dart';

/// Costura da Terraformação Global (§04 + §12.3) — mock hoje, API depois.
abstract interface class TerraformRepository {
  Future<TerraformState> loadTerraform();
}
