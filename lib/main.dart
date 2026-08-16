import 'dart:async';

import 'package:flutter/material.dart';

import 'adapters/device.dart';
import 'adapters/link_opener.dart';
import 'adapters/speaker.dart';
import 'adapters/store.dart';
import 'app/app.dart';
import 'app/game_controller.dart';
import 'app/orientation_controller.dart';
import 'app/settings_controller.dart';
import 'core/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Read once here so the first frame already has the saved game and settings,
  // rather than flashing an empty board.
  final store = await PreferencesStore.open();
  final speaker = FlutterTtsSpeaker();
  final device = HandsetDevice();

  // Rotates, because a phone propped sideways on a table is a good way to run
  // a game. Upside down portrait is left out: nothing is gained by it and it
  // makes a phone picked up the wrong way flip unexpectedly.
  final orientation = OrientationController(device: device);
  await device.lockOrientation(OrientationLock.auto);

  final settings = SettingsController(
    store: store,
    speaker: speaker,
    device: device,
  );
  final game = GameController(
    store: store,
    speaker: speaker,
    device: device,
    settings: settings,
  );

  if (settings.value.speakNumbers) {
    // Not awaited: the answer only drives a warning in settings, and asking
    // the platform for it can take a second on a cold start.
    unawaited(settings.refreshVoiceAvailability());
  }

  runApp(
    HousieApp(
      game: game,
      settings: settings,
      orientation: orientation,
      links: BrowserLinkOpener(),
    ),
  );
}
