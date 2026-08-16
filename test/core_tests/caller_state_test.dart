import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/caller_state.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';

void main() {
  group('drawing', () {
    test('a fresh game has called nothing', () {
      final state = CallerState(mode: GameMode.housie90);
      expect(state.current, isNull);
      expect(state.calledCount, 0);
      expect(state.remainingCount, 90);
      expect(state.isFresh, isTrue);
      expect(state.isComplete, isFalse);
    });

    test('a draw puts a number in range on the table', () {
      final drawn = CallerState(mode: GameMode.housie90).draw(Random(1))!;
      expect(drawn.current, inInclusiveRange(1, 90));
      expect(drawn.calledCount, 1);
      expect(drawn.remainingCount, 89);
      expect(drawn.wasCalled(drawn.current!), isTrue);
    });

    test('draining the bag yields every number exactly once', () {
      for (final mode in GameMode.values) {
        var state = CallerState(mode: mode);
        for (var i = 0; i < mode.maxNumber; i++) {
          state = state.draw(Random(i))!;
        }
        expect(state.isComplete, isTrue);
        expect(
          state.drawn.toSet().length,
          mode.maxNumber,
          reason: '${mode.id} repeated a number',
        );
        expect(state.drawn.toSet(), {
          for (var n = 1; n <= mode.maxNumber; n++) n,
        });
      }
    });

    test(
      'drawing from an empty bag returns null rather than a no-op state',
      () {
        var state = CallerState(mode: GameMode.bingo75);
        for (var i = 0; i < 75; i++) {
          state = state.draw(Random(i))!;
        }
        expect(state.draw(Random(0)), isNull);
      },
    );

    test('the same seed gives the same game', () {
      List<int> play() {
        var state = CallerState(mode: GameMode.housie90);
        final random = Random(42);
        for (var i = 0; i < 10; i++) {
          state = state.draw(random)!;
        }
        return state.drawn;
      }

      expect(play(), play());
    });

    test('the original state is untouched by a draw', () {
      final first = CallerState(mode: GameMode.housie90);
      first.draw(Random(3));
      expect(first.calledCount, 0);
    });
  });

  group('undo and reset', () {
    test('undo takes back only the last call', () {
      final state = CallerState(mode: GameMode.housie90, drawn: [7, 21, 63]);
      final back = state.undo()!;
      expect(back.drawn, [7, 21]);
      expect(back.current, 21);
      expect(back.wasCalled(63), isFalse);
    });

    test('undo on a fresh game returns null', () {
      expect(CallerState(mode: GameMode.housie90).undo(), isNull);
    });

    test('reset clears the board but keeps the mode', () {
      final state = CallerState(mode: GameMode.bingo75, drawn: [4, 5]).reset();
      expect(state.isFresh, isTrue);
      expect(state.mode, GameMode.bingo75);
    });

    test('switching mode always starts a fresh game', () {
      final state = CallerState(mode: GameMode.housie90, drawn: [88]);
      final switched = state.withMode(GameMode.bingo75);
      expect(switched.mode, GameMode.bingo75);
      expect(switched.isFresh, isTrue);
    });

    test('switching to the mode already set changes nothing', () {
      final state = CallerState(mode: GameMode.housie90, drawn: [88]);
      expect(state.withMode(GameMode.housie90).drawn, [88]);
    });
  });

  test('recent lists the newest call first', () {
    final state = CallerState(mode: GameMode.housie90, drawn: [1, 2, 3]);
    expect(state.recent, [3, 2, 1]);
  });

  group('saving and restoring', () {
    test('a game survives a round trip', () {
      final state = CallerState(mode: GameMode.bingo75, drawn: [1, 40, 75]);
      final restored = CallerState.fromJson(state.toJson())!;
      expect(restored.mode, GameMode.bingo75);
      expect(restored.drawn, [1, 40, 75]);
    });

    test('unreadable data returns null instead of a guess', () {
      // Each of these used to be a plausible way to end up with a board that
      // could not be drawn, so they are rejected outright.
      expect(CallerState.fromJson(null), isNull);
      expect(CallerState.fromJson({}), isNull);
      expect(
        CallerState.fromJson({'mode': 'housie100', 'drawn': <int>[]}),
        isNull,
      );
      expect(
        CallerState.fromJson({'mode': 'housie90', 'drawn': 'nope'}),
        isNull,
      );
      expect(
        CallerState.fromJson({
          'mode': 'housie90',
          'drawn': [0],
        }),
        isNull,
      );
      expect(
        CallerState.fromJson({
          'mode': 'housie90',
          'drawn': [91],
        }),
        isNull,
      );
      expect(
        CallerState.fromJson({
          'mode': 'bingo75',
          'drawn': [76],
        }),
        isNull,
      );
      expect(
        CallerState.fromJson({
          'mode': 'housie90',
          'drawn': [5, 5],
        }),
        isNull,
      );
      expect(
        CallerState.fromJson({
          'mode': 'housie90',
          'drawn': ['x'],
        }),
        isNull,
      );
    });

    test('an empty saved game restores as empty', () {
      final restored = CallerState.fromJson({
        'mode': 'housie90',
        'drawn': <int>[],
      })!;
      expect(restored.isFresh, isTrue);
    });
  });
}
