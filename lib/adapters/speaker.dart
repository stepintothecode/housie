import 'package:flutter_tts/flutter_tts.dart';

import '../core/number_words.dart';

/// Says a number out loud.
///
/// The seam exists so the game logic can be tested without a speech engine,
/// and so every quirk of the platform engines is contained in one file.
abstract class Speaker {
  /// Speaks [text] in [language], cutting off anything still being said.
  ///
  /// Never throws. A device with no voice for the language stays silent
  /// rather than taking the game down.
  Future<void> say(String text, VoiceLanguage language, double rate);

  Future<void> stop();

  /// Whether the platform has a voice installed for [language]. Used to warn
  /// in settings instead of letting the player wonder why nothing was said.
  Future<bool> supports(VoiceLanguage language);

  void dispose();
}

class FlutterTtsSpeaker implements Speaker {
  FlutterTtsSpeaker() : _tts = FlutterTts();

  final FlutterTts _tts;
  VoiceLanguage? _language;
  double? _rate;

  @override
  Future<void> say(String text, VoiceLanguage language, double rate) async {
    try {
      await _tts.stop();
      // Setting these on every call is wasteful, so only push what changed.
      if (_language != language) {
        await _tts.setLanguage(language.locale);
        _language = language;
      }
      if (_rate != rate) {
        await _tts.setSpeechRate(rate);
        _rate = rate;
      }
      await _tts.speak(text);
    } catch (_) {
      // A missing voice, a busy engine or an OEM engine that reports an error
      // for a call that worked anyway. None of it should interrupt the game.
      _language = null;
      _rate = null;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {
      // Nothing was playing, or the engine went away. Either is fine.
    }
  }

  @override
  Future<bool> supports(VoiceLanguage language) async {
    try {
      final available = await _tts.isLanguageAvailable(language.locale);
      return available == true;
    } catch (_) {
      // Unknown rather than unsupported. Assume it works and let the player
      // hear for themselves, instead of showing a warning that may be wrong.
      return true;
    }
  }

  @override
  void dispose() {
    _tts.stop();
  }
}
