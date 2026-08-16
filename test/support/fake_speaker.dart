import 'package:housie_bingo_caller/adapters/speaker.dart';
import 'package:housie_bingo_caller/core/number_words.dart';

/// Records what would have been said instead of saying it.
class FakeSpeaker implements Speaker {
  FakeSpeaker({this.hasVoice = true});

  /// What [supports] answers, so tests can cover a phone with no Hindi voice.
  final bool hasVoice;

  final List<String> spoken = [];
  final List<VoiceLanguage> languages = [];
  int stops = 0;

  String? get last => spoken.isEmpty ? null : spoken.last;

  @override
  Future<void> say(String text, VoiceLanguage language, double rate) async {
    spoken.add(text);
    languages.add(language);
  }

  @override
  Future<void> stop() async => stops++;

  @override
  Future<bool> supports(VoiceLanguage language) async => hasVoice;

  @override
  void dispose() {}
}
