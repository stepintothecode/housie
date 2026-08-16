# Housie Bingo Caller: No Ads

A number caller for Housie, Tambola and Bingo. Tap once, get a number, and
everyone can see what has already come up.

**https://stepintothecode.github.io/housie/**

No ads, no tracking, no account, no paid version. The Android build is not
granted the internet permission at all, so it could not load an advert even if
it wanted to.

The launcher icon says **Housie Caller**, because Android cuts a home screen
label off after about thirteen characters.

- Draws 1 to 90 for Housie and Tambola, or 1 to 75 for Bingo
- Never repeats a number
- Reads each number out loud, in English or Hindi
- Shows the whole board, so players can check without stopping the game
- Call history and undo
- Holds the screen awake while a game is running
- Picks the game back up if the app closes

## Running it

You need the [Flutter SDK](https://docs.flutter.dev/get-started/install)
(3.47.0 or later) and a phone or emulator.

```sh
flutter pub get
flutter run
```

If `flutter` is not a recognised command, or you are not sure how to get the
app onto a phone, start with [docs/developing.md](docs/developing.md).

## Building a release

```sh
flutter build appbundle --release    # Android, for Play
flutter build ipa --release          # iOS, needs macOS
```

Android release builds need an upload key. Without one they fall back to the
debug key, which installs fine for testing and is refused by Play. See
[CONTRIBUTING.md](CONTRIBUTING.md).

iOS binaries cannot be built on Windows. [codemagic.yaml](codemagic.yaml)
builds them in the cloud instead.

## Repo

```
lib/          the app
tool/         generates the launcher artwork, and renders screenshots
test/         mirrors lib/
docs/         how to develop it, store copy, release checklist
privacy/      the published privacy policy
index.html    the published landing page
```

- [docs/features.md](docs/features.md) - every feature, in full
- [docs/developing.md](docs/developing.md) - installing the tools, getting it
  onto a phone, the hot reload loop
- [docs/release-checklist.md](docs/release-checklist.md) - every step to get
  it onto the Play Store
- [docs/store-listing.md](docs/store-listing.md) - the listing copy

Layout and conventions are in [CONTRIBUTING.md](CONTRIBUTING.md).
