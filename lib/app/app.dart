import 'package:flutter/material.dart';

import '../adapters/link_opener.dart';
import '../core/app_info.dart';
import '../core/settings.dart';
import 'game_controller.dart';
import 'orientation_controller.dart';
import 'settings_controller.dart';
import 'screens/home_shell.dart';
import 'theme/app_theme.dart';

class HousieApp extends StatelessWidget {
  const HousieApp({
    super.key,
    required this.game,
    required this.settings,
    required this.orientation,
    required this.links,
  });

  final GameController game;
  final SettingsController settings;
  final OrientationController orientation;
  final LinkOpener links;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return MaterialApp(
          title: AppInfo.name,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: switch (settings.value.theme) {
            ThemeChoice.system => ThemeMode.system,
            ThemeChoice.light => ThemeMode.light,
            ThemeChoice.dark => ThemeMode.dark,
          },
          themeAnimationDuration: const Duration(milliseconds: 200),
          home: HomeShell(
            game: game,
            settings: settings,
            orientation: orientation,
            links: links,
          ),
        );
      },
    );
  }
}
