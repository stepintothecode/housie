import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../core/settings.dart';

/// What the app asks of the handset itself: a nudge you can feel, a screen
/// that stays on, and which way up it sits.
abstract class Device {
  /// A short tick, for a number being drawn.
  Future<void> tap();

  /// A heavier bump, for the last number of a game.
  Future<void> thud();

  /// Holds the display awake, or releases it.
  Future<void> keepAwake(bool on);

  /// Pins the app to one orientation, or lets it follow the handset.
  Future<void> lockOrientation(OrientationLock lock);
}

class HandsetDevice implements Device {
  /// Android and iOS need different calls here, and the difference matters.
  ///
  /// Flutter's impact feedbacks go through `performHapticFeedback` on
  /// Android, which the system drops without a word when touch feedback is
  /// switched off in settings. That is the right behaviour for a keyboard
  /// tick and the wrong one here: the player turned this on with a switch
  /// that says "vibrate on each call", so it uses the vibrator directly and
  /// the manifest asks for the VIBRATE permission.
  ///
  /// On iOS the reverse holds. `vibrate` there is the old long buzz, whereas
  /// the impact feedbacks drive the Taptic Engine and feel like the rest of
  /// the system.
  @override
  Future<void> tap() => _quietly(
    () => _isIOS ? HapticFeedback.mediumImpact() : HapticFeedback.vibrate(),
  );

  @override
  Future<void> thud() => _quietly(() async {
    if (_isIOS) return HapticFeedback.heavyImpact();
    // Android has no strength control on a plain vibrate, so the last number
    // of the game gets two pulses instead of a longer one.
    await HapticFeedback.vibrate();
    await Future<void>.delayed(const Duration(milliseconds: 140));
    await HapticFeedback.vibrate();
  });

  @override
  Future<void> keepAwake(bool on) =>
      _quietly(() => WakelockPlus.toggle(enable: on));

  @override
  Future<void> lockOrientation(OrientationLock lock) => _quietly(
    () => SystemChrome.setPreferredOrientations(switch (lock) {
      OrientationLock.auto => const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
      OrientationLock.portrait => const [DeviceOrientation.portraitUp],
      OrientationLock.landscape => const [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    }),
  );

  bool get _isIOS => defaultTargetPlatform == TargetPlatform.iOS;

  /// Handsets without a vibration motor, and desktop hosts, throw here. None
  /// of it is worth surfacing: the feedback is a bonus, not the feature.
  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      // Ignored on purpose.
    }
  }
}
