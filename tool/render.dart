// Shared plumbing for the two tools that rasterise Flutter widgets to PNG:
// make_icons_test.dart and screenshots_test.dart.
//
// Both have to run under `flutter test`, because rendering a widget needs a
// binding and a rasteriser, and neither is a test in any real sense.

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The family the bundled Roboto is registered under.
///
/// The app itself names no font and takes the platform's. A test binding has
/// no platform font, so anything rendered here has to ask for this one by
/// name or every glyph comes out as a filled box.
const renderFont = 'BundledRoboto';

/// Registers Roboto and the Material icons that ship inside the Flutter SDK.
///
/// Using the SDK's own copies rather than whatever the host machine has
/// installed keeps the output the same on any machine with the same SDK.
Future<void> loadBundledFonts() async {
  final cache = _materialFontsDir();
  if (cache == null) {
    stdout.writeln('material_fonts not found: text will render as boxes');
    return;
  }

  const weights = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ];
  final text = FontLoader(renderFont);
  for (final name in weights) {
    final file = File('$cache/$name');
    if (file.existsSync()) text.addFont(_bytes(file));
  }
  await text.load();

  final icons = FontLoader('MaterialIcons')
    ..addFont(_bytes(File('$cache/materialicons-regular.otf')));
  await icons.load();

  stdout.writeln('fonts loaded from $cache');
}

/// Rasterises the boundary behind [key] and writes it to [path].
///
/// Call after pumping. Decoding and rasterising are real asynchronous work
/// that a widget test's fake clock never lets finish on its own.
Future<void> captureToPng(
  WidgetTester tester, {
  required GlobalKey key,
  required String path,
  double pixelRatio = 1,
}) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump();

  final boundary = tester.renderObject<RenderRepaintBoundary>(find.byKey(key));
  final image = await boundary.toImage(pixelRatio: pixelRatio);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  File(path).parent.createSync(recursive: true);
  File(path).writeAsBytesSync(data!.buffer.asUint8List());
  stdout.writeln('wrote $path');
}

Future<ByteData> _bytes(File file) async =>
    ByteData.sublistView(file.readAsBytesSync());

/// Walks from the running Flutter tool to the fonts bundled with it.
String? _materialFontsDir() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (flutterRoot != null) '$flutterRoot/bin/cache/artifacts/material_fonts',
    r'C:\src\flutter\bin\cache\artifacts\material_fonts',
  ];
  for (final path in candidates) {
    if (Directory(path).existsSync()) return path;
  }
  return null;
}
