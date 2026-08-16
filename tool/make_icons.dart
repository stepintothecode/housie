// Writes the app artwork into assets/icon/.
//
//   dart run tool/make_icons.dart
//   dart run flutter_launcher_icons
//   dart run flutter_native_splash:create
//
// The files it writes are committed, and test/repo_tests/icons_test.dart
// fails if they no longer match what this produces.

import 'dart:io';

import 'icon_painter.dart';

/// Path to the bytes for it, relative to the repo root.
final artwork = <String, List<int> Function()>{
  'assets/icon/icon.png': () => paintIcon(1024),
  'assets/icon/icon-foreground.png': () => paintForeground(1024),
  'assets/icon/icon-monochrome.png': () => paintMonochrome(1024),
  'assets/icon/splash.png': () => paintSplash(512),
};

void main() {
  Directory('assets/icon').createSync(recursive: true);
  artwork.forEach((path, paint) {
    File(path).writeAsBytesSync(paint());
    stdout.writeln('wrote $path');
  });
}
