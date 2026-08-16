/// What the voice says for a drawn number.
///
/// The words are spelled out rather than handed to the engine as digits, so a
/// number sounds the same on every device instead of depending on how a
/// particular text-to-speech build reads "47".
enum VoiceLanguage {
  english(id: 'en', label: 'English', locale: 'en-US'),
  hindi(id: 'hi', label: 'हिंदी (Hindi)', locale: 'hi-IN');

  const VoiceLanguage({
    required this.id,
    required this.label,
    required this.locale,
  });

  /// Stable key written to storage. Never change these.
  final String id;
  final String label;

  /// BCP-47 tag handed to the platform speech engine.
  final String locale;

  static VoiceLanguage? fromId(String? id) {
    for (final language in values) {
      if (language.id == id) return language;
    }
    return null;
  }
}

/// Words for 1-99 in [language]. Returns null outside that range.
///
/// A game only ever asks for 1-90. The rest of the range exists so the voice
/// test in settings can say a number no game can produce, which is what stops
/// anyone in the room hearing it as a real call.
String? numberWords(int number, VoiceLanguage language) {
  if (number < 1 || number > 99) return null;
  return switch (language) {
    VoiceLanguage.english => _english(number),
    VoiceLanguage.hindi => _hindi[number - 1],
  };
}

String _english(int number) {
  if (number < 20) return _englishUnits[number - 1];
  final tens = _englishTens[number ~/ 10 - 2];
  final unit = number % 10;
  return unit == 0 ? tens : '$tens-${_englishUnits[unit - 1]}';
}

const _englishUnits = [
  'one',
  'two',
  'three',
  'four',
  'five',
  'six',
  'seven',
  'eight',
  'nine',
  'ten',
  'eleven',
  'twelve',
  'thirteen',
  'fourteen',
  'fifteen',
  'sixteen',
  'seventeen',
  'eighteen',
  'nineteen',
];

const _englishTens = [
  'twenty',
  'thirty',
  'forty',
  'fifty',
  'sixty',
  'seventy',
  'eighty',
  'ninety',
];

/// The number the voice test says, in both languages.
///
/// Ninety-seven on purpose. Housie stops at 90 and bingo at 75, so this can
/// never be a number that was actually drawn, and nobody half-listening from
/// across the room can mistake the test for a call.
const voiceTestNumber = 97;

/// Hindi has a distinct word for each number up to a hundred, so there is no
/// rule to generate these from. Index 0 is 1.
const _hindi = [
  'एक',
  'दो',
  'तीन',
  'चार',
  'पाँच',
  'छह',
  'सात',
  'आठ',
  'नौ',
  'दस',
  'ग्यारह',
  'बारह',
  'तेरह',
  'चौदह',
  'पंद्रह',
  'सोलह',
  'सत्रह',
  'अठारह',
  'उन्नीस',
  'बीस',
  'इक्कीस',
  'बाईस',
  'तेईस',
  'चौबीस',
  'पच्चीस',
  'छब्बीस',
  'सत्ताईस',
  'अट्ठाईस',
  'उनतीस',
  'तीस',
  'इकतीस',
  'बत्तीस',
  'तैंतीस',
  'चौंतीस',
  'पैंतीस',
  'छत्तीस',
  'सैंतीस',
  'अड़तीस',
  'उनतालीस',
  'चालीस',
  'इकतालीस',
  'बयालीस',
  'तैंतालीस',
  'चवालीस',
  'पैंतालीस',
  'छियालीस',
  'सैंतालीस',
  'अड़तालीस',
  'उनचास',
  'पचास',
  'इक्यावन',
  'बावन',
  'तिरेपन',
  'चौवन',
  'पचपन',
  'छप्पन',
  'सत्तावन',
  'अट्ठावन',
  'उनसठ',
  'साठ',
  'इकसठ',
  'बासठ',
  'तिरेसठ',
  'चौंसठ',
  'पैंसठ',
  'छियासठ',
  'सड़सठ',
  'अड़सठ',
  'उनहत्तर',
  'सत्तर',
  'इकहत्तर',
  'बहत्तर',
  'तिहत्तर',
  'चौहत्तर',
  'पचहत्तर',
  'छिहत्तर',
  'सतहत्तर',
  'अठहत्तर',
  'उन्यासी',
  'अस्सी',
  'इक्यासी',
  'बयासी',
  'तिरासी',
  'चौरासी',
  'पचासी',
  'छियासी',
  'सत्तासी',
  'अठासी',
  'नवासी',
  'नब्बे',
  // 91 to 99. Only the voice test reaches this far; no game calls them.
  'इक्यानवे',
  'बानवे',
  'तिरानवे',
  'चौरानवे',
  'पचानवे',
  'छियानवे',
  'सत्तानवे',
  'अट्ठानवे',
  'निन्यानवे',
];
