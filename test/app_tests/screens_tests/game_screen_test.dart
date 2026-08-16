import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/game_controller.dart';
import 'package:housie_bingo_caller/app/orientation_controller.dart';
import 'package:housie_bingo_caller/app/screens/game_screen.dart';
import 'package:housie_bingo_caller/app/settings_controller.dart';
import 'package:housie_bingo_caller/app/theme/app_theme.dart';
import 'package:housie_bingo_caller/app/widgets/current_number.dart';
import 'package:housie_bingo_caller/app/widgets/history_strip.dart';
import 'package:housie_bingo_caller/app/widgets/number_board.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/settings.dart'
    show OrientationLock, Settings;

import '../../support/fake_device.dart';
import '../../support/fake_speaker.dart';
import '../../support/fake_store.dart';

/// A phone held upright, and the same phone turned sideways. Set explicitly
/// because the default test window is 800x600, which is landscape, and the
/// screen builds a different layout for each.
const _portrait = Size(412, 915);
const _landscape = Size(915, 412);

void main() {
  late GameController game;
  late OrientationController orientation;
  late FakeDevice device;

  Widget wrap(GameMode mode) {
    final store = FakeStore()
      ..seedRaw(SettingsController.storageKey, Settings(mode: mode).toJson());
    final speaker = FakeSpeaker();
    device = FakeDevice();
    final settings = SettingsController(
      store: store,
      speaker: speaker,
      device: device,
    );

    game = GameController(
      store: store,
      speaker: speaker,
      device: device,
      settings: settings,
      random: Random(11),
      drawLock: Duration.zero,
    );
    orientation = OrientationController(device: device);

    return MaterialApp(
      theme: AppTheme.dark(),
      home: GameScreen(game: game, orientation: orientation),
    );
  }

  /// Pumps the screen at [size]. Defaults to a portrait phone.
  Future<void> show(
    WidgetTester tester,
    GameMode mode, {
    Size size = _portrait,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(wrap(mode));
    await tester.pumpAndSettle();
  }

  testWidgets('opens on an empty board with the draw button ready', (
    tester,
  ) async {
    await show(tester, GameMode.housie90);

    expect(find.text('DRAW'), findsOneWidget);
    expect(find.text('90 left in the bag'), findsOneWidget);
    expect(find.text('Ready when you are'), findsOneWidget);
  });

  testWidgets('drawing shows the number and counts down the bag', (
    tester,
  ) async {
    await show(tester, GameMode.housie90);

    await tester.tap(find.text('DRAW'));
    await tester.pumpAndSettle();

    expect(game.state.calledCount, 1);
    expect(find.text('89 left in the bag'), findsOneWidget);
    expect(find.text('Ready when you are'), findsNothing);
  });

  testWidgets('the board fills as numbers are called', (tester) async {
    await show(tester, GameMode.bingo75);

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();
    }

    expect(game.state.calledCount, 3);
    // Every cell is on screen at once for bingo, and each called number also
    // appears in the history strip and the big display.
    for (final number in game.state.drawn) {
      expect(find.text('$number'), findsWidgets);
    }
  });

  testWidgets('undo is dead until something has been called', (tester) async {
    await show(tester, GameMode.housie90);
    expect(game.canUndo, isFalse);

    await tester.tap(find.byIcon(Icons.undo_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Undo the last call?'), findsNothing);
    expect(game.state.isFresh, isTrue);
  });

  group('undoing', () {
    testWidgets('asks first, and names the number at stake', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();
      final called = game.state.current!;

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Undo the last call?'), findsOneWidget);
      expect(
        find.textContaining('$called goes back in the bag'),
        findsOneWidget,
      );
      expect(
        game.state.calledCount,
        1,
        reason: 'undid the call before being told to',
      );
    });

    testWidgets('keeps the number when declined', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Keep it'));
      await tester.pumpAndSettle();

      expect(game.state.calledCount, 1);
    });

    testWidgets('takes it back when confirmed', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.undo_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilledButton, 'Undo'));
      await tester.pumpAndSettle();

      expect(game.state.isFresh, isTrue);
    });
  });

  group('resetting', () {
    testWidgets('asks before throwing a game away', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Start a new game?'), findsOneWidget);

      await tester.tap(find.text('Keep playing'));
      await tester.pumpAndSettle();

      expect(
        game.state.calledCount,
        1,
        reason: 'cleared the board after being told not to',
      );
    });

    testWidgets('clears the board when confirmed', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.restart_alt_rounded));
      await tester.pumpAndSettle();
      await tester.tap(find.text('New game'));
      await tester.pumpAndSettle();

      expect(game.state.isFresh, isTrue);
    });
  });

  group('turned sideways', () {
    testWidgets('still has every control, in one column each', (tester) async {
      await show(tester, GameMode.housie90, size: _landscape);

      expect(find.text('DRAW'), findsOneWidget);
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);
      expect(find.text('Housie 1-90'), findsOneWidget);
      expect(find.byType(NumberBoard), findsOneWidget);
      expect(find.byType(HistoryStrip), findsOneWidget);
    });

    testWidgets('board and history sit left of the number and buttons', (
      tester,
    ) async {
      await show(tester, GameMode.housie90, size: _landscape);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      final board = tester.getCenter(find.byType(NumberBoard));
      final history = tester.getCenter(find.byType(HistoryStrip));
      final number = tester.getCenter(find.byType(CurrentNumber));
      final draw = tester.getCenter(find.text('DRAW'));

      expect(board.dx, lessThan(number.dx), reason: 'board is not on the left');
      expect(
        history.dx,
        lessThan(draw.dx),
        reason: 'history is not on the left',
      );
    });

    testWidgets('drawing works the same way', (tester) async {
      await show(tester, GameMode.housie90, size: _landscape);

      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      expect(game.state.calledCount, 1);
      expect(find.text('89 left in the bag'), findsOneWidget);
    });
  });

  group('the rotate button', () {
    // The two icons in the header. They must never be the same glyph: one
    // starts a new game and the other turns the screen, and they sit at
    // opposite ends of the row precisely so neither is hit by accident.
    const rotate = Icons.screen_rotation_outlined;
    const reset = Icons.restart_alt_rounded;

    testWidgets('is a different icon from reset, at the other end', (
      tester,
    ) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();

      expect(rotate, isNot(reset));
      expect(find.byIcon(rotate), findsOneWidget);
      expect(find.byIcon(reset), findsOneWidget);
      expect(
        tester.getCenter(find.byIcon(rotate)).dx,
        lessThan(tester.getCenter(find.byIcon(reset)).dx),
        reason: 'rotate should sit left of reset, not beside it',
      );
    });

    testWidgets('pins the other way up, then lets go again', (tester) async {
      await show(tester, GameMode.housie90);
      expect(orientation.lock, OrientationLock.auto);

      // Upright, so the first tap should turn it sideways.
      await tester.tap(find.byIcon(rotate));
      await tester.pumpAndSettle();
      expect(orientation.lock, OrientationLock.landscape);
      expect(device.lock, OrientationLock.landscape);

      await tester.tap(find.byIcon(rotate));
      await tester.pumpAndSettle();
      expect(orientation.lock, OrientationLock.auto);
      expect(device.lock, OrientationLock.auto);
    });

    testWidgets('stays the same icon once it has been used', (tester) async {
      await show(tester, GameMode.housie90);

      await tester.tap(find.byIcon(rotate));
      await tester.pumpAndSettle();

      // A button that turns the screen should not turn into a different
      // looking control the moment you press it.
      expect(find.byIcon(rotate), findsOneWidget);
      expect(
        tester.widget<Icon>(find.byIcon(rotate)).color,
        isNull,
        reason: 'the icon should take the button colour, not its own accent',
      );
    });

    testWidgets('pins upright when the screen is already sideways', (
      tester,
    ) async {
      await show(tester, GameMode.housie90, size: _landscape);

      await tester.tap(find.byIcon(rotate));
      await tester.pumpAndSettle();

      expect(orientation.lock, OrientationLock.portrait);
    });

    testWidgets('does not touch the game', (tester) async {
      await show(tester, GameMode.housie90);
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();
      final called = game.state.current;

      await tester.tap(find.byIcon(rotate));
      await tester.pumpAndSettle();

      expect(game.state.current, called);
      expect(game.state.calledCount, 1);
    });
  });

  group('the whole board is on screen', () {
    // A tall phone, a sideways phone, and a small cheap phone. The board sizes
    // its own cells, so every number has to be inside it in all of them.
    const sizes = {
      'upright': _portrait,
      'sideways': _landscape,
      'small': Size(412, 620),
    };

    for (final mode in GameMode.values) {
      for (final entry in sizes.entries) {
        testWidgets('${mode.id}, ${entry.key}', (tester) async {
          await show(tester, mode, size: entry.value);

          expect(
            find.descendant(
              of: find.byType(NumberBoard),
              matching: find.byType(Scrollable),
            ),
            findsNothing,
            reason: 'the board scrolls instead of sizing itself to fit',
          );

          final board = tester.getRect(find.byType(NumberBoard));
          // The first and last numbers are the corners. Scoped to the board,
          // because the header shows the range as well.
          for (final number in [1, mode.maxNumber]) {
            final cell = tester.getRect(
              find.descendant(
                of: find.byType(NumberBoard),
                matching: find.text('$number'),
              ),
            );
            expect(
              board.inflate(0.5).contains(cell.topLeft) &&
                  board.inflate(0.5).contains(cell.bottomRight),
              isTrue,
              reason:
                  '$number falls outside the board on a ${entry.key} screen',
            );
          }
        });
      }
    }
  });

  testWidgets('a finished game offers a new one instead of another draw', (
    tester,
  ) async {
    await show(tester, GameMode.bingo75);

    for (var i = 0; i < 75; i++) {
      await tester.tap(find.text('DRAW'));
      await tester.pumpAndSettle();
    }

    expect(find.text('NEW GAME'), findsOneWidget);
    expect(find.text('All 75 called'), findsOneWidget);
    expect(find.text('DRAW'), findsNothing);
  });

  // The overflow this guards against only appeared on the very last number,
  // when the draw button's label grows, on a screen narrow enough that it
  // wrapped. Every size below is a real shape a phone comes in.
  group('a finished game fits without overflowing', () {
    const sizes = {
      'upright': _portrait,
      'sideways': _landscape,
      'small upright': Size(360, 640),
      'small sideways': Size(640, 360),
    };

    for (final mode in GameMode.values) {
      for (final entry in sizes.entries) {
        testWidgets('${mode.id}, ${entry.key}', (tester) async {
          await show(tester, mode, size: entry.value);
          for (var i = 0; i < mode.maxNumber; i++) {
            await tester.tap(find.text('DRAW'));
            await tester.pumpAndSettle();
          }

          // A RenderFlex overflow throws in tests, so reaching here is most
          // of the assertion. The rest confirms the end state rendered.
          expect(tester.takeException(), isNull);
          expect(find.text('NEW GAME'), findsOneWidget);
        });
      }
    }
  });
}
