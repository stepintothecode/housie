import 'dart:async';

import 'package:flutter/foundation.dart';

import '../adapters/device.dart';
import '../adapters/speaker.dart';
import '../adapters/store.dart';
import '../core/game_mode.dart';
import '../core/number_words.dart';
import '../core/settings.dart';

/// Holds the current [Settings] and writes every change straight to storage.
class SettingsController extends ChangeNotifier {
  SettingsController({
    required Store store,
    required Speaker speaker,
    required Device device,
  }) : _store = store,
       _speaker = speaker,
       _device = device,
       _value = Settings.fromJson(store.read(storageKey));

  static const storageKey = 'settings';

  final Store _store;
  final Speaker _speaker;
  final Device _device;

  Settings _value;
  Settings get value => _value;

  /// Null until checked. Only ever false when the platform is sure it has no
  /// voice for the chosen language.
  bool? _voiceAvailable;
  bool? get voiceAvailable => _voiceAvailable;

  void setMode(GameMode mode) => _update(_value.copyWith(mode: mode));

  void setTheme(ThemeChoice theme) => _update(_value.copyWith(theme: theme));

  void setSpeakNumbers(bool on) {
    _update(_value.copyWith(speakNumbers: on));
    if (on) {
      refreshVoiceAvailability();
    } else {
      _speaker.stop();
    }
  }

  void setLanguage(VoiceLanguage language) {
    _update(_value.copyWith(language: language));
    refreshVoiceAvailability();
  }

  void setSpeechRate(double rate) => _update(_value.copyWith(speechRate: rate));

  void setHaptics(bool on) {
    _update(_value.copyWith(haptics: on));
    // Buzz once on the way on, so you can tell straight away whether this
    // handset actually does anything, instead of starting a game to find out.
    if (on) unawaited(_device.tap());
  }

  void setKeepAwake(bool on) => _update(_value.copyWith(keepAwake: on));

  /// Speaks a sample so the player can hear the language and rate they picked
  /// without starting a game.
  Future<void> previewVoice() async {
    final words = numberWords(voiceTestNumber, _value.language);
    if (words == null) return;
    await _speaker.say(words, _value.language, _value.speechRate);
  }

  /// The words the test speaks. See [voiceTestNumber] for why it is 97.
  String get voiceSample => numberWords(voiceTestNumber, _value.language) ?? '';

  Future<void> refreshVoiceAvailability() async {
    final language = _value.language;
    final available = await _speaker.supports(language);
    // Another change may have landed while the platform was answering.
    if (language != _value.language) return;
    _voiceAvailable = available;
    notifyListeners();
  }

  void _update(Settings next) {
    if (identical(next, _value)) return;
    _value = next;
    notifyListeners();
    _store.write(storageKey, next.toJson());
  }
}
