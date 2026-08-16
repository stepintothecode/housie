// Draws the launcher and splash artwork.
//
// The mark is a three by three board with the diagonal called: the shape of a
// winning line, readable at 48 pixels, and no text to translate or blur.
//
// Kept apart from make_icons.dart so a test can redraw the artwork and compare
// it against the files committed to the repo.

import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart';

/// Same values as lib/app/theme/tokens.dart, as plain 0xRRGGBB.
const backgroundRgb = 0x0E1117;
const calledRgb = 0xFFB347;
const uncalledRgb = 0x2A323D;

/// Full bleed artwork, for the iOS icon and the plain Android icon.
Uint8List paintIcon(int size) => _png(
  _board(
    size: size,
    gridFraction: 0.62,
    background: _rgb(backgroundRgb),
    called: _rgb(calledRgb),
    uncalled: _rgb(uncalledRgb),
  ),
);

/// Transparent artwork for the Android adaptive foreground, drawn small
/// enough to survive the launcher cropping to its 66% safe zone.
Uint8List paintForeground(int size) => _png(
  _board(
    size: size,
    gridFraction: 0.40,
    background: _transparent,
    called: _rgb(calledRgb),
    uncalled: _rgb(uncalledRgb),
  ),
);

/// Single colour version, which Android 13 and later tint for themed icons.
Uint8List paintMonochrome(int size) => _png(
  _board(
    size: size,
    gridFraction: 0.40,
    background: _transparent,
    called: _rgb(0xFFFFFF),
    uncalled: _rgb(0xFFFFFF, alpha: 0x66),
  ),
);

/// The mark on its own, for the launch screen.
Uint8List paintSplash(int size) => _png(
  _board(
    size: size,
    gridFraction: 0.72,
    background: _transparent,
    called: _rgb(calledRgb),
    uncalled: _rgb(uncalledRgb),
  ),
);

Image _board({
  required int size,
  required double gridFraction,
  required Color background,
  required Color called,
  required Color uncalled,
}) {
  final canvas = Image(width: size, height: size, numChannels: 4);
  fill(canvas, color: background);

  final grid = size * gridFraction;
  final step = grid / 2;
  final origin = (size - grid) / 2;
  final radius = max(1, (grid * 0.16).round());

  for (var row = 0; row < 3; row++) {
    for (var column = 0; column < 3; column++) {
      fillCircle(
        canvas,
        x: (origin + column * step).round(),
        y: (origin + row * step).round(),
        radius: radius,
        color: row == column ? called : uncalled,
        antialias: true,
      );
    }
  }
  return canvas;
}

/// Level 6 rather than the default, so the bytes are small and, more
/// importantly, identical every run. The icons test compares them.
Uint8List _png(Image image) => encodePng(image, level: 6);

Color _rgb(int rgb, {int alpha = 0xFF}) =>
    ColorUint8.rgba((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF, alpha);

final _transparent = ColorUint8.rgba(0, 0, 0, 0);
