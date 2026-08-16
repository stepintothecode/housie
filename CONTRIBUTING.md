# Working on Housie Bingo Caller: No Ads

## What to install

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.47.0 or later,
  which brings Dart 3.13
- JDK 17 or later, for Android builds
- Android SDK with platform 36 and build-tools 36, either through Android
  Studio or the command line tools
- Xcode, only if you are building for iOS, which means only on macOS

`flutter doctor` tells you what is missing.

## Running it

```sh
flutter pub get
flutter run
```

## Tests

```sh
flutter test           # all of them
flutter analyze        # must be clean before anything is merged
```

Both run in CI on every branch, and a release build will not start until they
pass.

## How the folders are arranged

```
lib/
  core/          pure Dart. No Flutter import, no platform call, no network.
  adapters/      one file per external thing, interface and implementation.
  app/           everything that needs Flutter.
    theme/       colour and spacing tokens, and the two ThemeData builders.
    screens/     one file per screen.
    widgets/     the pieces the screens are built from.
  main.dart      builds the adapters and hands them to the app.

test/            mirrors lib/, with `_tests` on each folder.
  support/       fakes. Not tests, and the runner does not pick them up.

tool/            generates assets/icon/. Not shipped in the app.
docs/            store copy and the release checklist.
privacy/         published to GitHub Pages.
```

### core/ is the important boundary

Everything in `lib/core/` runs anywhere: a test, a CLI, a server. It has no
`package:flutter` import at all. Game rules, the number words, the settings
value and the board layout all live there, which is why they are covered by
plain unit tests with no widget pumping.

If you find yourself wanting `BuildContext` in `core/`, the decision belongs
somewhere else.

### Anything external sits behind an adapter

`lib/adapters/` holds four: `Speaker`, `Store`, `Device` and `LinkOpener`.
Each is an interface plus the real implementation. The fake lives in
`test/support/`. Swapping a package means editing one file.

### Two deviations from the usual conventions

Both are forced by the toolchain, and both are deliberate:

- **Dart files are `snake_case`, not `dash-case`.** The `file_names` lint and
  the whole Dart ecosystem require it. Everything that is not Dart keeps
  dashes.
- **Test files end `_test.dart`, not `-tests.dart`.** The Dart test runner
  globs on that suffix and will not find them otherwise. The folder mirroring
  is unaffected: `lib/core/caller_state.dart` is tested by
  `test/core_tests/caller_state_test.dart`.

## Generated files

`assets/icon/*.png` is drawn by `tool/make_icons.dart`, not by hand. After
changing the artwork:

```sh
dart run tool/make_icons.dart
dart run flutter_launcher_icons
dart run flutter_native_splash:create
```

`test/repo_tests/icons_test.dart` fails if the committed PNGs no longer match
what the generator produces.

## The upload key

Android release builds are signed with an upload key that is not in the repo
and must never be. Losing it means you cannot update the app and have to
publish a new listing under a new package name. Back it up somewhere that is
not this machine.

Make one:

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Put it somewhere outside the repo, then create `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/path/outside/the/repo/upload-keystore.jks
```

That file is gitignored, along with `*.jks` and `*.keystore`, so a slip does
not publish it. If `key.properties` is absent the release build still works,
signs with the debug key and prints a warning. Play refuses the result, which
is the intended outcome.

## Conventions

- Two names, and only two, both defined in `lib/core/app_info.dart`:
  - `AppInfo.name`, **Housie Bingo Caller: No Ads**, for both store listings,
    the about screen and the website.
  - `AppInfo.shortName`, **Housie Caller**, for the launcher label and the app
    bar, because Android truncates a home screen label at about thirteen
    characters.

  `test/repo_tests/app_name_test.dart` fails if the Android manifest, the iOS
  plist or the store listing stops agreeing with those two constants. Never
  type either name into a Dart file; reference the constant.
- Comments say why, not what. If a comment restates the line under it, delete
  it.
- No em dashes or en dashes in anything written here or in the app.
- A value that carries a rule is immutable and returns a new instance.
  `CallerState` is the example to copy.
- When something cannot be parsed, return `null` and let the caller decide.
  Never guess a plausible value.
- When you fix a bug, add the test that would have caught it and note in one
  line what used to happen.

## Releasing

See [docs/release-checklist.md](docs/release-checklist.md).
