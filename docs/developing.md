# Developing and testing this app

## Expo does not apply here

Expo is tooling for React Native, which is JavaScript. This app is Flutter,
which is Dart, and the two share nothing. There is no Expo Go equivalent to
scan a QR code with. Flutter's own tooling does the same job: `flutter run`
installs a debug build on a phone or emulator and gives you hot reload.

## Where the tools actually are

Neither one is a Windows program, so neither appears in Installed Apps and
neither has a window to open. They are folders of command line tools:

```
C:\src\flutter                                     the Flutter SDK
C:\Users\karti\AppData\Local\Android\Sdk           the Android SDK
```

Both are on your user PATH, along with `ANDROID_HOME` and `JAVA_HOME`.

**Open a new terminal before any of this works.** A terminal reads the PATH
once when it starts, so windows opened before the change still will not know
what `flutter` is. Close and reopen, then:

```sh
flutter --version
flutter doctor
```

`flutter doctor` reporting a red cross for Visual Studio is expected and
harmless. That is for building Windows desktop apps, which this project does
not do.

### If you want a GUI

Nothing here needs one, but Android Studio gives you a device manager, a
visual emulator list and a log viewer. Install it from
https://developer.android.com/studio, then point it at the existing SDK at
`%LOCALAPPDATA%\Android\Sdk` rather than letting it download a second copy.
VS Code with the Flutter extension is the lighter option and is enough.

## Running the app

### On a real phone, which is the one to use

Faster than the emulator, and the only way to judge the voice, the vibration
and whether the number really is readable across a room.

1. On the phone, open **Settings > About phone** and tap **Build number**
   seven times. That turns on Developer options.
2. **Settings > System > Developer options > USB debugging**, on.
3. Plug the phone into the PC with a cable that carries data. Many charging
   cables do not.
4. The phone shows "Allow USB debugging?". Tick always allow, accept.
5. Check the PC can see it:

   ```sh
   adb devices
   flutter devices
   ```

6. Run it:

   ```sh
   cd k:\Projects\housie
   flutter run
   ```

### On the emulator

An AVD named `housie_pixel` already exists. Start it and run:

```sh
emulator -avd housie_pixel
flutter run
```

Two things the emulator is bad at, so confirm both on a real phone before
release:

- **The voice.** Emulator images often ship with no text to speech data, so
  numbers are silent. Settings will show the "no voice installed" warning.
- **Vibration.** There is no motor to feel.

## The loop you will actually use

With `flutter run` attached, in that terminal:

| Key | What it does |
|---|---|
| `r` | Hot reload. Your change appears in about a second, game state is kept |
| `R` | Hot restart. Rebuilds from scratch, game state is lost |
| `o` | Toggle between Android and iOS visual styling |
| `q` | Quit |

Hot reload covers almost everything: colours, spacing, text, layout, widget
logic. You need hot restart after changing anything in `main.dart`, any
`initState`, or the shape of a class.

VS Code does the same on save if you run with **Run > Start Debugging** (F5)
instead, which also gives you breakpoints.

## The one warning you will see, and why it is left alone

Every `flutter run` prints this:

```
WARNING: Your app uses the following plugins that apply Kotlin Gradle Plugin
(KGP): flutter_tts
Future versions of Flutter will fail to build if your app uses plugins that
apply KGP.
```

**It is not caused by anything in this repo and cannot be fixed here.** Flutter
3.47 began providing Kotlin itself, and plugins are now supposed to stop
bringing their own. `flutter_tts` still does, in two lines of its
`android/build.gradle`:

```gradle
classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
apply plugin: 'kotlin-android'
```

Checked, so nobody has to check again:

| | |
|---|---|
| Latest release | 4.2.5, January 2026, still applies KGP |
| Upstream `master` | last commit January 2026, still applies KGP |
| `text_to_speech` | last published 2021 |
| `tts` | last published 2018 |

So there is no newer version to move to, no upstream commit to pin, and no
maintained alternative. The fix has to land in the plugin.

**Nothing will break unexpectedly.** The Flutter version is pinned to 3.47.0 in
both `codemagic.yaml` and `.github/workflows/checks.yml`, so a future Flutter
release cannot turn this into an error without somebody editing those files.

**When it does need dealing with**, when the plugin ships a migrated version or
when a Flutter upgrade makes this an error, there are two options:

1. Move to the migrated `flutter_tts`. One line in `pubspec.yaml`. Preferred.
2. Drop the plugin and talk to the platform directly. The app uses five of its
   calls (`setLanguage`, `setSpeechRate`, `speak`, `stop`,
   `isLanguageAvailable`), and `lib/adapters/speaker.dart` already exists as
   the seam for exactly this. That is roughly 120 lines of Kotlin and Swift
   replacing a 2000 line dependency, and nothing outside that one file changes.

Do not silence the warning. It is the only reminder that this is pending.

## Judging how it feels

**Do not judge performance from a `flutter run` build.** Debug builds are
compiled just in time, with assertions on and no optimisation, and they are
several times slower than what you ship. Rotation is the worst case for it:
the whole tree re-lays-out, and in debug that takes long enough to see.

Check it in release, on the phone:

```sh
flutter run --release
```

That is the same compilation as the store build. If something still stutters
there, it is real and worth fixing. If it only stutters in debug, it is not.

For numbers rather than impressions, use profile mode, which keeps the
tooling attached while compiling ahead of time:

```sh
flutter run --profile
```

## Before you commit anything

```sh
flutter analyze     # must be clean
flutter test        # must be green
dart format .
```

CI runs all three and refuses the build if any fails.

## Looking at the screens without a device

```sh
flutter test tool/screenshots_test.dart
```

Writes PNGs of every screen, light and dark, to `build/screenshots/`. Useful
for checking layout quickly and for starting the store screenshots.

It reports a timeout on every case after writing the file. The files are
correct; read the "wrote ..." lines and ignore the exit code. Devanagari shows
as boxes there because the bundled Roboto has no Devanagari glyphs, and real
phones do.

## Building what the store takes

```sh
flutter build appbundle --release
```

Output lands at `build/app/outputs/bundle/release/app-release.aab`.

Without `android/key.properties` this is signed with the debug key: fine for
your own testing, refused by Play. See CONTRIBUTING.md for making the upload
key.

To install a release build on a phone to check it behaves like the real thing:

```sh
flutter build apk --release
flutter install --release
```

An `.aab` cannot be installed directly on a phone. That is what the `.apk` is
for.
