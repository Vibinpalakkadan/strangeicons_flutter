import 'dart:ui';

part 'icons.g.dart';

/// Visual style of an icon.
enum StrangeIconStyle { line, fill, duoline }

/// One vector path of an icon, in SVG path syntax (absolute M/L/H/V/C/Z).
class StrangePath {
  const StrangePath(
    this.d, {
    this.stroke = false,
    this.evenOdd = false,
    this.accent = false,
  });

  final String d;

  /// Drawn as a 2px round-capped stroke instead of a filled shape.
  final bool stroke;
  final bool evenOdd;

  /// Secondary layer of a duoline icon (drawn with the secondary colour).
  final bool accent;

  Path toPath() => parseSvgPath(d, evenOdd: evenOdd);
}

/// All paths for one style of one icon.
class StrangeIconLayer {
  const StrangeIconLayer(this.paths);
  final List<StrangePath> paths;
}

/// Vector data for one icon in every available style.
class StrangeIconData {
  const StrangeIconData._(this.name, {this.line, this.fill, this.duoline});

  final String name;
  final StrangeIconLayer? line;
  final StrangeIconLayer? fill;
  final StrangeIconLayer? duoline;

  /// The layer for [style], falling back to [line] when a style is missing.
  StrangeIconLayer layerFor(StrangeIconStyle style) {
    final l = switch (style) {
      StrangeIconStyle.line => line,
      StrangeIconStyle.fill => fill,
      StrangeIconStyle.duoline => duoline,
    };
    return l ?? line ?? duoline ?? fill!;
  }

  bool hasStyle(StrangeIconStyle style) => switch (style) {
    StrangeIconStyle.line => line != null,
    StrangeIconStyle.fill => fill != null,
    StrangeIconStyle.duoline => duoline != null,
  };
}

/// Minimal SVG path parser for absolute `M L H V C Z` commands.
Path parseSvgPath(String d, {bool evenOdd = false}) {
  final path = Path()
    ..fillType = evenOdd ? PathFillType.evenOdd : PathFillType.nonZero;
  final tokens = RegExp(r'[MLHVCZ]|-?\d*\.?\d+(?:e-?\d+)?').allMatches(d);
  final it = tokens.map((m) => m[0]!).toList();
  var i = 0;
  double n() => double.parse(it[i++]);
  double x = 0, y = 0;
  String cmd = 'M';
  while (i < it.length) {
    final t = it[i];
    if (RegExp(r'[A-Z]').hasMatch(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z') {
        path.close();
        continue;
      }
    }
    switch (cmd) {
      case 'M':
        x = n();
        y = n();
        path.moveTo(x, y);
        cmd = 'L';
      case 'L':
        x = n();
        y = n();
        path.lineTo(x, y);
      case 'H':
        x = n();
        path.lineTo(x, y);
      case 'V':
        y = n();
        path.lineTo(x, y);
      case 'C':
        final x1 = n(), y1 = n(), x2 = n(), y2 = n();
        x = n();
        y = n();
        path.cubicTo(x1, y1, x2, y2, x, y);
    }
  }
  return path;
}
