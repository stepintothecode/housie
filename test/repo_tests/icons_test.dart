import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/make_icons.dart';

/// The artwork in assets/icon/ is generated, not hand drawn. This fails if a
/// committed file no longer matches what tool/make_icons.dart produces, which
/// is the only thing stopping the two drifting apart.
void main() {
  test('the committed artwork matches the generator', () {
    for (final entry in artwork.entries) {
      final file = File(entry.key);
      expect(
        file.existsSync(),
        isTrue,
        reason: '${entry.key} is missing. Run: dart run tool/make_icons.dart',
      );
      expect(
        file.readAsBytesSync(),
        entry.value(),
        reason:
            '${entry.key} is out of date. Run: dart run tool/make_icons.dart',
      );
    }
  });
}
