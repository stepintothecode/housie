import 'package:flutter/material.dart';

import '../../core/game_mode.dart';
import '../../core/number_words.dart';
import '../../core/settings.dart';
import '../game_controller.dart';
import '../settings_controller.dart';
import '../theme/tokens.dart';
import '../widgets/settings_tiles.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.settings, required this.game});

  final SettingsController settings;
  final GameController game;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([settings, game]),
      builder: (context, _) {
        final value = settings.value;
        final palette = context.palette;

        return Scaffold(
          appBar: AppBar(title: const Text('Settings')),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              Space.lg,
              Space.sm,
              Space.lg,
              Space.xxl,
            ),
            children: [
              SettingsSection(
                title: 'Game',
                children: [
                  ChoiceRow<GameMode>(
                    title: 'Number range',
                    subtitle:
                        'Housie and Tambola draw 1 to 90. Bingo draws 1 to 75 '
                        'in five lettered columns.',
                    options: {
                      for (final mode in GameMode.values)
                        mode: '${mode.label} ${mode.range}',
                    },
                    selected: value.mode,
                    onChanged: (mode) => _changeMode(context, mode),
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              SettingsSection(
                title: 'Appearance',
                children: [
                  ChoiceRow<ThemeChoice>(
                    title: 'Theme',
                    subtitle:
                        'System follows your phone. Dark is easier on the eyes '
                        'in a dim hall.',
                    options: {for (final c in ThemeChoice.values) c: c.label},
                    selected: value.theme,
                    onChanged: settings.setTheme,
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              SettingsSection(
                title: 'Voice',
                children: [
                  SwitchRow(
                    icon: Icons.record_voice_over_outlined,
                    title: 'Call numbers out loud',
                    subtitle: 'Speaks each number as it is drawn.',
                    value: value.speakNumbers,
                    onChanged: settings.setSpeakNumbers,
                  ),
                  if (value.speakNumbers) ...[
                    ChoiceRow<VoiceLanguage>(
                      title: 'Language',
                      subtitle:
                          'Uses the voices already on your phone. Nothing is '
                          'downloaded and nothing is sent anywhere.',
                      options: {
                        for (final l in VoiceLanguage.values) l: l.label,
                      },
                      selected: value.language,
                      onChanged: settings.setLanguage,
                    ),
                    _SpeedRow(settings: settings),
                    if (settings.voiceAvailable == false)
                      _VoiceWarning(language: value.language),
                  ],
                ],
              ),
              const SizedBox(height: Space.xl),
              SettingsSection(
                title: 'During play',
                children: [
                  SwitchRow(
                    icon: Icons.vibration_rounded,
                    title: 'Vibrate on each call',
                    subtitle: 'A short tap so you know the draw registered.',
                    value: value.haptics,
                    onChanged: settings.setHaptics,
                  ),
                  SwitchRow(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'Keep the screen on',
                    subtitle:
                        'Stops the display locking between calls. Only while a '
                        'game is running.',
                    value: value.keepAwake,
                    onChanged: settings.setKeepAwake,
                  ),
                ],
              ),
              const SizedBox(height: Space.xl),
              Text(
                'Everything you set here stays on this phone.',
                textAlign: TextAlign.center,
                style: TextStyle(color: palette.muted, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Switching range clears the board, because numbers from a 1-90 game mean
  /// nothing on a 1-75 one. Only worth asking about if a game is under way.
  Future<void> _changeMode(BuildContext context, GameMode mode) async {
    if (mode == settings.value.mode) return;

    if (game.state.isFresh) {
      settings.setMode(mode);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Switch to ${mode.title}?'),
        content: Text(
          'The ${game.state.calledCount} numbers called so far will be cleared, '
          'because they do not fit a ${mode.range} board.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch and clear'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) settings.setMode(mode);
  }
}

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({required this.settings});

  final SettingsController settings;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final value = settings.value;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.lg,
        Space.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Speaking speed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              // "Test", not "Hear". The word has to be on the button, and the
              // number has to be one no game can call, or somebody across the
              // room takes the sample for a real one.
              TextButton.icon(
                onPressed: settings.previewVoice,
                icon: const Icon(Icons.play_arrow_rounded, size: 20),
                label: Text('Test: ${settings.voiceSample}'),
                style: TextButton.styleFrom(foregroundColor: palette.accent),
              ),
            ],
          ),
          Slider(
            value: value.speechRate,
            min: Settings.minSpeechRate,
            max: Settings.maxSpeechRate,
            onChanged: settings.setSpeechRate,
            onChangeEnd: (_) => settings.previewVoice(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slower',
                style: TextStyle(color: palette.muted, fontSize: 12),
              ),
              Text(
                'Faster',
                style: TextStyle(color: palette.muted, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VoiceWarning extends StatelessWidget {
  const _VoiceWarning({required this.language});

  final VoiceLanguage language;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Container(
      margin: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
      padding: const EdgeInsets.all(Space.md),
      decoration: BoxDecoration(
        color: palette.calledFill,
        borderRadius: BorderRadius.circular(Radii.cell),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 20, color: palette.calledInk),
          const SizedBox(width: Space.md),
          Expanded(
            child: Text(
              'Your phone has no ${language.label} voice installed. Add one in '
              'your system text-to-speech settings, or the numbers will be read '
              'in whichever voice is available.',
              style: TextStyle(
                color: palette.calledInk,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
