import 'package:flutter/material.dart';

import '../../core/caller_state.dart';
import '../../core/game_mode.dart';
import '../theme/tokens.dart';

/// Every number in the range, dim until it is called.
///
/// Sizes itself to whatever box it is given: the whole board is always on one
/// screen, because a caller should never scroll to answer "has 47 gone?".
/// That means the parent has to give it a bounded height, which every layout
/// in this app does.
class NumberBoard extends StatelessWidget {
  const NumberBoard({super.key, required this.state, required this.layout});

  final CallerState state;
  final BoardLayout layout;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final hasRowLabels = layout.rowLabels.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Cells shrink to fit rather than the board growing past its box.
        // Below about this size two digits stop being readable at arm's
        // length, and there is nothing useful left to do about it.
        final gutter = hasRowLabels ? _labelGutter : 0.0;
        final cellWidth =
            (constraints.maxWidth - gutter - (layout.columns - 1) * Space.xs) /
            layout.columns;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (layout.columnLabels.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.xs),
                child: Row(
                  children: [
                    for (final letter in layout.columnLabels)
                      Expanded(child: _Label(letter, palette: palette)),
                  ],
                ),
              ),
            for (var row = 0; row < layout.rows; row++) ...[
              if (row > 0) const SizedBox(height: Space.xs),
              Expanded(
                child: Row(
                  children: [
                    if (hasRowLabels)
                      SizedBox(
                        width: _labelGutter,
                        child: _Label(layout.rowLabels[row], palette: palette),
                      ),
                    for (var column = 0; column < layout.columns; column++) ...[
                      if (column > 0) const SizedBox(width: Space.xs),
                      Expanded(
                        child: _cell(row * layout.columns + column, cellWidth),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _cell(int index, double width) {
    final number = layout.numberAt(index);
    if (number == null) return const SizedBox.shrink();
    return _Cell(
      number: number,
      called: state.wasCalled(number),
      isCurrent: number == state.current,
      // Narrow cells need smaller type before the fitter starts shrinking it,
      // otherwise a two-digit number is scaled down further than a one-digit
      // one and the rows look uneven.
      compact: width < 40,
    );
  }

  static const _labelGutter = 22.0;
}

class _Label extends StatelessWidget {
  const _Label(this.text, {required this.palette});

  final String text;
  final Palette palette;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: palette.muted),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.number,
    required this.called,
    required this.isCurrent,
    required this.compact,
  });

  final int number;
  final bool called;
  final bool isCurrent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;

    final background = switch ((called, isCurrent)) {
      (_, true) => palette.accent,
      (true, _) => palette.calledFill,
      _ => palette.surfaceHigh,
    };
    final foreground = switch ((called, isCurrent)) {
      (_, true) => palette.accentInk,
      (true, _) => palette.calledInk,
      _ => palette.muted,
    };

    return AnimatedContainer(
      duration: Motion.cell,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(Radii.cell),
        border: isCurrent ? Border.all(color: palette.accent, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            '$number',
            style: TextStyle(
              color: foreground,
              fontSize: compact ? 15 : 18,
              fontWeight: called ? FontWeight.w800 : FontWeight.w500,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}
