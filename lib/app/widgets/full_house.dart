import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A shower of housie balls and a shout of FULL HOUSE, for the seven tap
/// easter egg on the about screen.
///
/// Nothing in the app depends on this and nothing breaks if it is deleted.
class FullHouse extends StatefulWidget {
  const FullHouse({super.key});

  /// How long the whole thing lasts before it clears itself away.
  static const duration = Duration(milliseconds: 4200);

  /// Drops it over whatever is on screen. Tapping anywhere skips it.
  static Future<void> celebrate(BuildContext context) {
    return Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black.withValues(alpha: 0.55),
        barrierDismissible: true,
        transitionDuration: const Duration(milliseconds: 160),
        pageBuilder: (_, _, _) => const FullHouse(),
      ),
    );
  }

  @override
  State<FullHouse> createState() => _FullHouseState();
}

class _FullHouseState extends State<FullHouse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _run = AnimationController(
    vsync: this,
    duration: FullHouse.duration,
  );

  late final List<_Ball> _balls;

  @override
  void initState() {
    super.initState();
    // Seeded from nothing in particular: a different shower each time is part
    // of the fun.
    final random = Random();
    _balls = [
      for (var i = 0; i < _count; i++)
        _Ball(
          across: random.nextDouble(),
          drift: random.nextDouble() * 0.24 - 0.12,
          diameter: 34 + random.nextDouble() * 40,
          delay: random.nextDouble() * 0.45,
          spin: random.nextDouble() * 2 - 1,
          number: 1 + random.nextInt(90),
          amber: random.nextInt(3) > 0,
        ),
    ];

    _run.forward();
    _run.addStatusListener((status) {
      // Clears itself away rather than waiting to be dismissed, so nobody is
      // left staring at a screen they cannot get out of.
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).maybePop();
      }
    });
  }

  static const _count = 44;

  @override
  void dispose() {
    _run.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    // This is a bare route with no Scaffold over it, so nothing would hand
    // the text a style. Taking one from the theme explicitly keeps the font
    // the same as the rest of the app.
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: LayoutBuilder(
          builder: (context, constraints) => AnimatedBuilder(
            animation: _run,
            builder: (context, _) {
              final t = _run.value;
              return Stack(
                children: [
                  for (final ball in _balls) _positioned(ball, t, constraints),
                  Center(
                    child: _Shout(t: t, palette: palette),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _positioned(_Ball ball, double t, BoxConstraints box) {
    // Each ball starts a little after the last, so they arrive as a shower
    // rather than a single row.
    final local = ((t - ball.delay) / (1 - ball.delay)).clamp(0.0, 1.0);
    if (local == 0) return const SizedBox.shrink();

    final fallen = Curves.easeIn.transform(local);
    return Positioned(
      left:
          (ball.across + ball.drift * fallen) * box.maxWidth -
          ball.diameter / 2,
      top: (-0.18 + 1.36 * fallen) * box.maxHeight,
      child: Transform.rotate(
        angle: ball.spin * fallen * 3.2,
        child: _BallView(ball: ball, palette: context.palette),
      ),
    );
  }
}

class _Ball {
  const _Ball({
    required this.across,
    required this.drift,
    required this.diameter,
    required this.delay,
    required this.spin,
    required this.number,
    required this.amber,
  });

  /// Where it starts, as a fraction of the width.
  final double across;
  final double drift;
  final double diameter;

  /// Fraction of the run before this one is let go.
  final double delay;
  final double spin;
  final int number;

  /// Most are amber, some are slate, so the shower has some texture.
  final bool amber;
}

/// One ball, drawn like the ones on the app icon.
class _BallView extends StatelessWidget {
  const _BallView({required this.ball, required this.palette});

  final _Ball ball;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final face = ball.amber ? palette.accent : palette.surfaceHigh;
    final ink = ball.amber ? palette.accentInk : palette.text;

    return SizedBox.square(
      dimension: ball.diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: face,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: ball.diameter * 0.16,
              offset: Offset(0, ball.diameter * 0.06),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '${ball.number}',
              style: TextStyle(
                color: ink,
                fontSize: ball.diameter * 0.42,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
            // The same glassy dome as the icon, so a loose ball still looks
            // like it came off the board.
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.4, -0.5),
                  radius: 0.95,
                  colors: [
                    Colors.white.withValues(alpha: 0.42),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.white.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.4, 0.75],
                ),
              ),
              child: const SizedBox.expand(),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wordmark. Pops in, holds, fades out with the last of the balls.
class _Shout extends StatelessWidget {
  const _Shout({required this.t, required this.palette});

  final double t;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    final entering = (t / 0.22).clamp(0.0, 1.0);
    final leaving = ((t - 0.82) / 0.18).clamp(0.0, 1.0);
    final scale = 0.55 + Curves.easeOutBack.transform(entering) * 0.45;

    return Opacity(
      opacity: entering * (1 - leaving),
      child: Transform.scale(
        scale: scale,
        child: Transform.rotate(
          angle: -0.06,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Space.xl,
              vertical: Space.lg,
            ),
            decoration: BoxDecoration(
              color: palette.accent,
              borderRadius: BorderRadius.circular(Radii.button),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 40,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'FULL HOUSE!',
                  style: TextStyle(
                    color: palette.accentInk,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    height: 1,
                  ),
                ),
                const SizedBox(height: Space.xs),
                Text(
                  'you found the seventh tap',
                  style: TextStyle(
                    color: palette.accentInk.withValues(alpha: 0.75),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
