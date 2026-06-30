import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

import '../../../app/theme/ds_colors.dart';
import '../../../domain/models/colony_lots.dart';
import '../../../domain/models/world_models.dart';

/// Sprite isométrico por tipo de lote (reusa a arte já existente).
String? colonyLotSprite(PlotKind k) => switch (k) {
      PlotKind.factory => 'plot-factory-v1.png',
      PlotKind.water => 'plot-water-v1.png',
      PlotKind.metals => 'plot-metals-v1.png',
      PlotKind.biomass => 'plot-biomass-v1.png',
      PlotKind.energy => 'plot-energy-v1.png',
      PlotKind.capital => 'capital-v1.png',
      _ => null,
    };

Color colonyLotColor(PlotKind k) => switch (k) {
      PlotKind.water => FwPalette.teal600,
      PlotKind.metals => FwPalette.rust700,
      PlotKind.biomass => FwPalette.green600,
      PlotKind.energy => FwPalette.solar500,
      PlotKind.factory => FwPalette.rust600,
      PlotKind.capital => FwPalette.rust600,
      _ => FwPalette.gray500,
    };

IconData colonyLotIcon(PlotKind k) => switch (k) {
      PlotKind.water => Icons.water_drop_outlined,
      PlotKind.metals => Icons.view_in_ar_outlined,
      PlotKind.biomass => Icons.eco_outlined,
      PlotKind.energy => Icons.bolt_outlined,
      PlotKind.factory => Icons.factory_outlined,
      PlotKind.capital => Icons.account_balance_outlined,
      _ => Icons.add,
    };

/// Vista da Colônia (nível entre Planeta e Capital): terreno + Capital central
/// e lotes de recurso (com sprites), além de lotes livres claimáveis. Pan/zoom
/// com câmera travada na imagem. Tocar num lote dispara [onLotTap].
class FertwaysColonyGame extends FlameGame with ScaleDetector, ScrollDetector {
  FertwaysColonyGame(this.layout, {this.onLotTap});

  final ColonyLayout layout;
  final void Function(ColonyLot lot)? onLotTap;

  static const double terrainW = 1600;
  static const double terrainH = 1067;
  static const double _maxZoom = 2.6;

  double _minZoom = 0.5;
  double _startZoom = 1;
  String? selectedId;

  @override
  Color backgroundColor() => FwPalette.gray950;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    try {
      final sprite = await loadSprite('colony-ground-dawn-v1.png');
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
      // sem arte: fundo escuro + lotes
    }
    world.add(_RoadLayer(layout));
    for (final l in layout.lots) {
      world.add(_LotComponent(lot: l, onTap: onLotTap));
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
    // "cover": terreno preenche o frame inteiro, sem faixa preta/branca.
    _minZoom = math.max(vp.x / terrainW, vp.y / terrainH);
    if (_minZoom > _maxZoom) _minZoom = _maxZoom;
  }

  void resetView() {
    camera.viewfinder.zoom = _minZoom;
    camera.viewfinder.position = Vector2.zero();
    _clamp();
  }

  void zoomBy(double factor) {
    camera.viewfinder.zoom = (camera.viewfinder.zoom * factor).clamp(_minZoom, _maxZoom);
    _clamp();
  }

  void _clamp() {
    final vp = camera.viewport.size;
    final z = camera.viewfinder.zoom;
    if (z <= 0) return;
    final maxX = terrainW / 2 - vp.x / (2 * z);
    final maxY = terrainH / 2 - vp.y / (2 * z);
    final p = camera.viewfinder.position;
    final nx = maxX <= 0 ? 0.0 : p.x.clamp(-maxX, maxX).toDouble();
    final ny = maxY <= 0 ? 0.0 : p.y.clamp(-maxY, maxY).toDouble();
    camera.viewfinder.position = Vector2(nx, ny);
  }

  @override
  void onScaleStart(ScaleStartInfo info) => _startZoom = camera.viewfinder.zoom;

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    camera.viewfinder.position += -info.delta.global / camera.viewfinder.zoom;
    final scale = info.scale.global;
    if ((scale.y - 1).abs() > 0.001) {
      camera.viewfinder.zoom = (_startZoom * scale.y).clamp(_minZoom, _maxZoom);
    }
    _clamp();
  }

  @override
  void onScroll(PointerScrollInfo info) {
    camera.viewfinder.zoom =
        (camera.viewfinder.zoom - info.scrollDelta.global.y / 600).clamp(_minZoom, _maxZoom);
    _clamp();
  }
}

/// Estradas suaves da Capital até cada lote.
class _RoadLayer extends PositionComponent {
  _RoadLayer(this.layout) : super(priority: -10);
  final ColonyLayout layout;

  @override
  void render(Canvas canvas) {
    for (final l in layout.lots) {
      if (l.isCapital) continue;
      canvas.drawLine(
        Offset.zero,
        Offset(l.dx, l.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round
          ..color = FwPalette.gray50.withValues(alpha: 0.32),
      );
    }
  }
}

/// Lote tocável (Capital, recurso ou livre).
class _LotComponent extends PositionComponent
    with TapCallbacks, HasGameReference<FertwaysColonyGame> {
  _LotComponent({required this.lot, this.onTap})
      : super(
          position: Vector2(lot.dx, lot.dy),
          size: _sizeFor(lot),
          anchor: Anchor.center,
        );

  final ColonyLot lot;
  final void Function(ColonyLot lot)? onTap;

  Sprite? _sprite;

  static Vector2 _sizeFor(ColonyLot l) {
    if (l.isCapital) return Vector2(150, 150);
    if (l.isFree) return Vector2(72, 72);
    return Vector2(124, 124);
  }

  @override
  Future<void> onLoad() async {
    final asset = colonyLotSprite(lot.kind);
    if (asset == null) return;
    try {
      _sprite = await game.loadSprite(asset);
    } catch (_) {
      // mantém fallback vetorial
    }
  }

  @override
  void onTapDown(TapDownEvent event) => onTap?.call(lot);

  @override
  void render(Canvas canvas) {
    final center = Offset(size.x / 2, size.y / 2);
    if (game.selectedId == lot.id) _renderSelection(canvas, center);
    if (lot.isFree) {
      _renderFree(canvas, center);
    } else {
      _renderBuilt(canvas, center);
    }
  }

  void _renderSelection(Canvas canvas, Offset center) {
    final r = lot.isCapital ? 56.0 : (lot.isFree ? 28.0 : 50.0);
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

  void _renderBuilt(Canvas canvas, Offset center) {
    final color = colonyLotColor(lot.kind);
    final spriteW = lot.isCapital ? 120.0 : 104.0;
    if (_sprite != null) {
      _sprite!.render(canvas,
          position: Vector2(center.dx - spriteW / 2, center.dy - spriteW * 0.74),
          size: Vector2.all(spriteW));
    } else {
      canvas.drawCircle(center, 26, Paint()..color = FwPalette.white);
      canvas.drawCircle(center, 26,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3
            ..color = color);
      _icon(canvas, colonyLotIcon(lot.kind), center, 22, color);
    }
    _levelBadge(canvas, center.translate(spriteW * 0.30, -spriteW * 0.30), color);
    if (!lot.isCapital && lot.perHour != 0) {
      _prodPill(canvas, lot.perHour, center.translate(0, 30));
    }
    _namePill(canvas, lot.name, center.translate(0, 50),
        bg: lot.isCapital ? FwPalette.rust50 : FwPalette.white,
        fg: FwPalette.gray900,
        bold: lot.isCapital);
  }

  void _renderFree(Canvas canvas, Offset center) {
    canvas.drawCircle(center.translate(0, 4), 20,
        Paint()
          ..color = FwPalette.gray950.withValues(alpha: 0.28)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawCircle(center, 20, Paint()..color = FwPalette.white.withValues(alpha: 0.85));
    _dashedCircle(canvas, center, 20, FwPalette.gray500);
    _icon(canvas, Icons.add, center, 22, FwPalette.gray600);
    _namePill(canvas, lot.name, center.translate(0, 38),
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
      canvas.drawArc(rect, (i / segments) * 2 * math.pi, (2 * math.pi / segments) * 0.55, false, paint);
    }
  }

  void _levelBadge(Canvas canvas, Offset at, Color color) {
    canvas.drawCircle(at, 11, Paint()..color = color);
    canvas.drawCircle(at, 11,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = FwPalette.white);
    _text(canvas, '${lot.level}', at, const TextStyle(color: FwPalette.white, fontSize: 11, fontWeight: FontWeight.w700));
  }

  void _prodPill(Canvas canvas, int perHour, Offset center) {
    final up = perHour >= 0;
    final txt = '${up ? '+' : ''}$perHour/h';
    final tp = _layout(txt, TextStyle(color: up ? FwPalette.green600 : FwPalette.red600, fontSize: 11, fontWeight: FontWeight.w700));
    final rect = Rect.fromCenter(center: center, width: tp.width + 14, height: tp.height + 7);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(7));
    canvas.drawRRect(rr, Paint()..color = (up ? FwPalette.green500 : FwPalette.red500).withValues(alpha: 0.14));
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _namePill(Canvas canvas, String text, Offset center,
      {Color bg = FwPalette.white, Color fg = FwPalette.gray900, bool bold = false}) {
    final tp = _layout(text, TextStyle(color: fg, fontSize: 12, fontWeight: bold ? FontWeight.w700 : FontWeight.w600));
    final rect = Rect.fromCenter(center: center, width: tp.width + 16, height: tp.height + 8);
    final rr = RRect.fromRectAndRadius(rect, const Radius.circular(8));
    canvas.drawRRect(rr, Paint()..color = bg.withValues(alpha: 0.96));
    canvas.drawRRect(rr,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = FwPalette.gray300);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _icon(Canvas canvas, IconData icon, Offset center, double sizePx, Color color) {
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: sizePx, fontFamily: icon.fontFamily, package: icon.fontPackage, color: color),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  void _text(Canvas canvas, String text, Offset center, TextStyle style) {
    final tp = _layout(text, style);
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  TextPainter _layout(String text, TextStyle style) => TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      )..layout();
}
