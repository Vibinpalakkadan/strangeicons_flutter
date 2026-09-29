# strangeicons_flutter

544 icons in three styles (`line`, `fill`, `duoline`) for Flutter, drawn from vector paths.
Artwork derived from [strangeicons](https://strangeicons.com) (MIT, by indigoscipio).

```dart
import 'package:strangeicons_flutter/strangeicons_flutter.dart';

StrangeIcon(StrangeIcons.heart);                                  // line
StrangeIcon(StrangeIcons.heart, style: StrangeIconStyle.fill, size: 32, color: Colors.red);
StrangeIcon(StrangeIcons.heart, style: StrangeIconStyle.duoline, secondaryColor: Colors.pink);
```

- Size defaults to `IconTheme` size (24); colour to `IconTheme` colour.
- Duoline: the accent layer uses `secondaryColor`, or `color` at `secondaryOpacity` (0.4).
- If an icon lacks a style, it falls back to `line`. Check with `icon.hasStyle(style)`.
- `StrangeIcons.values` lists every icon; see `example/` for a searchable gallery.

## Regenerating
`python3 tool/generate.py tool/icon_paths.json` rewrites `lib/src/icons.g.dart`.
