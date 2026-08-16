import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/number_words.dart';

void main() {
  group('english', () {
    test('the awkward ones read correctly', () {
      expect(numberWords(1, VoiceLanguage.english), 'one');
      expect(numberWords(11, VoiceLanguage.english), 'eleven');
      expect(numberWords(13, VoiceLanguage.english), 'thirteen');
      expect(numberWords(19, VoiceLanguage.english), 'nineteen');
      expect(numberWords(20, VoiceLanguage.english), 'twenty');
      expect(numberWords(21, VoiceLanguage.english), 'twenty-one');
      expect(numberWords(47, VoiceLanguage.english), 'forty-seven');
      expect(numberWords(80, VoiceLanguage.english), 'eighty');
      expect(numberWords(90, VoiceLanguage.english), 'ninety');
    });

    test('a round ten never trails a unit', () {
      for (final ten in [20, 30, 40, 50, 60, 70, 80, 90]) {
        expect(numberWords(ten, VoiceLanguage.english), isNot(contains('-')));
      }
    });
  });

  group('hindi', () {
    test('the table covers one to ninety', () {
      for (var n = 1; n <= 90; n++) {
        final words = numberWords(n, VoiceLanguage.hindi);
        expect(words, isNotNull, reason: 'no Hindi word for $n');
        expect(words, isNotEmpty, reason: 'empty Hindi word for $n');
      }
    });

    test('no two numbers share a word', () {
      // A copy-paste slip in a ninety-entry table is otherwise invisible until
      // someone hears the wrong number called.
      final words = [
        for (var n = 1; n <= 90; n++) numberWords(n, VoiceLanguage.hindi)!,
      ];
      expect(words.toSet().length, 90);
    });

    test('a known handful', () {
      expect(numberWords(1, VoiceLanguage.hindi), 'एक');
      expect(numberWords(10, VoiceLanguage.hindi), 'दस');
      expect(numberWords(47, VoiceLanguage.hindi), 'सैंतालीस');
      expect(numberWords(90, VoiceLanguage.hindi), 'नब्बे');
    });
  });

  test('both languages cover the whole range and nothing outside it', () {
    for (final language in VoiceLanguage.values) {
      expect(numberWords(0, language), isNull);
      expect(numberWords(-1, language), isNull);
      expect(numberWords(100, language), isNull);
      for (var n = 1; n <= 99; n++) {
        expect(
          numberWords(n, language),
          isNotNull,
          reason: '${language.id} missing $n',
        );
      }
    }
  });

  group('the voice test number', () {
    test('is one no game can ever call', () {
      // The whole point of it: a sample nobody can mistake for a real call.
      for (final mode in GameMode.values) {
        expect(
          voiceTestNumber,
          greaterThan(mode.maxNumber),
          reason: '${mode.id} can draw $voiceTestNumber',
        );
      }
    });

    test('both languages can say it', () {
      expect(
        numberWords(voiceTestNumber, VoiceLanguage.english),
        'ninety-seven',
      );
      expect(numberWords(voiceTestNumber, VoiceLanguage.hindi), 'सत्तानवे');
    });
  });

  group('stored ids', () {
    test('round trip', () {
      for (final language in VoiceLanguage.values) {
        expect(VoiceLanguage.fromId(language.id), language);
      }
    });

    test('an unknown id returns null', () {
      expect(VoiceLanguage.fromId('fr'), isNull);
      expect(VoiceLanguage.fromId(null), isNull);
    });

    test('the locales handed to the speech engine are well formed', () {
      expect(VoiceLanguage.english.locale, 'en-US');
      expect(VoiceLanguage.hindi.locale, 'hi-IN');
    });
  });
}
