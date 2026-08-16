// Renders each screen to a PNG in build/screenshots/.
//
//   flutter test tool/screenshots_test.dart
//
// Lives in tool/ rather than test/ so `flutter test` does not run it: it
// writes files and proves nothing, it just lets you look at the app without a
// device, and gives a starting point for the store screenshots.
//
// The test renderer draws every glyph as a box unless real fonts are loaded,
// so this registers the ones bundled with the Flutter SDK.
//
// Known quirk: every case writes its PNG and then reports a timeout in
// teardown. The files are correct and complete. Read the "wrote ..." lines
// rather than the exit code.
//
// Devanagari still renders as boxes because Roboto has no Devanagari glyphs.
// Phones do, so the Hindi option only looks wrong here.

import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/game_controller.dart';
import 'package:housie_bingo_caller/app/orientation_controller.dart';
import 'package:housie_bingo_caller/app/screens/game_screen.dart';
import 'package:housie_bingo_caller/app/screens/home_shell.dart';
import 'package:housie_bingo_caller/app/screens/settings_screen.dart';
import 'package:housie_bingo_caller/app/screens/support_screen.dart';
import 'package:housie_bingo_caller/app/settings_controller.dart';
import 'package:housie_bingo_caller/app/theme/app_theme.dart';
import 'package:housie_bingo_caller/app/widgets/full_house.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/settings.dart';

import 'render.dart';

import '../test/support/fake_device.dart';
import '../test/support/fake_link_opener.dart';
import '../test/support/fake_speaker.dart';
import '../test/support/fake_store.dart';

/// A phone that is tall enough to be representative without being a monster,
/// and the same phone turned sideways.
const _size = Size(412, 915);
const _sideways = Size(915, 412);
const _outputDir = 'build/screenshots';

void main() {
  // Font loading needs a binding, and setUpAll runs before the first
  // testWidgets would create one.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await loadBundledFonts();
    Directory(_outputDir).createSync(recursive: true);
  });

  testWidgets('game, dark, mid game', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 23);
    await _shoot(
      tester,
      'game-dark',
      dark: true,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  testWidgets('game, light, mid game', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 23);
    await _shoot(
      tester,
      'game-light',
      dark: false,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  testWidgets('game, empty board', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 0);
    await _shoot(
      tester,
      'game-empty',
      dark: true,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  testWidgets('game, bingo 75', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.bingo75, draws: 17);
    await _shoot(
      tester,
      'game-bingo',
      dark: true,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  testWidgets('game, sideways', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 23);
    await _shoot(
      tester,
      'game-landscape',
      dark: true,
      sideways: true,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  testWidgets('game, sideways, bingo', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.bingo75, draws: 17);
    await _shoot(
      tester,
      'game-landscape-bingo',
      dark: true,
      sideways: true,
      child: GameScreen(game: game, orientation: _orientation!),
    );
  });

  // The whole shell, so the navigation itself is in shot: a bar along the
  // bottom upright, a rail down the right hand side sideways.
  testWidgets('shell, upright', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 23);
    await _shoot(
      tester,
      'shell-portrait',
      dark: true,
      child: HomeShell(
        game: game,
        orientation: _orientation!,
        settings: _settings!,
        links: FakeLinkOpener(),
      ),
    );
  });

  testWidgets('shell, sideways', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 23);
    await _shoot(
      tester,
      'shell-landscape',
      dark: true,
      sideways: true,
      child: HomeShell(
        game: game,
        orientation: _orientation!,
        settings: _settings!,
        links: FakeLinkOpener(),
      ),
    );
  });

  testWidgets('settings', timeout: _quick, (tester) async {
    final game = await _game(tester, mode: GameMode.housie90, draws: 0);
    await _shoot(
      tester,
      'settings-dark',
      dark: true,
      child: SettingsScreen(settings: _settings!, game: game),
    );
  });

  testWidgets('the easter egg', timeout: _quick, (tester) async {
    tester.view.physicalSize = _size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The boundary has to sit outside the app, not inside its home. The
    // celebration is a route pushed over the top, so a boundary within the
    // home screen captures only what is underneath it.
    final key = GlobalKey();
    await tester.pumpWidget(
      RepaintBoundary(
        key: key,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          // Named so the inline styles in the celebration inherit a real
          // font, the same reason _shoot does it.
          theme: AppTheme.dark().copyWith(
            textTheme: AppTheme.dark().textTheme.apply(fontFamily: renderFont),
          ),
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => FullHouse.celebrate(context),
                  child: const Text('go'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    // Far enough in that the later balls have been let go and the first are
    // halfway down, rather than a single row still at the top.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 2400));

    await captureToPng(tester, key: key, path: '$_outputDir/easter-egg.png');
  });

  testWidgets('support', timeout: _quick, (tester) async {
    await _shoot(
      tester,
      'support-dark',
      dark: true,
      child: SupportScreen(links: FakeLinkOpener()),
    );
  });
}

/// Short, so a hang shows up in seconds instead of the default ten minutes.
const _quick = Timeout(Duration(seconds: 90));

SettingsController? _settings;
OrientationController? _orientation;

Future<GameController> _game(
  WidgetTester tester, {
  required GameMode mode,
  required int draws,
}) async {
  final store = FakeStore()
    ..seedRaw(SettingsController.storageKey, Settings(mode: mode).toJson());
  final speaker = FakeSpeaker();
  final device = FakeDevice();
  _settings = SettingsController(
    store: store,
    speaker: speaker,
    device: device,
  );
  _orientation = OrientationController(device: device);

  final game = GameController(
    store: store,
    speaker: speaker,
    device: device,
    settings: _settings!,
    random: Random(4),
    drawLock: Duration.zero,
  );
  // runAsync, because draw() awaits a Future.delayed for its draw lock and a
  // widget test's clock is fake: outside runAsync that delay never completes.
  await tester.runAsync(() async {
    for (var i = 0; i < draws; i++) {
      await game.draw();
    }
  });
  return game;
}

Future<void> _shoot(
  WidgetTester tester,
  String name, {
  required bool dark,
  required Widget child,
  bool sideways = false,
}) async {
  tester.view.physicalSize = sideways ? _sideways : _size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final theme = dark ? AppTheme.dark() : AppTheme.light();
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // The app leaves the font to the platform. Tests have no platform font,
      // so the loaded Roboto is named explicitly here and nowhere else.
      // Inline TextStyles inherit the family through DefaultTextStyle, but a
      // component theme holds a style that was resolved before this override,
      // so each of those has to be named again.
      theme: theme.copyWith(
        textTheme: theme.textTheme.apply(fontFamily: renderFont),
        appBarTheme: theme.appBarTheme.copyWith(
          titleTextStyle: _named(theme.appBarTheme.titleTextStyle),
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          titleTextStyle: _named(theme.listTileTheme.titleTextStyle),
          subtitleTextStyle: _named(theme.listTileTheme.subtitleTextStyle),
        ),
        dialogTheme: theme.dialogTheme.copyWith(
          titleTextStyle: _named(theme.dialogTheme.titleTextStyle),
          contentTextStyle: _named(theme.dialogTheme.contentTextStyle),
        ),
        navigationRailTheme: theme.navigationRailTheme.copyWith(
          selectedLabelTextStyle: _named(
            theme.navigationRailTheme.selectedLabelTextStyle,
          ),
          unselectedLabelTextStyle: _named(
            theme.navigationRailTheme.unselectedLabelTextStyle,
          ),
        ),
      ),
      home: RepaintBoundary(key: _boundary, child: child),
    ),
  );
  // Fixed pumps rather than pumpAndSettle: everything here animates in under
  // half a second, and a settle that never finishes is impossible to debug.
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 500));
  // Decoding an asset image is real async work that the fake clock never
  // lets finish, so the app icon comes out blank without this.
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 100)),
  );
  await tester.pump();

  await captureToPng(
    tester,
    key: _boundary,
    path: '$_outputDir/$name.png',
    pixelRatio: 2,
  );
}

final _boundary = GlobalKey();

TextStyle? _named(TextStyle? style) => style?.copyWith(fontFamily: renderFont);
