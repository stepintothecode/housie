import 'package:flutter/material.dart';

import '../../core/caller_state.dart';
import '../../core/settings.dart';
import '../theme/tokens.dart';

/// How far through the game we are: counts either side of a thin bar.
///
/// This doubles as the app's title bar. There is no AppBar above it: a strip
/// repeating the app's own name tells a player nothing they did not know from
/// the icon they just tapped, and it costs a row of board.
class ProgressHeader extends StatelessWidget {
  const ProgressHeader({
    super.key,
    required this.state,
    required this.lock,
    this.onReset,
    this.onRotate,
  });

  final CallerState state;

  /// Drives the rotate button's icon and whether it reads as switched on.
  final OrientationLock lock;

  /// Null on a fresh board, where there is nothing to start over.
  final VoidCallback? onReset;

  final VoidCallback? onRotate;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final total = state.mode.maxNumber;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            // Rotate lives at the far left and reset at the far right, at
            // opposite ends of the screen. They are the only two icons here
            // and neither can be undone by tapping the other, so they are
            // kept as far apart as the row allows.
            IconButton(
              onPressed: onRotate,
              // One icon, one colour, whichever way up the app is. It is a
              // button that turns the screen, and it does not become a
              // different control once it has been used. Only the tooltip
              // changes, which costs nothing visually.
              //
              // A phone outline, not another circular arrow: nothing about
              // this shape can be mistaken for the reset icon opposite.
              icon: const Icon(Icons.screen_rotation_outlined),
              tooltip: lock.isLocked
                  ? 'Unlock rotation'
                  : 'Turn the screen sideways',
              visualDensity: VisualDensity.compact,
              color: palette.muted,
            ),
            const SizedBox(width: Space.xs),
            _Stat(label: 'Called', value: '${state.calledCount}', strong: true),
            // Expanded rather than a pair of Spacers. Two icon buttons and
            // three labels do not fit a narrow phone at a fixed size, and the
            // mode name is the one thing here that can afford to give way.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    state.mode.title,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(color: palette.muted),
                  ),
                ),
              ),
            ),
            _Stat(label: 'Left', value: '${state.remainingCount}'),
            const SizedBox(width: Space.xs),
            // Kept up here, as far as possible from the draw button, so a
            // thumb cannot find it by accident in the middle of a game.
            IconButton(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded),
              tooltip: 'New game',
              visualDensity: VisualDensity.compact,
              color: palette.muted,
            ),
          ],
        ),
        const SizedBox(height: Space.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: state.calledCount / total),
            duration: Motion.draw,
            curve: Curves.easeOut,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 4,
              backgroundColor: palette.surfaceHigh,
              valueColor: AlwaysStoppedAnimation(palette.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.strong = false});

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            color: strong ? palette.accent : palette.text,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: Space.xs),
        Text(label, style: TextStyle(color: palette.muted, fontSize: 13)),
      ],
    );
  }
}
