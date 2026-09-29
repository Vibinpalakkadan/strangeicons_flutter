import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strangeicons_flutter/strangeicons_flutter.dart';

void main() {
  test('icon count and lookup', () {
    expect(StrangeIcons.values.length, 544);
    expect(StrangeIcons.heart.hasStyle(StrangeIconStyle.duoline), isTrue);
  });

  testWidgets('every icon paints in every style', (tester) async {
    for (final style in StrangeIconStyle.values) {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Wrap(children: [
          for (final i in StrangeIcons.values) StrangeIcon(i, style: style),
        ]),
      ));
      expect(tester.takeException(), isNull);
    }
  });
}
