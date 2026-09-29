import 'package:flutter/widgets.dart';

import 'icon_data.dart';

/// Draws a [StrangeIconData] at [size] using the ambient [IconTheme] colour.
///
/// ```dart
/// StrangeIcon(StrangeIcons.heart, style: StrangeIconStyle.duoline)
/// ```
class StrangeIcon extends StatelessWidget {
  const StrangeIcon(
    this.icon, {
    super.key,
    this.style = StrangeIconStyle.line,
    this.size,
    this.color,
    this.secondaryColor,
    this.secondaryOpacity = 0.4,
    this.semanticLabel,
  });

  final StrangeIconData icon;
  final StrangeIconStyle style;
  final double? size;
  final Color? color;

  /// Colour of the accent layer in [StrangeIconStyle.duoline]. Defaults to
  /// [color] at [secondaryOpacity].
  final Color? secondaryColor;
  final double secondaryOpacity;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = IconTheme.of(context);
    final s = size ?? theme.size ?? 24;
    final c = color ?? theme.color ?? const Color(0xFF000000);
    final layer = icon.layerFor(style);
    return Semantics(
      label: semanticLabel,
      image: true,
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: s,
          child: CustomPaint(
            painter: _Painter(
              layer,
              c,
              secondaryColor ?? c.withValues(alpha: c.a * secondaryOpacity),
              duo: style == StrangeIconStyle.duoline && icon.duoline != null,
            ),
          ),
        ),
      ),
    );
  }
}

final _cache = Expando<List<Path>>('strange_icon_paths');

class _Painter extends CustomPainter {
  _Painter(this.layer, this.color, this.accent, {required this.duo});

  final StrangeIconLayer layer;
  final Color color, accent;
  final bool duo;

  List<Path> get _paths =>
      _cache[layer] ??= [for (final p in layer.paths) p.toPath()];

  @override
  void paint(Canvas canvas, Size size) {
    final paths = _paths;
    Rect? b;
    for (final p in paths) {
      final r = p.getBounds();
      b = b == null ? r : b.expandToInclude(r);
    }
    if (b == null) return;
    // Stroke paths are centred on their outline, so pad for half the stroke.
    final hasStroke = layer.paths.any((p) => p.stroke);
    if (hasStroke) b = b.inflate(1);
    final k = size.width / 24;
    canvas
      ..scale(k)
      ..translate(12 - b.center.dx, 12 - b.center.dy);
    for (var i = 0; i < paths.length; i++) {
      final sp = layer.paths[i];
      final paint = Paint()
        ..isAntiAlias = true
        ..color = duo && sp.accent ? accent : color;
      if (sp.stroke) {
        paint
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
      }
      canvas.drawPath(paths[i], paint);
    }
  }

  @override
  bool shouldRepaint(_Painter o) =>
      o.layer != layer || o.color != color || o.accent != accent;
}
