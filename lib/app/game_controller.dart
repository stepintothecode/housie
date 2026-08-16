import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../adapters/device.dart';
import '../adapters/speaker.dart';
import '../adapters/store.dart';
import '../core/caller_state.dart';
import '../core/number_words.dart';
import 'settings_controller.dart';

/// Drives one game: draws, undoes, resets, and everything that should happen
/// around a draw.
///
/// A saved game is restored on launch, so a phone that dies mid-game does not
/// lose the numbers already called.
class GameController extends ChangeNotifier {
  GameController({
    required Store store,
    required Speaker speaker,
    required Device device,
    required SettingsController settings,
    Random? random,
    Duration drawLock = defaultDrawLock,
  }) : _store = store,
       _speaker = speaker,
       _device = device,
       _settings = settings,
       _random = random ?? Random.secure(),
       _drawLock = drawLock {
    final saved = CallerState.fromJson(store.read(storageKey));
    // A saved game from a mode the player has since switched away from is
    // dropped rather than dragged into a board it does not fit.
    _state = saved != null && saved.mode == settings.value.mode
        ? saved
        : CallerState(mode: settings.value.mode);
    _settings.addListener(_onSettingsChanged);
    _applyWakelock();
  }

  static const storageKey = 'game';

  final Store _store;
  final Speaker _speaker;
  final Device _device;
  final SettingsController _settings;
  final Random _random;

  /// How long the draw button stays down after a call, so a fast tapper
  /// cannot outrun the number landing on screen. Tests pass zero.
  final Duration _drawLock;

  static const defaultDrawLock = Duration(milliseconds: 260);

  late CallerState _state;
  CallerState get state => _state;

  /// True from the moment a number is drawn until its animation settles.
  /// The draw button reads it so a fast tapper cannot outrun the display.
  bool _drawing = false;
  bool get isDrawing => _drawing;

  bool get canDraw => !_state.isComplete && !_drawing;

  bool get canUndo => !_state.isFresh && !_drawing;

  Future<void> draw() async {
    if (!canDraw) return;
    final next = _state.draw(_random);
    if (next == null) return;

    _drawing = true;
    _commit(next);

    // try/finally, so an adapter that throws cannot leave the button locked
    // for the rest of the game.
    try {
      final settings = _settings.value;
      if (settings.haptics) {
        await (next.isComplete ? _device.thud() : _device.tap());
      }
      if (settings.speakNumbers) {
        final words = numberWords(next.current!, settings.language);
        if (words != null) {
          // Not awaited. The number should be on screen immediately, and the
          // voice catches up a moment later.
          unawaited(
            _speaker.say(words, settings.language, settings.speechRate),
          );
        }
      }
      await Future<void>.delayed(_drawLock);
    } finally {
      _drawing = false;
      notifyListeners();
    }
  }

  Future<void> undo() async {
    if (!canUndo) return;
    final next = _state.undo();
    if (next == null) return;
    await _speaker.stop();
    if (_settings.value.haptics) await _device.tap();
    _commit(next);
  }

  Future<void> reset() async {
    await _speaker.stop();
    if (_settings.value.haptics) await _device.tap();
    _commit(_state.reset());
  }

  void _onSettingsChanged() {
    final mode = _settings.value.mode;
    if (mode != _state.mode) _commit(_state.withMode(mode));
    _applyWakelock();
  }

  void _commit(CallerState next) {
    _state = next;
    notifyListeners();
    _store.write(storageKey, next.toJson());
    _applyWakelock();
  }

  /// The screen is held awake only while a game is actually running. Holding
  /// it on an idle or finished board just burns battery.
  void _applyWakelock() {
    final wanted =
        _settings.value.keepAwake && !_state.isFresh && !_state.isComplete;
    if (wanted == _awake) return;
    _awake = wanted;
    _device.keepAwake(wanted);
  }

  bool _awake = false;

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    _device.keepAwake(false);
    _speaker.stop();
    super.dispose();
  }
}
