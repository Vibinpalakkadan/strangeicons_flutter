import 'package:flutter/material.dart';
import 'package:strangeicons_flutter/strangeicons_flutter.dart';

void main() => runApp(const MaterialApp(home: Gallery()));

class Gallery extends StatefulWidget {
  const Gallery({super.key});
  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  var style = StrangeIconStyle.line;
  var query = '';

  @override
  Widget build(BuildContext context) {
    final icons = StrangeIcons.values
        .where((i) => i.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return Scaffold(
      appBar: AppBar(
        title: Text('strangeicons_flutter (${icons.length})'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(96),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              TextField(
                decoration: const InputDecoration(hintText: 'Search', isDense: true),
                onChanged: (v) => setState(() => query = v),
              ),
              const SizedBox(height: 8),
              SegmentedButton<StrangeIconStyle>(
                segments: [
                  for (final s in StrangeIconStyle.values)
                    ButtonSegment(value: s, label: Text(s.name)),
                ],
                selected: {style},
                onSelectionChanged: (s) => setState(() => style = s.first),
              ),
            ]),
          ),
        ),
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 110),
        itemCount: icons.length,
        itemBuilder: (_, n) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StrangeIcon(icons[n], style: style, size: 32),
            const SizedBox(height: 6),
            Text(icons[n].name,
                maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
