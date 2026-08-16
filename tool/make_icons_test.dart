// Draws the app artwork into assets/icon/.
//
//   flutter test tool/make_icons_test.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// Runs under `flutter test` because the artwork is Flutter widgets, and
// rendering those needs a binding and a rasteriser. It is not a test: it
// writes files. Named to match anyway, because that is the only way the
// runner will execute it. `flutter test` on its own scans test/ and never
// reaches this.
//
// The output is not byte-for-byte reproducible across machines, because text
// rasterisation differs between platforms. test/repo_tests/icons_test.dart
// therefore checks the shape of the files rather than their contents. Redraw
// them on one machine and commit the result.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'icon_art.dart';
import 'render.dart';

/// Everything written, and how big.
const _artwork = [
  (name: 'icon', size: 1024.0, kind: _Kind.full),
  (name: 'icon-foreground', size: 1024.0, kind: _Kind.foreground),
  (name: 'icon-monochrome', size: 1024.0, kind: _Kind.monochrome),
  (name: 'splash', size: 512.0, kind: _Kind.splash),
];

enum _Kind { full, foreground, monochrome, splash }

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadBundledFonts);

  for (final art in _artwork) {
    testWidgets(art.name, timeout: const Timeout(Duration(seconds: 90)), (
      tester,
    ) async {
      final key = GlobalKey();
      final size = art.size;

      final child = switch (art.kind) {
        _Kind.full => IconArt(size: size),
        // Android crops an adaptive foreground to its middle 66%, so the
        // board is drawn well inside the edges.
        _Kind.foreground => IconMarkArt(size: size),
        _Kind.monochrome => IconMarkArt(size: size, monochrome: true),
        // The launch screen supplies its own background and shows the mark
        // smaller, so it needs less inset than the launcher does.
        _Kind.splash => IconMarkArt(size: size, inset: 0.08),
      };

      tester.view.physicalSize = Size(size, size);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: RepaintBoundary(key: key, child: child),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await captureToPng(tester, key: key, path: 'assets/icon/${art.name}.png');
    });
  }
}
