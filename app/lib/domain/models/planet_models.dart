import 'package:flutter/foundation.dart';

/// Tipo de nó no mapa-planeta (macro MMO).
enum MapNodeType { ownColony, neighborColony, neutralZone, spaceport, landmark, freeSlot }

/// Relação política de uma colônia vizinha com o jogador.
enum Relation { self, ally, neutral, hostile }

/// Recurso natural associado a uma zona neutra (depósito disputável, GDD §7).
enum ZoneResource { water, metals, biomass, energy, components, none }

MapNodeType _typeFrom(String s) => switch (s) {
      'own' || 'ownColony' => MapNodeType.ownColony,
      'neighbor' || 'neighborColony' => MapNodeType.neighborColony,
      'zone' || 'neutralZone' => MapNodeType.neutralZone,
      'spaceport' => MapNodeType.spaceport,
      'landmark' => MapNodeType.landmark,
      'free' || 'freeSlot' => MapNodeType.freeSlot,
      _ => MapNodeType.landmark,
    };

Relation _relationFrom(String? s) => switch (s) {
      'self' => Relation.self,
      'ally' => Relation.ally,
      'hostile' => Relation.hostile,
      _ => Relation.neutral,
    };

ZoneResource _resourceFrom(String? s) => switch (s) {
      'water' => ZoneResource.water,
      'metals' => ZoneResource.metals,
      'biomass' => ZoneResource.biomass,
      'energy' => ZoneResource.energy,
      'components' => ZoneResource.components,
      _ => ZoneResource.none,
    };

/// Um nó no mapa-planeta. x/y são coordenadas de mundo (Capital perto de 0,0)
/// no espaço Flame; o terreno é 3:2 centrado na origem.
@immutable
class MapNode {
  const MapNode({
    required this.id,
    required this.name,
    required this.type,
    required this.x,
    required this.y,
    this.relation = Relation.neutral,
    this.resource = ZoneResource.none,
    this.level = 0,
    this.owner,
    this.sector,
    this.note,
  });

  final String id;
  final String name;
  final MapNodeType type;
  final double x;
  final double y;
  final Relation relation;
  final ZoneResource resource; // só para zonas neutras
  final int level; // nível da colônia OU nível do depósito (zona)
  final String? owner; // dono (colônia vizinha)
  final String? sector; // código de setor, ex. "F-07"
  final String? note; // texto de lore (marcos)

  factory MapNode.fromJson(Map<String, dynamic> j) => MapNode(
        id: j['id'] as String,
        name: j['name'] as String,
        type: _typeFrom(j['type'] as String? ?? 'landmark'),
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
        relation: _relationFrom(j['relation'] as String?),
        resource: _resourceFrom(j['resource'] as String?),
        level: j['level'] as int? ?? 0,
        owner: j['owner'] as String?,
        sector: j['sector'] as String?,
        note: j['note'] as String?,
      );
}

/// Rótulo de região geográfica (bioma) desenhado sobre o terreno.
@immutable
class PlanetRegion {
  const PlanetRegion({required this.name, required this.x, required this.y});

  final String name;
  final double x;
  final double y;

  factory PlanetRegion.fromJson(Map<String, dynamic> j) => PlanetRegion(
        name: j['name'] as String,
        x: (j['x'] as num).toDouble(),
        y: (j['y'] as num).toDouble(),
      );
}

/// Estado do mapa-planeta (mock).
@immutable
class PlanetState {
  const PlanetState({
    required this.name,
    required this.ownSector,
    required this.regions,
    required this.nodes,
  });

  final String name;
  final String ownSector;
  final List<PlanetRegion> regions;
  final List<MapNode> nodes;

  factory PlanetState.fromJson(Map<String, dynamic> j) => PlanetState(
        name: j['name'] as String? ?? 'Fertways',
        ownSector: j['ownSector'] as String? ?? '',
        regions: (j['regions'] as List<dynamic>? ?? const [])
            .map((e) => PlanetRegion.fromJson(e as Map<String, dynamic>))
            .toList(),
        nodes: (j['nodes'] as List<dynamic>? ?? const [])
            .map((e) => MapNode.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
