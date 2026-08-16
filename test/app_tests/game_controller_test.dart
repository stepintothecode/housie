import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/game_controller.dart';
import 'package:housie_bingo_caller/app/settings_controller.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/number_words.dart';
import 'package:housie_bingo_caller/core/settings.dart';

import '../support/fake_device.dart';
import '../support/fake_speaker.dart';
import '../support/fake_store.dart';

void main() {
  late FakeStore store;
  late FakeSpeaker speaker;
  late FakeDevice device;
  late SettingsController settings;

  GameController build({
    Map<String, Object?>? savedGame,
    Settings? initial,
    Duration drawLock = Duration.zero,
  }) {
    store = FakeStore();
    if (savedGame != null) {
      store.seedRaw(GameController.storageKey, savedGame);
    }
    if (initial != null) {
      store.seedRaw(SettingsController.storageKey, initial.toJson());
    }

    speaker = FakeSpeaker();
    device = FakeDevice();
    settings = SettingsController(
      store: store,
      speaker: speaker,
      device: device,
    );

    return GameController(
      store: store,
      speaker: speaker,
      device: device,
      settings: settings,
      random: Random(7),
      drawLock: drawLock,
    );
  }

  group('drawing', () {
    test('puts a number on the table and counts it', () async {
      final game = build();
      await game.draw();

      expect(game.state.calledCount, 1);
      expect(game.state.current, inInclusiveRange(1, 90));
    });

    test('says the number out loud in the chosen language', () async {
      final game = build();
      await game.draw();

      expect(speaker.spoken, hasLength(1));
      expect(
        speaker.spoken.single,
        numberWords(game.state.current!, VoiceLanguage.english),
      );
      expect(speaker.languages.single, VoiceLanguage.english);
    });

    test('speaks Hindi when that is the setting', () async {
      final game = build();
      settings.setLanguage(VoiceLanguage.hindi);
      await game.draw();

      expect(
        speaker.spoken.single,
        numberWords(game.state.current!, VoiceLanguage.hindi),
      );
    });

    test('stays silent when the voice is turned off', () async {
      final game = build(
        initial: const Settings().copyWith(speakNumbers: false),
      );
      await game.draw();

      expect(speaker.spoken, isEmpty);
    });

    test(
      'taps the handset, and thuds on the last number of the game',
      () async {
        final game = build(
          initial: const Settings().copyWith(mode: GameMode.bingo75),
        );
        for (var i = 0; i < 75; i++) {
          await game.draw();
        }

        expect(game.state.isComplete, isTrue);
        expect(device.taps, 74);
        expect(device.thuds, 1);
      },
    );

    test('does not vibrate when haptics are off', () async {
      final game = build(initial: const Settings().copyWith(haptics: false));
      await game.draw();

      expect(device.taps, 0);
    });

    test('a second tap while the number is landing is ignored', () async {
      final game = build(drawLock: const Duration(milliseconds: 40));

      final first = game.draw();
      await game.draw(); // arrives while the first is still locked
      await first;

      expect(game.state.calledCount, 1, reason: 'a fast tapper drew twice');
    });

    test('the lock lets go, so the next tap works', () async {
      final game = build(drawLock: const Duration(milliseconds: 20));

      await game.draw();
      await game.draw();

      expect(game.state.calledCount, 2);
      expect(game.canDraw, isTrue);
    });

    test('does nothing once every number is called', () async {
      final game = build(
        initial: const Settings().copyWith(mode: GameMode.bingo75),
      );
      for (var i = 0; i < 75; i++) {
        await game.draw();
      }
      final before = store.writes;

      await game.draw();

      expect(game.state.calledCount, 75);
      expect(
        store.writes,
        before,
        reason: 'a refused draw still wrote to storage',
      );
      expect(game.canDraw, isFalse);
    });
  });

  group('undo', () {
    test('takes the last number back and stops the voice', () async {
      final game = build();
      await game.draw();
      await game.draw();
      final second = game.state.current;

      await game.undo();

      expect(game.state.calledCount, 1);
      expect(game.state.wasCalled(second!), isFalse);
      expect(speaker.stops, greaterThan(0));
    });

    test('does nothing on a fresh game', () async {
      final game = build();
      expect(game.canUndo, isFalse);
      await game.undo();
      expect(game.state.isFresh, isTrue);
    });

    test('an undone number can come up again', () async {
      final game = build();
      await game.draw();
      final first = game.state.current!;
      await game.undo();

      final seen = <int>{};
      while (!game.state.isComplete) {
        await game.draw();
        seen.add(game.state.current!);
      }

      expect(seen, contains(first));
    });
  });

  test('reset clears the board and keeps the mode', () async {
    final game = build(
      initial: const Settings().copyWith(mode: GameMode.bingo75),
    );
    await game.draw();
    await game.reset();

    expect(game.state.isFresh, isTrue);
    expect(game.state.mode, GameMode.bingo75);
  });

  group('saving between launches', () {
    test('a game in progress is written on every change', () async {
      final game = build();
      await game.draw();

      final saved = store.read(GameController.storageKey)!;
      expect(saved['mode'], 'housie90');
      expect(saved['drawn'], [game.state.current]);
    });

    test('a saved game is picked back up on launch', () {
      final game = build(
        savedGame: {
          'mode': 'housie90',
          'drawn': [12, 45],
        },
      );

      expect(game.state.drawn, [12, 45]);
      expect(game.state.current, 45);
    });

    test('a saved game from the other mode is dropped rather than forced', () {
      // Settings say bingo, storage holds a housie game. Restoring it would
      // put numbers above 75 on a 75 board.
      final game = build(
        savedGame: {
          'mode': 'housie90',
          'drawn': [88],
        },
        initial: const Settings().copyWith(mode: GameMode.bingo75),
      );

      expect(game.state.mode, GameMode.bingo75);
      expect(game.state.isFresh, isTrue);
    });

    test('unreadable saved data opens a fresh game instead of failing', () {
      final game = build(
        savedGame: {
          'mode': 'housie90',
          'drawn': [5, 5],
        },
      );
      expect(game.state.isFresh, isTrue);
    });
  });

  group('switching mode', () {
    test('follows the setting and clears the board', () async {
      final game = build();
      await game.draw();

      settings.setMode(GameMode.bingo75);

      expect(game.state.mode, GameMode.bingo75);
      expect(game.state.isFresh, isTrue);
    });
  });

  group('keeping the screen on', () {
    test('holds the screen only while a game is actually running', () async {
      final game = build();
      expect(
        device.awake,
        isFalse,
        reason: 'held the screen on an empty board',
      );

      await game.draw();
      expect(device.awake, isTrue);

      await game.reset();
      expect(device.awake, isFalse);
    });

    test('lets go once the last number is called', () async {
      final game = build(
        initial: const Settings().copyWith(mode: GameMode.bingo75),
      );
      for (var i = 0; i < 75; i++) {
        await game.draw();
      }

      expect(device.awake, isFalse);
    });

    test('never asks for the same state twice in a row', () async {
      final game = build();
      for (var i = 0; i < 5; i++) {
        await game.draw();
      }

      for (var i = 1; i < device.wakeCalls.length; i++) {
        expect(
          device.wakeCalls[i],
          isNot(device.wakeCalls[i - 1]),
          reason: 'repeated the same wakelock request',
        );
      }
    });

    test('respects the setting being turned off mid-game', () async {
      final game = build();
      await game.draw();
      expect(device.awake, isTrue);

      settings.setKeepAwake(false);

      expect(device.awake, isFalse);
    });
  });
}
