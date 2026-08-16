import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/number_words.dart';
import 'package:housie_bingo_caller/core/settings.dart';

void main() {
  test('a first run opens on housie, system theme and English voice', () {
    const settings = Settings();
    expect(settings.mode, GameMode.housie90);
    expect(settings.theme, ThemeChoice.system);
    expect(settings.speakNumbers, isTrue);
    expect(settings.language, VoiceLanguage.english);
    expect(settings.haptics, isTrue);
    expect(settings.keepAwake, isTrue);
  });

  test('copyWith changes one field and leaves the rest', () {
    const settings = Settings();
    final next = settings.copyWith(mode: GameMode.bingo75);
    expect(next.mode, GameMode.bingo75);
    expect(next.theme, settings.theme);
    expect(next.language, settings.language);
  });

  group('speech rate', () {
    test('is held inside the usable range', () {
      expect(
        const Settings().copyWith(speechRate: 5).speechRate,
        Settings.maxSpeechRate,
      );
      expect(
        const Settings().copyWith(speechRate: -1).speechRate,
        Settings.minSpeechRate,
      );
    });

    test('a value in range is kept as given', () {
      expect(const Settings().copyWith(speechRate: 0.6).speechRate, 0.6);
    });
  });

  group('saving and restoring', () {
    test('every field survives a round trip', () {
      final settings = const Settings().copyWith(
        mode: GameMode.bingo75,
        theme: ThemeChoice.dark,
        speakNumbers: false,
        language: VoiceLanguage.hindi,
        speechRate: 0.7,
        haptics: false,
        keepAwake: false,
      );
      final restored = Settings.fromJson(settings.toJson());

      expect(restored.mode, GameMode.bingo75);
      expect(restored.theme, ThemeChoice.dark);
      expect(restored.speakNumbers, isFalse);
      expect(restored.language, VoiceLanguage.hindi);
      expect(restored.speechRate, 0.7);
      expect(restored.haptics, isFalse);
      expect(restored.keepAwake, isFalse);
    });

    test('nothing saved gives the defaults', () {
      expect(Settings.fromJson(null).mode, GameMode.housie90);
    });

    test('one bad field falls back on its own without losing the others', () {
      // Unlike a game in progress, half-readable settings are worth keeping.
      final restored = Settings.fromJson({
        'mode': 'bingo75',
        'theme': 'neon',
        'speakNumbers': 'yes',
        'language': 'fr',
        'speechRate': 99,
      });

      expect(
        restored.mode,
        GameMode.bingo75,
        reason: 'the readable field was dropped',
      );
      expect(restored.theme, ThemeChoice.system);
      expect(restored.speakNumbers, isTrue);
      expect(restored.language, VoiceLanguage.english);
      expect(restored.speechRate, Settings.maxSpeechRate);
    });
  });

  group('stored ids', () {
    test('round trip', () {
      for (final choice in ThemeChoice.values) {
        expect(ThemeChoice.fromId(choice.id), choice);
      }
    });

    test('an unknown id returns null', () {
      expect(ThemeChoice.fromId('sepia'), isNull);
    });
  });
}
