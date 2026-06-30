import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../domain/models/planet_models.dart';

/// Cor por relação política (colônias vizinhas) — compartilhada com a UI.
Color relationColor(Relation r) => switch (r) {
      Relation.self => FwPalette.rust600,
      Relation.ally => FwPalette.teal600,
      Relation.neutral => FwPalette.gray500,
      Relation.hostile => FwPalette.red600,
    };

/// Cor por recurso natural de uma zona neutra.
Color zoneResourceColor(ZoneResource k) => switch (k) {
      ZoneResource.water => FwPalette.teal600,
      ZoneResource.metals => FwPalette.rust700,
      ZoneResource.biomass => FwPalette.green600,
      ZoneResource.energy => FwPalette.solar500,
      ZoneResource.components => FwPalette.purple600,
      ZoneResource.none => FwPalette.gray500,
    };

IconData zoneResourceIcon(ZoneResource k) => switch (k) {
      ZoneResource.water => Icons.water_drop_outlined,
      ZoneResource.metals => Icons.view_in_ar_outlined,
      ZoneResource.biomass => Icons.eco_outlined,
      ZoneResource.energy => Icons.bolt_outlined,
      ZoneResource.components => Icons.memory_outlined,
      ZoneResource.none => Icons.help_outline,
    };

/// Ícone por nó do mapa (tipo + casos especiais de marco).
IconData mapNodeIcon(MapNode n) => switch (n.type) {
      MapNodeType.ownColony => Icons.account_balance_outlined,
      MapNodeType.neighborColony => Icons.location_city_outlined,
      MapNodeType.neutralZone => zoneResourceIcon(n.resource),
      MapNodeType.spaceport => Icons.rocket_launch_outlined,
      MapNodeType.landmark => n.id.contains('gagarin')
          ? Icons.travel_explore_outlined
          : (n.id.contains('endurance') ? Icons.rocket_outlined : Icons.place_outlined),
      MapNodeType.freeSlot => Icons.add,
    };

/// Cor principal de um nó (para chips/realces na UI).
Color mapNodeColor(MapNode n) => switch (n.type) {
      MapNodeType.ownColony => FwPalette.rust600,
      MapNodeType.neighborColony => relationColor(n.relation),
      MapNodeType.neutralZone => zoneResourceColor(n.resource),
      MapNodeType.spaceport => FwPalette.solar500,
      MapNodeType.landmark => FwPalette.gray500,
      MapNodeType.freeSlot => FwPalette.gray500,
    };

/// Mapa-planeta do Fertways (Solar Frontier): terreno ilustrado 3:2 com regiões
/// de bioma, sua colônia central, colônias vizinhas, zonas neutras, espaçoporto
/// e marcos. Pan (arrastar) + zoom (pinça/scroll), com câmera travada na imagem
/// (min-zoom = planeta inteiro). Tocar num nó dispara [onNodeTap].
class FertwaysWorldGame extends FlameGame with ScaleDetector, ScrollDetector {
  FertwaysWorldGame(this.state, {this.onNodeTap});

  final PlanetState state;
  final void Function(MapNode node)? onNodeTap;

  /// Terreno 3:2 centrado na origem (placeholder até a arte nova chegar).
  static const double terrainW = 2400;
  static const double terrainH = 1600;
  static const double _maxZoom = 2.4;

  double _minZoom = 0.3;
  double _startZoom = 1;

  /// Id do nó atualmente selecionado (desenha um realce no mapa). Setado pela UI.
  String? selectedId;

  @override
  Color backgroundColor() => FwPalette.gray950; // "espaço" — moldura intencional

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final sprite = await loadSprite('mars-solar-frontier-map-v6.png');
      world.add(
        SpriteComponent(
          sprite: sprite,
          anchor: Anchor.center,
          position: Vector2.zero(),
          size: Vector2(terrainW, terrainH),
          priority: -20,
        ),
      );
    } catch (_) {
      // sem arte: segue só com o fundo escuro + nós
    }
    world.add(_RegionLayer(state));
    for (final n in state.nodes) {
      world.add(_NodeComponent(node: n, onTap: onNodeTap));
    }
    _recomputeMinZoom();
    resetView();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (!isLoaded) return;
    _recomputeMinZoom();
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(_minZoom, _maxZoom);
    _clamp();
  }

  void _recomputeMinZoom() {
    final vp = camera.viewport.size;
    if (vp.x <= 0 || vp.y <= 0) return;
    // "cover": o terreno preenche o frame inteiro — sem faixa preta/branca nas
    // bordas em qualquer proporção de tela. O excedente é navegável por pan.
    _minZoom = math.max(vp.x / terrainW, vp.y / terrainH);
    if (_minZoom > _maxZoom) _minZoom = _maxZoom;
  }

  /// Reenquadra: planeta inteiro, centrado.
  void resetView() {
    camera.viewfinder.zoom = _minZoom;
    camera.viewfinder.position = Vector2.zero();
    _clamp();
  }

  void zoomBy(double factor) {
    camera.viewfinder.zoom = (camera.viewfinder.zoom * factor).clamp(_minZoom, _maxZoom);
    _clamp();
  }

  /// Trava a câmera nas bordas do terreno (sem "vazar" para o espaço).
  void _clamp() {
    final vp = camera.viewport.size;
    final z = camera.viewfinder.zoom;
    if (z <= 0) return;
    final halfW = vp.x / (2 * z);
    final halfH = vp.y / (2 * z);
    final maxX = terrainW / 2 - halfW;
    final maxY = terrainH / 2 - halfH;
    final p = camera.viewfinder.position;
    final nx = maxX <= 0 ? 0.0 : p.x.clamp(-maxX, maxX).toDouble();
    final ny = maxY <= 0 ? 0.0 : p.y.clamp(-maxY, maxY).toDouble();
    camera.viewfinder.position = Vector2(nx, ny);
  }

  @override
  void onScaleStart(ScaleStartInfo info) => _startZoom = camera.viewfinder.zoom;

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final delta = info.delta.global;
    camera.viewfinder.position += -delta / camera.viewfinder.zoom;
    final scale = info.scale.global;
    if ((scale.y - 1).abs() > 0.001) {
      camera.viewfinder.zoom = (_startZoom * scale.y).clamp(_minZoom, _maxZoom);
    }
    _clamp();
  }

  @override
  void onScroll(PointerScrollInfo info) {
    final dy = info.scrollDelta.global.y;
    camera.viewfinder.zoom = (camera.viewfinder.zoom - dy / 600).clamp(_minZoom, _maxZoom);
    _clamp();
  }
}

/// Camada de fundo lógico: estradas da colônia até zonas/espaçoporto + rótulos
/// das regiões de bioma. Não interativa.
class _RegionLayer extends PositionComponent {
  _RegionLayer(this.state) : super(priority: -10);
  final PlanetState state;

  @override
  void render(Canvas canvas) {
    // estradas suaves da Capital (origem) até zonas e espaçoporto
    for (final n in state.nodes) {
      if (n.type != MapNodeType.neutralZone && n.type != MapNodeType.spaceport) {
        continue;
      }
      canvas.drawLine(
        Offset.zero,
        Offset(n.x, n.y),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..color = FwPalette.gray100.withValues(alpha: 0.18),
      );
    }
    // rótulos de região (proper nouns vindos do fixture)
    for (final r in state.regions) {
      _label(canvas, r.name, Offset(r.x, r.y));
    }
  }

  void _label(Canvas canvas, String text, Offset center) {
    final tp = TextPainter(
      text: TextSpan(
        text: text.toUpperCase(),
        style: TextStyle(
          color: FwPalette.gray100.withValues(alpha: 0.42),
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}

/// Nó tocável no mapa-planeta (colônia, zona, espaçoporto, marco).
class _NodeComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FertwaysWorldGame> {
  _NodeComponent({required this.node, this.onTap})
      : super(
          position: Vector2(node.x, node.y),
          size: _sizeFor(node.type),
          anchor: Anchor.center,
        );

  final MapNode node;
  final void Function(MapNode node)? onTap;

  Sprite? _ownSprite;

  static Vector2 _sizeFor(MapNodeType t) => switch (t) {
        MapNodeType.ownColony => Vector2(150, 150),
        MapNodeType.spaceport => Vector2(76, 76),
        MapNodeType.neutralZone => Vector2(72, 72),
        MapNodeType.neighborColony => Vector2(64, 64),
        MapNodeType.landmark => Vector2(56, 56),
        MapNodeType.freeSlot => Vector2(64, 64),
      };

  @override
  Future<void> onLoad() async {
    if (node.type != MapNodeType.ownColony) return;
    try {
      _ownSprite = await game.loadSprite('capital-v1.png');
    } catch (_) {
      // fallback vetorial no render()
    }
  }

  @override
  void onTapDown(TapDownEvent event) => onTap?.call(node);

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    if (game.selectedId == node.id) _renderSelection(canvas, center);
    switch (node.type) {
      case MapNodeType.ownColony:
        _renderOwnColony(canvas, center);
      case MapNodeType.neutralZone:
        _renderZone(canvas, center);
      case MapNodeType.neighborColony:
        _renderNeighbor(canvas, center);
      case MapNodeType.spaceport:
        _renderSpaceport(canvas, center);
      case MapNodeType.landmark:
        _renderLandmark(canvas, center);
      case MapNodeType.freeSlot:
        _renderFreeSlot(canvas, center);
    }
  }

  void _renderSelection(Canvas canvas, Offset center) {
    final r = node.type == MapNodeType.ownColony ? 54.0 : 30.0;
    canvas.drawCircle(center, r + 4,
        Paint()
          ..color = FwPalette.solar400.withValues(alpha: 0.22)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
    canvas.drawCircle(center, r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = FwPalette.solar500);
  }

  void _renderOwnColony(Canvas canvas, Offset center) {
    // halo "você"
    canvas.drawCircle(center, 58,
        Paint()
          ..color = FwPalette.rust600.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18));
    canvas.drawCircle(center, 50,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = FwPalette.rust600.withValues(alpha: 0.65));

    if (_ownSprite != null) {
      const w = 120.0;
      _ownSprite!.render(canvas,
          position: Vector2(center.dx - w / 2, center.dy - w * 0.78), size: Vector2.all(w));
    } else {
      canvas.drawCircle(center, 30, Paint()..color = FwPalette.rust600);
      canvas.drawCircle(center, 21, Paint()..color = FwPalette.white);
      _icon(canvas, Icons.account_balance_outlined, center, 22, FwPalette.rust600);
    }
    _levelBadge(canvas, center.translate(34, -30), FwPalette.rust600);
    _namePill(canvas, node.name, center.translate(0, 48),
        bg: FwPalette.rust50, fg: FwPalette.gray900, bold: true);
  }

  void _renderNeighbor(Canvas canvas, Offset center) {
    final color = relationColor(node.relation);
    _shadow(canvas, center, 22);
    canvas.drawCircle(center, 22, Paint()..color = FwPalette.white);
    canvas.drawCircle(center, 22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color);
    _icon(canvas, Icons.location_city_outlined, center, 20, color);
    _levelBadge(canvas, center.translate(18, 18), color);
    _namePill(canvas, node.name, center.translate(0, 40));
  }

  void _renderZone(Canvas canvas, Offset center) {
    final color = zoneResourceColor(node.resource);
    _shadow(canvas, center, 23);
    // anel externo translúcido = disputável
    canvas.drawCircle(center, 27,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.45));
    canvas.drawCircle(center, 22, Paint()..color = FwPalette.gray50);
    canvas.drawCircle(center, 22,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color);
    _icon(canvas, zoneResourceIcon(node.resource), center, 20, color);
    _levelBadge(canvas, center.translate(19, 19), color);
    _namePill(canvas, node.name, center.translate(0, 42));
  }

  void _renderSpaceport(Canvas canvas, Offset center) {
    const color = FwPalette.solar600;
    _shadow(canvas, center, 24);
    canvas.drawCircle(center, 28,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = color.withValues(alpha: 0.45));
    canvas.drawCircle(center, 23, Paint()..color = FwPalette.white);
    canvas.drawCircle(center, 23,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = color);
    _icon(canvas, Icons.rocket_launch_outlined, center, 21, color);
    _namePill(canvas, node.name, center.translate(0, 44),
        bg: FwPalette.solar100, fg: FwPalette.solar700);
  }

  void _renderLandmark(Canvas canvas, Offset center) {
    canvas.drawCircle(center, 18, Paint()..color = FwPalette.gray950.withValues(alpha: 0.42));
    canvas.drawCircle(center, 18,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = FwPalette.solar300.withValues(alpha: 0.7));
    _icon(canvas, mapNodeIcon(node), center, 17, FwPalette.solar100);
    _namePill(canvas, node.name, center.translate(0, 32),
        bg: FwPalette.gray900, fg: FwPalette.gray50);
  }

  void _renderFreeSlot(Canvas canvas, Offset center) {
    _shadow(canvas, center, 20);
    canvas.drawCircle(center, 20, Paint()..color = FwPalette.white.withValues(alpha: 0.85));
    _dashedCircle(canvas, center, 20, FwPalette.gray500);
    _icon(canvas, Icons.add, center, 22, FwPalette.gray600);
    _namePill(canvas, node.name, center.translate(0, 38),
        bg: FwPalette.gray100, fg: FwPalette.gray600);
  }

  void _dashedCircle(Canvas canvas, Offset center, double r, Color color) {
    const segments = 14;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..color = color;
    final rect = Rect.fromCircle(center: center, radius: r);
    for (var i = 0; i < segments; i++) {
      final start = (i / segments) * 2 * math.pi;
      canvas.drawArc(rect, start, (2 * math.pi / segments) * 0.55, false, paint);
    }
  }

  void _shadow(Canvas canvas, Offset center, double r) {
    canvas.drawCircle(center.translate(0, 4), r,
        Paint()
          ..color = FwPalette.gray950.withValues(alpha: 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
  }

  void _levelBadge(Canvas canvas, Offset at, Color color) {
    if (node.level <= 0) return;
    canvas.drawCircle(at, 11, Paint()..color = color);
    canvas.drawCircle(at, 11,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = FwPalette.white);
    final tp = TextPainter(
      text: TextSpan(
          text: '${node.level}',
          style: const TextStyle(color: FwPalette.white, fontSize: 11, fontWeight: FontWeight.w700)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, at - Offset(tp.width / 2, tp.height / 2));
  }

  void _namePill(Canvas canvas, String text, Offset center,
      {Color bg = FwPalette.white, Color fg = FwPalette.gray900, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final s = tp.size;
    final rect = Rect.fromCenter(center: center, width: s.width + 16, height: s.height + 8);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rr, Paint()..color = bg.withValues(alpha: 0.96));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = FwPalette.gray300);
    tp.paint(canvas, center - Offset(s.width / 2, s.height / 2));
  }

  void _icon(Canvas canvas, IconData icon, Offset center, double sizePx, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: sizePx,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }
}
