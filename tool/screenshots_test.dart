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
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/game_controller.dart';
import 'package:housie_bingo_caller/app/orientation_controller.dart';
import 'package:housie_bingo_caller/app/screens/game_screen.dart';
import 'package:housie_bingo_caller/app/screens/home_shell.dart';
import 'package:housie_bingo_caller/app/screens/settings_screen.dart';
import 'package:housie_bingo_caller/app/screens/support_screen.dart';
import 'package:housie_bingo_caller/app/settings_controller.dart';
import 'package:housie_bingo_caller/app/theme/app_theme.dart';
import 'package:housie_bingo_caller/core/game_mode.dart';
import 'package:housie_bingo_caller/core/settings.dart';

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
    await _loadFonts();
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
        textTheme: theme.textTheme.apply(fontFamily: _fontFamily),
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
  stdout.writeln('$name: laid out');

  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(_boundary),
  );
  // Not wrapped in runAsync. That is what golden tests do, and runAsync
  // deadlocks here against the test binding's own rasterisation.
  final image = await boundary.toImage(pixelRatio: 2);
  stdout.writeln('$name: rasterised');
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  File('$_outputDir/$name.png').writeAsBytesSync(data!.buffer.asUint8List());
  stdout.writeln('$name: wrote $_outputDir/$name.png');
}

final _boundary = GlobalKey();

TextStyle? _named(TextStyle? style) => style?.copyWith(fontFamily: _fontFamily);

/// Name the screenshots render text under. The theme is pointed at it in
/// [_shoot]; the app itself does not set a font and uses the platform's.
const _fontFamily = 'ScreenshotRoboto';

/// The flutter_test renderer draws every glyph as a filled box unless real
/// fonts are registered. Both of these ship inside the Flutter SDK, so the
/// output matches what Android actually renders rather than whatever happens
/// to be installed on this machine.
Future<void> _loadFonts() async {
  final cache = _materialFontsDir();
  if (cache == null) {
    stdout.writeln('material_fonts not found: text will render as boxes');
    return;
  }

  // Regular through black, so w400 to w800 in the theme all resolve.
  const weights = [
    'roboto-regular.ttf',
    'roboto-medium.ttf',
    'roboto-bold.ttf',
    'roboto-black.ttf',
  ];
  final text = FontLoader(_fontFamily);
  for (final name in weights) {
    final file = File('$cache/$name');
    if (file.existsSync()) text.addFont(_bytes(file));
  }
  await text.load();

  final icons = FontLoader('MaterialIcons')
    ..addFont(_bytes(File('$cache/materialicons-regular.otf')));
  await icons.load();

  stdout.writeln('fonts loaded from $cache');
}

Future<ByteData> _bytes(File file) async =>
    ByteData.sublistView(file.readAsBytesSync());

/// Walks up from the running Flutter tool to its bundled fonts.
String? _materialFontsDir() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'];
  final candidates = [
    if (flutterRoot != null) '$flutterRoot/bin/cache/artifacts/material_fonts',
    r'C:\src\flutter\bin\cache\artifacts\material_fonts',
  ];
  for (final path in candidates) {
    if (Directory(path).existsSync()) return path;
  }
  return null;
}
