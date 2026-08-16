import 'package:flutter/material.dart';

import '../../core/caller_state.dart';
import '../theme/tokens.dart';

/// The number on the table right now, as large as the screen allows.
///
/// This is the whole point of the app: a caller holds the phone up and a room
/// reads it from across the hall.
class CurrentNumber extends StatelessWidget {
  const CurrentNumber({super.key, required this.state});

  final CallerState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final number = state.current;

    return Semantics(
      liveRegion: true,
      label: number == null
          ? 'No number called yet'
          : 'Called ${state.mode.display(number)}',
      excludeSemantics: true,
      child: AnimatedSwitcher(
        duration: Motion.draw,
        switchInCurve: Curves.easeOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: _swap,
        child: number == null
            ? const _Waiting(key: ValueKey('waiting'))
            : _Number(
                key: ValueKey(number),
                number: number,
                letter: state.mode.letterFor(number),
                palette: palette,
              ),
      ),
    );
  }

  /// The new number scales up as the old one falls away, rather than the two
  /// cross-fading on top of each other.
  static Widget _swap(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: ScaleTransition(
        scale: Tween(begin: 0.72, end: 1.0).animate(animation),
        child: child,
      ),
    );
  }
}

class _Number extends StatelessWidget {
  const _Number({
    super.key,
    required this.number,
    required this.letter,
    required this.palette,
  });

  final int number;
  final String? letter;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    // The letter and the number scale together, as one block.
    //
    // A Column hands its non-flexible children unbounded height, so a
    // FittedBox around the number alone never saw a ceiling and the pair
    // could stand taller than the space they were given. Fitting the whole
    // column is what keeps it inside on a short screen.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (letter != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.xs,
              ),
              decoration: BoxDecoration(
                color: palette.calledFill,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: Text(
                letter!,
                style: TextStyle(
                  color: palette.calledInk,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: Space.sm),
          ],
          // No glow behind this. A box shadow follows the box, not the digits,
          // so it renders as a rectangular haze rather than a halo. Amber on
          // near-black already carries across a room.
          Text(
            '$number',
            style: Theme.of(context).textTheme.displayLarge
                ?.copyWith(color: palette.accent),
          ),
        ],
      ),
    );
  }
}

class _Waiting extends StatelessWidget {
  const _Waiting({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    // Fitted for the same reason as the number it stands in for: this column
    // is taller than the slot on a short sideways screen.
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.casino_outlined, size: 56, color: palette.border),
          const SizedBox(height: Space.md),
          Text(
            'Ready when you are',
            style: TextStyle(
              color: palette.muted,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: Space.xs),
          Text(
            'Tap Draw to call the first number',
            style: TextStyle(
              color: palette.muted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
