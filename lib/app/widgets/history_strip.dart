import 'package:flutter/material.dart';

import '../../core/caller_state.dart';
import '../theme/tokens.dart';

/// The last few calls in order, newest on the left.
///
/// The board shows *whether* a number came up. This shows *when*, which is
/// what settles an argument about the number before last.
class HistoryStrip extends StatelessWidget {
  const HistoryStrip({super.key, required this.state});

  final CallerState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final recent = state.recent;

    if (recent.isEmpty) {
      return SizedBox(
        height: _height,
        child: Center(
          child: Text(
            'Called numbers appear here',
            style: TextStyle(
              color: palette.muted.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: Space.lg),
        itemCount: recent.length,
        separatorBuilder: (_, _) => const SizedBox(width: Space.sm),
        itemBuilder: (context, index) {
          final number = recent[index];
          // Index 0 is the number showing now; it gets the accent so the strip
          // and the big display never disagree about what was just called.
          final isCurrent = index == 0;
          return _Chip(
            label: state.mode.display(number),
            background: isCurrent ? palette.accent : palette.surfaceHigh,
            foreground: isCurrent ? palette.accentInk : palette.muted,
            emphasised: isCurrent,
          );
        },
      ),
    );
  }

  static const _height = 44.0;
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.emphasised,
  });

  final String label;
  final Color background;
  final Color foreground;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: Motion.cell,
        padding: const EdgeInsets.symmetric(
          horizontal: Space.md,
          vertical: Space.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Radii.pill),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: foreground,
            fontSize: 15,
            fontWeight: emphasised ? FontWeight.w800 : FontWeight.w600,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
