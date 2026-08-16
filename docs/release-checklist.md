# Release checklist

Copy for the listings is in [store-listing.md](store-listing.md). This is the
order to do things in.

## Every release, before anything else

- [ ] `flutter analyze` is clean
- [ ] `flutter test` passes
- [ ] Bump `version:` in `pubspec.yaml`. The number after `+` is the build
      number and **must** go up every single upload, even for a build that is
      never released. Play and Apple both refuse a repeat.
- [ ] Bump `AppInfo.version` in `lib/core/app_info.dart` to match. A test
      fails if you forget.
- [ ] Write the release notes

---

## Android: the whole thing, in order

Roughly three weeks start to finish, and almost all of that is step 9 waiting.
Read step 9 before you begin so you can line the testers up on day one.

### 1. Publish the website first

The privacy policy has to be live before Play will accept the listing.

- [ ] Push this repo to GitHub as a **public** repo named `housie`
- [ ] **Settings > Pages**, source **Deploy from a branch**, branch `main`,
      folder `/ (root)`, save
- [ ] Wait a couple of minutes, then confirm both of these load:
      - https://stepintothecode.github.io/housie/
      - https://stepintothecode.github.io/housie/privacy/
- [ ] Push the `support` repo changes too, so the in-app support link greets
      people by name instead of showing its generic wording

### 2. Make the upload key

Losing this means you can never update the app and have to publish a new
listing under a new package name. Back it up somewhere that is not this
machine before continuing.

```sh
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
  -keysize 2048 -validity 10000 -alias upload
```

Save it outside the repo, then create `android/key.properties`:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=C:/somewhere/outside/the/repo/upload-keystore.jks
```

- [ ] Keystore made and backed up off this machine
- [ ] `android/key.properties` written
- [ ] Confirm it took effect. This must **not** print the debug key warning:

      ```sh
      flutter build appbundle --release
      ```

### 3. Pay for the account

- [ ] https://play.google.com/console, **$25 once**, personal account
- [ ] Identity verification. This can take a few days on its own, so start it
      now rather than at the end

### 4. Create the app

- [ ] **All apps > Create app**
- [ ] App name: `Housie Bingo Caller: No Ads`
- [ ] Default language English (India) or English (UK)
- [ ] It is an **App**, and it is **Free**. Free cannot be changed to paid
      later
- [ ] Accept the declarations

### 5. Package name

Set the first time you upload a bundle, and **permanent**. Triple check it
reads `com.stepintothecode.housiebingo`.

### 6. Fill in the forms Play blocks release on

**Policy > App content**, work down the list:

- [ ] **Privacy policy**: `https://stepintothecode.github.io/housie/privacy/`
- [ ] **Ads**: **No, my app does not contain ads**
- [ ] **App access**: all functionality available without restriction
- [ ] **Content rating**: fill in the questionnaire. Answer literally. There
      is no gambling here, because the app draws numbers and never touches a
      stake, a score or a prize. It lands at 3+ / Everyone
- [ ] **Target audience**: 13+ is the simplest answer. Choosing "under 13"
      pulls you into the Families programme and a much stricter review
- [ ] **Data safety**: **no data collected, no data shared**. True: no
      analytics, no crash reporting, no ads, and no `INTERNET` permission in
      the manifest. The one permission the app does declare is `VIBRATE`,
      which is not a runtime permission, collects nothing and needs no
      disclosure. A test fails if any other one ever appears
- [ ] **Government apps**: no
- [ ] **Financial features**: none
- [ ] **Health**: no

### 7. The store listing

**Grow > Store presence > Main store listing.** Copy is in
[store-listing.md](store-listing.md).

- [ ] App name, short description, full description
- [ ] **App icon**, 512x512 PNG. Resize `assets/icon/icon.png`
- [ ] **Feature graphic**, 1024x500 PNG. Required, and the listing will not
      submit without it
- [ ] **Phone screenshots**, between 2 and 8, at least 1080px on the short
      edge. Start from `build/screenshots/`, add captions
- [ ] Category **Games > Casual**, tags Casual / Board / Family
- [ ] Contact email

### 8. Upload the build

- [ ] Bump `version:` in `pubspec.yaml`. The number after `+` must increase on
      every upload, forever, even for builds nobody sees
- [ ] Bump `AppInfo.version` to match. A test fails if you forget
- [ ] Build:

      ```sh
      flutter analyze
      flutter test
      flutter build appbundle --release
      ```

- [ ] **Test and release > Testing > Closed testing > Create track**
- [ ] Upload `build/app/outputs/bundle/release/app-release.aab`
- [ ] Upload `build/app/outputs/mapping/release/mapping.txt` so crash reports
      are readable rather than obfuscated
- [ ] Release notes from store-listing.md

### 9. The twelve tester rule, which is the long pole

A personal Play account created recently **cannot publish to production**
until it has run a closed test with **twelve testers who stay opted in for
fourteen continuous days**.

- [ ] Collect twelve Gmail addresses. They must be the Google accounts those
      people actually use on their phones
- [ ] Add them as an email list on the closed track
- [ ] Send every one of them the opt-in link, and confirm each has **installed
      it**. An address on the list that never installs does not count
- [ ] Wait fourteen days. If the count drops below twelve the clock restarts,
      so tell people not to uninstall
- [ ] Keep shipping builds to the track during the wait, since that is what
      the fortnight is for

Line these twelve up before step 3. Everything else here is an afternoon; this
is three weeks.

### 10. Production

- [ ] **Test and release > Production > Create new release**
- [ ] Promote the tested build rather than uploading a fresh one
- [ ] Roll out to 100%, or start at 20% if you would rather watch the crash
      rate first
- [ ] Submit for review. First review is usually a few days and can be longer
      for a brand new account
- [ ] Once live, confirm the listing renders properly on a phone, and that
      `AppInfo.playStoreUrl` actually resolves

## iOS, phase two

Only worth starting once Android is live.

### One time

- [ ] Apple Developer Program, **$99 a year**
- [ ] App Store Connect record. Bundle id `com.stepintothecode.housiebingo`
- [ ] App Store Connect API key, added to Codemagic as an integration named
      `stepintothecode`
- [ ] Put the real Apple ID into `APP_STORE_APPLE_ID` in `codemagic.yaml`

### Shipping it

- [ ] Push. The `ios` workflow in `codemagic.yaml` builds and uploads to
      TestFlight
- [ ] Install from TestFlight and actually play a game on a real iPhone
- [ ] Submit for review

### What review will look at

- **Guideline 4.2, minimum functionality.** A bare random number generator
  gets refused. The board, the voice, the history, undo and the two game modes
  are the answer to that, so make sure the screenshots show them rather than
  just a number on a screen.
- **Donations.** The support link opens the external browser, which is what
  Apple requires. It must never open in a web view, and the app must not
  suggest the tip unlocks anything. The wording on the About page already says
  so and should not be softened.
- **Privacy nutrition labels.** Answer "Data Not Collected". Everything on the
  About page has to stay true.

---

## After a release

- [ ] Tag the commit `v1.0.0`
- [ ] Check the store listing renders properly on a phone
- [ ] Watch the first reviews. In this category the common complaints are the
      screen locking mid-game and the voice not working, both of which have
      settings, so the answer is usually to point at them and then work out
      why they were not obvious
