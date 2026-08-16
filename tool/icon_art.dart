// The app's artwork, as widgets, so it can be drawn with real type and real
// gradients. make_icons_test.dart rasterises these.
//
// The mark is a corner of a housie board: numbers under the little clear
// plastic domes that a real board has, with a called diagonal lit in the
// app's amber. It reads as a number board rather than as an abstract pattern,
// and the B I N G O strip along the top names the other game the app calls.

import 'package:flutter/material.dart';

import 'render.dart';

/// Same values as lib/app/theme/tokens.dart.
const _ink = Color(0xFF0E1117);
const _inkLift = Color(0xFF161C26);
const _cell = Color(0xFF2A323D);
const _cellEdge = Color(0xFF39434F);
const _amber = Color(0xFFFFB347);
const _amberDeep = Color(0xFFE89122);
const _amberInk = Color(0xFF3A2408);
const _muted = Color(0xFFA9B4C0);

/// The three by three crop of the board. The diagonal is called.
const _numbers = [
  [7, 19, 23],
  [41, 55, 68],
  [72, 84, 90],
];

/// The whole icon, background included. Used for iOS and the plain Android
/// launcher icon.
class IconArt extends StatelessWidget {
  const IconArt({super.key, required this.size, this.monochrome = false});

  final double size;

  /// Flat white on transparent, for Android's themed icons, which tint the
  /// alpha channel and throw the colour away.
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          // A touch lighter at the top, so the tile has some depth rather
          // than reading as a flat black square.
          gradient: monochrome
              ? null
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_inkLift, _ink],
                ),
        ),
        child: _Fitted(inset: size * 0.09, monochrome: monochrome),
      ),
    );
  }
}

/// The board on its own, on transparent. Used for the Android adaptive
/// foreground and the launch screen, both of which supply their own
/// background and crop inwards.
class IconMarkArt extends StatelessWidget {
  const IconMarkArt({
    super.key,
    required this.size,
    this.inset = 0.24,
    this.monochrome = false,
  });

  final double size;

  /// Fraction trimmed off each edge. Android crops an adaptive foreground to
  /// its middle 66%, so anything nearer the edge than this is lost.
  final double inset;

  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: _Fitted(inset: size * inset, monochrome: monochrome),
    );
  }
}

/// Draws the board at a fixed natural size and scales it to whatever is left
/// after [inset].
///
/// The board is taller than it is wide, because of the letters along the top,
/// so sizing its cells off the width alone runs it off the bottom of a square
/// canvas. Fitting the finished thing sidesteps the arithmetic and cannot
/// overflow whatever the numbers are changed to.
class _Fitted extends StatelessWidget {
  const _Fitted({required this.inset, required this.monochrome});

  final double inset;
  final bool monochrome;

  /// Arbitrary. Only the proportions inside the board matter; the fit decides
  /// how big it ends up.
  static const _natural = 1000.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(inset),
      child: FittedBox(
        child: _Board(width: _natural, monochrome: monochrome),
      ),
    );
  }
}

class _Board extends StatelessWidget {
  const _Board({required this.width, required this.monochrome});

  final double width;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final size = width;
    final gap = size * 0.045;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Both games named, one above the board and one below, so each word
        // gets the full width and its letters stay fat enough to survive
        // being shrunk to a home screen icon.
        _WordStrip('HOUSIE', size: size, monochrome: monochrome),
        SizedBox(height: gap * 1.2),
        for (var row = 0; row < 3; row++) ...[
          if (row > 0) SizedBox(height: gap),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var column = 0; column < 3; column++) ...[
                if (column > 0) SizedBox(width: gap),
                _Cell(
                  number: _numbers[row][column],
                  // The diagonal is the called line, which is what a board
                  // looks like part way through a game.
                  called: row == column,
                  size: (size - gap * 2) / 3,
                  monochrome: monochrome,
                ),
              ],
            ],
          ),
        ],
        SizedBox(height: gap * 1.2),
        _WordStrip('BINGO', size: size, monochrome: monochrome),
      ],
    );
  }
}

/// One game's name, letter-spaced across the width of the board, the way a
/// real board is headed.
class _WordStrip extends StatelessWidget {
  const _WordStrip(this.word, {required this.size, required this.monochrome});

  final String word;
  final double size;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (final letter in word.split(''))
            Text(
              letter,
              style: TextStyle(
                fontFamily: renderFont,
                // Heavy enough to survive being shrunk to a home screen
                // icon, where these become a band rather than five letters.
                fontSize: size * 0.15,
                fontWeight: FontWeight.w900,
                height: 1,
                color: monochrome
                    ? Colors.white.withValues(alpha: 0.85)
                    : _amber,
              ),
            ),
        ],
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.number,
    required this.called,
    required this.size,
    required this.monochrome,
  });

  final int number;
  final bool called;
  final double size;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final face = monochrome
        ? Colors.white.withValues(alpha: called ? 0.92 : 0.30)
        : null;

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // The cell itself, slightly domed by its own gradient.
          DecoratedBox(
            decoration: BoxDecoration(
              color: face,
              gradient: monochrome
                  ? null
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: called
                          ? const [_amber, _amberDeep]
                          : const [_cellEdge, _cell],
                    ),
              borderRadius: BorderRadius.circular(size * 0.24),
            ),
            child: const SizedBox.expand(),
          ),
          // The number, under the dome.
          Text(
            '$number',
            style: TextStyle(
              fontFamily: renderFont,
              fontSize: size * (number >= 10 ? 0.44 : 0.56),
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -size * 0.012,
              color: monochrome
                  ? (called
                        ? Colors.black.withValues(alpha: 0.6)
                        : Colors.white)
                  : (called ? _amberInk : _muted),
            ),
          ),
          // The clear plastic bulge over it. Two gradients: a wide sheen that
          // brightens towards the top left, and a small hard highlight where
          // a real dome catches the light.
          if (!monochrome) _Dome(size: size),
        ],
      ),
    );
  }
}

class _Dome extends StatelessWidget {
  const _Dome({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    final diameter = size * 0.86;
    return SizedBox.square(
      dimension: diameter,
      child: Stack(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.45),
                radius: 0.95,
                colors: [
                  Colors.white.withValues(alpha: 0.34),
                  Colors.white.withValues(alpha: 0.10),
                  Colors.white.withValues(alpha: 0.0),
                  Colors.black.withValues(alpha: 0.14),
                ],
                stops: const [0.0, 0.38, 0.72, 1.0],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: diameter * 0.035,
              ),
            ),
            child: const SizedBox.expand(),
          ),
          // The specular glint, up and to the left like the sheen.
          Align(
            alignment: const Alignment(-0.45, -0.55),
            child: SizedBox(
              width: diameter * 0.34,
              height: diameter * 0.24,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.55),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
