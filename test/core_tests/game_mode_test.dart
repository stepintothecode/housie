import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';

void main() {
  test('the two modes describe themselves', () {
    expect(GameMode.housie90.maxNumber, 90);
    expect(GameMode.housie90.title, 'Housie 1-90');
    expect(GameMode.bingo75.maxNumber, 75);
    expect(GameMode.bingo75.title, 'Bingo 1-75');
  });

  group('board layout', () {
    test('housie reads left to right in tens, whichever way up', () {
      for (final wide in [false, true]) {
        final board = GameMode.housie90.layout(wide: wide);
        expect(board.columns, 10);
        expect(board.rows, 9);
        expect(board.numberAt(0), 1);
        expect(board.numberAt(9), 10);
        expect(board.numberAt(10), 11);
        expect(board.numberAt(89), 90);
        expect(board.columnLabels, isEmpty);
        expect(board.rowLabels, isEmpty);
      }
    });

    test('upright bingo reads down five lettered columns', () {
      final board = GameMode.bingo75.layout(wide: false);
      expect(board.columns, 5);
      expect(board.rows, 15);
      expect(board.columnLabels, ['B', 'I', 'N', 'G', 'O']);
      expect(board.rowLabels, isEmpty);
      // Row one is the top of each column: 1, 16, 31, 46, 61.
      expect(board.numberAt(0), 1);
      expect(board.numberAt(1), 16);
      expect(board.numberAt(4), 61);
      expect(board.numberAt(5), 2);
      expect(board.numberAt(74), 75);
    });

    test('sideways bingo turns onto its side, five lettered rows', () {
      // A sideways screen is wide and short. Fifteen rows would be squeezed
      // to nothing, so the same board is transposed.
      final board = GameMode.bingo75.layout(wide: true);
      expect(board.columns, 15);
      expect(board.rows, 5);
      expect(board.rowLabels, ['B', 'I', 'N', 'G', 'O']);
      expect(board.columnLabels, isEmpty);
      expect(board.numberAt(0), 1, reason: 'the B row should start at 1');
      expect(board.numberAt(14), 15, reason: 'the B row should end at 15');
      expect(board.numberAt(15), 16, reason: 'the I row should start at 16');
      expect(board.numberAt(74), 75);
    });

    test('every layout covers its range exactly once', () {
      for (final mode in GameMode.values) {
        for (final wide in [false, true]) {
          final board = mode.layout(wide: wide);
          expect(
            board.rows * board.columns,
            mode.maxNumber,
            reason: '${mode.id} wide=$wide leaves cells over',
          );
          final numbers = [
            for (var i = 0; i < board.cellCount; i++) board.numberAt(i)!,
          ];
          expect(numbers.toSet(), {
            for (var n = 1; n <= mode.maxNumber; n++) n,
          }, reason: '${mode.id} wide=$wide does not cover its range once');
        }
      }
    });

    test('a cell off the board is null, not a wrapped number', () {
      final housie = GameMode.housie90.layout(wide: false);
      expect(housie.numberAt(-1), isNull);
      expect(housie.numberAt(90), isNull);
      expect(GameMode.bingo75.layout(wide: true).numberAt(75), isNull);
    });
  });

  group('bingo letters', () {
    test('each block of fifteen gets its letter', () {
      expect(GameMode.bingo75.letterFor(1), 'B');
      expect(GameMode.bingo75.letterFor(15), 'B');
      expect(GameMode.bingo75.letterFor(16), 'I');
      expect(GameMode.bingo75.letterFor(45), 'N');
      expect(GameMode.bingo75.letterFor(60), 'G');
      expect(GameMode.bingo75.letterFor(75), 'O');
    });

    test('housie has no letters, in either layout', () {
      expect(GameMode.housie90.letterFor(47), isNull);
      for (final wide in [false, true]) {
        final board = GameMode.housie90.layout(wide: wide);
        expect(board.columnLabels, isEmpty);
        expect(board.rowLabels, isEmpty);
      }
    });

    test('a number off the board has no letter', () {
      expect(GameMode.bingo75.letterFor(0), isNull);
      expect(GameMode.bingo75.letterFor(76), isNull);
    });

    test('display shows the letter only where there is one', () {
      expect(GameMode.housie90.display(47), '47');
      expect(GameMode.bingo75.display(47), 'G 47');
    });
  });

  group('stored ids', () {
    test('round trip', () {
      for (final mode in GameMode.values) {
        expect(GameMode.fromId(mode.id), mode);
      }
    });

    test('an unknown id returns null so the caller picks the fallback', () {
      expect(GameMode.fromId(null), isNull);
      expect(GameMode.fromId(''), isNull);
      expect(GameMode.fromId('housie'), isNull);
    });

    test('the ids written to storage never change', () {
      // Changing either of these silently discards every saved game.
      expect(GameMode.housie90.id, 'housie90');
      expect(GameMode.bingo75.id, 'bingo75');
    });
  });
}
