import 'package:flutter/material.dart';

import '../../core/caller_state.dart';
import '../game_controller.dart';
import '../orientation_controller.dart';
import '../theme/tokens.dart';
import '../widgets/current_number.dart';
import '../widgets/draw_button.dart';
import '../widgets/history_strip.dart';
import '../widgets/number_board.dart';
import '../widgets/progress_header.dart';

/// The caller's screen. Everything needed to run a game, nothing else.
///
/// There is no app bar. The counts row doubles as one, and the board gets the
/// height back.
///
/// Nothing scrolls in either orientation. The board is handed a bounded box
/// and sizes its own cells to fill it, so the whole range is always in view
/// on any screen. Upright, the number sits above the board with the controls
/// in a tray beneath. Sideways, the board and its history take the left and
/// the number and controls take the right.
class GameScreen extends StatelessWidget {
  const GameScreen({super.key, required this.game, required this.orientation});

  final GameController game;
  final OrientationController orientation;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([game, orientation]),
      builder: (context, _) {
        final state = game.state;
        final palette = context.palette;
        final wide = MediaQuery.orientationOf(context) == Orientation.landscape;

        return Scaffold(
          backgroundColor: palette.background,
          body: SafeArea(
            child: wide ? _wide(context, state) : _tall(context, state),
          ),
        );
      },
    );
  }

  Widget _tall(BuildContext context, CallerState state) {
    return Column(
      children: [
        _header(context, state, wide: false),
        // The number takes a share of the space rather than a fixed height,
        // so a short phone gives more of it to the board instead of pushing
        // the board off the bottom.
        Expanded(
          flex: 4,
          child: Center(child: CurrentNumber(state: state)),
        ),
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
            child: _board(state, wide: false),
          ),
        ),
        _tray(
          context,
          child: Column(children: [_history(state), _controls(context, state)]),
        ),
      ],
    );
  }

  Widget _wide(BuildContext context, CallerState state) {
    final palette = context.palette;
    return Row(
      children: [
        // The reference half. Given the larger share, because 90 cells need
        // the room far more than one number and two buttons do.
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _header(context, state, wide: true),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    Space.lg,
                    0,
                    Space.lg,
                    Space.md,
                  ),
                  child: _board(state, wide: true),
                ),
              ),
              _tray(context, child: _history(state)),
            ],
          ),
        ),
        VerticalDivider(width: 1, thickness: 1, color: palette.border),
        // The half the caller touches.
        Expanded(
          flex: 4,
          child: Column(
            children: [
              Expanded(
                child: Center(child: CurrentNumber(state: state)),
              ),
              _controls(context, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _header(
    BuildContext context,
    CallerState state, {
    required bool wide,
  }) => Padding(
    // Tighter at the edges than the board, because an icon button carries
    // its own padding inside its tap target.
    padding: const EdgeInsets.fromLTRB(Space.sm, Space.sm, Space.sm, Space.md),
    child: ProgressHeader(
      state: state,
      lock: orientation.lock,
      onRotate: () => orientation.toggle(showingWide: wide),
      onReset: state.isFresh ? null : () => _confirmReset(context),
    ),
  );

  Widget _board(CallerState state, {required bool wide}) => NumberBoard(
    state: state,
    layout: state.mode.layout(wide: wide),
  );

  /// Lifts whatever sits under the board off the background, so the history
  /// chips do not read as one more row of the board.
  Widget _tray(BuildContext context, {required Widget child}) {
    final palette = context.palette;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(top: BorderSide(color: palette.border)),
      ),
      child: child,
    );
  }

  Widget _history(CallerState state) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Space.sm),
    child: HistoryStrip(state: state),
  );

  Widget _controls(BuildContext context, CallerState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.sm,
        Space.lg,
        Space.md,
      ),
      child: Row(
        children: [
          GhostButton(
            icon: Icons.undo_rounded,
            tooltip: 'Undo last call',
            // Greyed out only when there is genuinely nothing to undo. The
            // controller ignores a tap that lands while a number is landing.
            onPressed: state.isFresh ? null : () => _confirmUndo(context),
          ),
          const SizedBox(width: Space.md),
          Expanded(
            child: state.isComplete
                ? DrawButton(
                    onPressed: () => _confirmReset(context),
                    enabled: true,
                    label: 'NEW GAME',
                    sublabel: 'All ${state.mode.maxNumber} called',
                  )
                : DrawButton(
                    // Deliberately not game.canDraw. That goes false for a
                    // fraction of a second after every draw, and a button that
                    // greys out on each tap looks broken. The controller drops
                    // the tap instead.
                    onPressed: game.draw,
                    enabled: true,
                    label: 'DRAW',
                    sublabel: '${state.remainingCount} left in the bag',
                  ),
          ),
        ],
      ),
    );
  }

  /// Undo is asked about for the same reason reset is: in a hall, with people
  /// waiting, a mis-tap that silently un-calls a number is worse than one
  /// extra tap. The number is named so you can see what you are about to lose
  /// before you agree to it.
  Future<void> _confirmUndo(BuildContext context) async {
    final state = game.state;
    final number = state.current;
    if (number == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Undo the last call?'),
        content: Text(
          '${state.mode.display(number)} goes back in the bag and can come up '
          'again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Undo'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await game.undo();
  }

  Future<void> _confirmReset(BuildContext context) async {
    final state = game.state;
    // A finished game has nothing left to lose, so it starts over directly.
    if (state.isComplete) {
      await game.reset();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start a new game?'),
        content: Text(
          'This clears all ${state.calledCount} numbers called so far. '
          'It cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep playing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('New game'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) await game.reset();
  }
}
