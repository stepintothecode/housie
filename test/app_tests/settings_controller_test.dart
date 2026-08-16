import 'package:flutter_test/flutter_test.dart';
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

  SettingsController build({Settings? saved, bool hasVoice = true}) {
    store = FakeStore();
    if (saved != null) {
      store.seedRaw(SettingsController.storageKey, saved.toJson());
    }
    speaker = FakeSpeaker(hasVoice: hasVoice);
    device = FakeDevice();
    return SettingsController(store: store, speaker: speaker, device: device);
  }

  test('opens on the defaults when nothing is saved', () {
    expect(build().value.mode, GameMode.housie90);
  });

  test('picks up what was saved last time', () {
    final settings = build(
      saved: const Settings().copyWith(theme: ThemeChoice.dark),
    );
    expect(settings.value.theme, ThemeChoice.dark);
  });

  group('changing a setting', () {
    test('writes it straight to storage', () {
      final settings = build();
      settings.setMode(GameMode.bingo75);

      expect(store.read(SettingsController.storageKey)!['mode'], 'bingo75');
    });

    test('tells listeners', () {
      final settings = build();
      var notified = 0;
      settings.addListener(() => notified++);

      settings.setTheme(ThemeChoice.light);

      expect(notified, 1);
    });

    test('holds the speech rate inside its range', () {
      final settings = build();
      settings.setSpeechRate(10);
      expect(settings.value.speechRate, Settings.maxSpeechRate);
    });
  });

  group('haptics', () {
    test('buzzes once on the way on, so you can tell it works', () async {
      final settings = build();
      settings.setHaptics(false);
      expect(device.taps, 0);

      settings.setHaptics(true);
      await Future<void>.delayed(Duration.zero);

      expect(device.taps, 1);
    });

    test('stays silent on the way off', () async {
      final settings = build();
      settings.setHaptics(false);
      await Future<void>.delayed(Duration.zero);

      expect(device.taps, 0);
    });
  });

  group('voice', () {
    test('turning it off stops anything mid-sentence', () {
      final settings = build();
      settings.setSpeakNumbers(false);
      expect(speaker.stops, 1);
    });

    test(
      'the preview says a two digit number in the chosen language',
      () async {
        final settings = build();
        settings.setLanguage(VoiceLanguage.hindi);

        await settings.previewVoice();

        // Never a number a game could draw, so the room cannot mishear the
        // test for a real call.
        final expected = numberWords(voiceTestNumber, VoiceLanguage.hindi);
        expect(speaker.spoken.single, expected);
        expect(settings.voiceSample, expected);
      },
    );

    test('a phone with no voice for the language is flagged', () async {
      final settings = build(hasVoice: false);
      expect(
        settings.voiceAvailable,
        isNull,
        reason: 'claimed to know before asking',
      );

      await settings.refreshVoiceAvailability();

      expect(settings.voiceAvailable, isFalse);
    });

    test('a phone that has the voice is not flagged', () async {
      final settings = build();
      await settings.refreshVoiceAvailability();
      expect(settings.voiceAvailable, isTrue);
    });
  });
}
