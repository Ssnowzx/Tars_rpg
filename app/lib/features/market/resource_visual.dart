import 'package:flutter/material.dart';

import '../../app/theme/ds_colors.dart';

/// Cor de marca de cada recurso (chips, ícones, ordens). Compartilhada entre o
/// Mercado Central e o Comércio Informal para manter a mesma leitura visual.
Color resourceColor(String id) => switch (id) {
      'oxygen' => FwPalette.teal300,
      'water' => FwPalette.teal600,
      'biomass' => FwPalette.green600,
      'energy' => FwPalette.solar500,
      'metalore' => FwPalette.gray700,
      'alloys' => FwPalette.rust700,
      'biofuel' => FwPalette.green800,
      'chemicals' => FwPalette.teal700,
      'electronics' => FwPalette.purple600,
      // Recursos raros das 8 luas (§12.2 / §28.2)
      'niobium' => FwPalette.purple600,
      'helium3' => FwPalette.teal300,
      'quartz' => FwPalette.solar300,
      'rediron' => FwPalette.rust600,
      'resin' => FwPalette.green600,
      'methane' => FwPalette.teal500,
      'plasma' => FwPalette.red600,
      'biofungus' => FwPalette.green500,
      _ => FwPalette.gray500,
    };

IconData resourceIcon(String id) => switch (id) {
      'oxygen' => Icons.air_outlined,
      'water' => Icons.water_drop_outlined,
      'biomass' => Icons.eco_outlined,
      'energy' => Icons.bolt_outlined,
      'metalore' => Icons.terrain_outlined,
      'alloys' => Icons.view_in_ar_outlined,
      'biofuel' => Icons.local_fire_department_outlined,
      'chemicals' => Icons.science_outlined,
      'electronics' => Icons.memory_outlined,
      // Recursos raros das 8 luas (§12.2 / §28.2)
      'niobium' => Icons.diamond_outlined,
      'helium3' => Icons.ac_unit_outlined,
      'quartz' => Icons.hexagon_outlined,
      'rediron' => Icons.hardware_outlined,
      'resin' => Icons.spa_outlined,
      'methane' => Icons.severe_cold_outlined,
      'plasma' => Icons.whatshot_outlined,
      'biofungus' => Icons.local_florist_outlined,
      _ => Icons.category_outlined,
    };
