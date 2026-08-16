import 'game_mode.dart';
import 'number_words.dart';

/// Which palette the app paints in.
enum ThemeChoice {
  system(id: 'system', label: 'System'),
  light(id: 'light', label: 'Light'),
  dark(id: 'dark', label: 'Dark');

  const ThemeChoice({required this.id, required this.label});

  /// Stable key written to storage. Never change these.
  final String id;
  final String label;

  static ThemeChoice? fromId(String? id) {
    for (final choice in values) {
      if (choice.id == id) return choice;
    }
    return null;
  }
}

/// Which way up the app is pinned.
///
/// Deliberately not part of [Settings] and not saved. A lock is for the next
/// few minutes, and a phone that opens sideways a week later because of a tap
/// nobody remembers is a bug report.
enum OrientationLock {
  /// Follow the handset, which is what most people want most of the time.
  auto,
  portrait,
  landscape;

  bool get isLocked => this != auto;
}

/// Everything the player can change, in one immutable value.
class Settings {
  const Settings({
    this.mode = GameMode.housie90,
    this.theme = ThemeChoice.system,
    this.speakNumbers = true,
    this.language = VoiceLanguage.english,
    this.speechRate = defaultSpeechRate,
    this.haptics = true,
    this.keepAwake = true,
  });

  static const defaultSpeechRate = 0.45;
  static const minSpeechRate = 0.2;
  static const maxSpeechRate = 0.9;

  final GameMode mode;
  final ThemeChoice theme;
  final bool speakNumbers;
  final VoiceLanguage language;

  /// 0.2 to 0.9, where the platform treats 1.0 as unnaturally fast.
  final double speechRate;

  final bool haptics;

  /// Holds the screen on during a game. A caller sets the phone down between
  /// draws and the display locking mid-game is the top complaint about every
  /// other app of this kind.
  final bool keepAwake;

  Settings copyWith({
    GameMode? mode,
    ThemeChoice? theme,
    bool? speakNumbers,
    VoiceLanguage? language,
    double? speechRate,
    bool? haptics,
    bool? keepAwake,
  }) {
    return Settings(
      mode: mode ?? this.mode,
      theme: theme ?? this.theme,
      speakNumbers: speakNumbers ?? this.speakNumbers,
      language: language ?? this.language,
      speechRate: _clampRate(speechRate ?? this.speechRate),
      haptics: haptics ?? this.haptics,
      keepAwake: keepAwake ?? this.keepAwake,
    );
  }

  Map<String, Object?> toJson() => {
    'mode': mode.id,
    'theme': theme.id,
    'speakNumbers': speakNumbers,
    'language': language.id,
    'speechRate': speechRate,
    'haptics': haptics,
    'keepAwake': keepAwake,
  };

  /// Reads saved settings. Unlike a game in progress, a single unreadable
  /// field is not worth discarding the rest for, so each one falls back to its
  /// default on its own.
  ///
  /// Every field is type-checked rather than cast. A cast here would throw on
  /// a value of the wrong type, and this runs before the first frame, so the
  /// app would fail to open rather than fall back.
  static Settings fromJson(Map<String, Object?>? json) {
    if (json == null) return const Settings();
    const fallback = Settings();
    return Settings(
      mode: GameMode.fromId(_text(json['mode'])) ?? fallback.mode,
      theme: ThemeChoice.fromId(_text(json['theme'])) ?? fallback.theme,
      speakNumbers: _flag(json['speakNumbers'], fallback.speakNumbers),
      language:
          VoiceLanguage.fromId(_text(json['language'])) ?? fallback.language,
      speechRate: _rate(json['speechRate'], fallback.speechRate),
      haptics: _flag(json['haptics'], fallback.haptics),
      keepAwake: _flag(json['keepAwake'], fallback.keepAwake),
    );
  }

  static String? _text(Object? value) => value is String ? value : null;

  static bool _flag(Object? value, bool fallback) =>
      value is bool ? value : fallback;

  static double _rate(Object? value, double fallback) =>
      value is num ? _clampRate(value.toDouble()) : fallback;

  static double _clampRate(double rate) =>
      rate.clamp(minSpeechRate, maxSpeechRate);
}
