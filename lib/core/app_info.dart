/// Fixed facts about this build, in one place.
///
/// [version] is checked against pubspec.yaml by a test, so the two cannot
/// drift apart without the suite failing.
abstract final class AppInfo {
  /// The full name: both store listings, the about screen, the website.
  ///
  /// "No Ads" is part of the name rather than only the description because it
  /// is the reason to pick this over the ad-filled callers it competes with,
  /// and a store title is the one line everybody reads.
  static const name = 'Housie Bingo Caller: No Ads';

  /// What fits under a launcher icon and in the app bar. Android truncates a
  /// home screen label at roughly thirteen characters, so the full name would
  /// show up as "Housie Bing...".
  ///
  /// A test checks the Android manifest and the iOS plist still say this.
  static const shortName = 'Housie Caller';

  /// Shown under the name on the about screen, and the name the stores list
  /// the app under.
  static const publisher = 'Step Into The Code';

  /// The launcher artwork, reused on the about screen.
  static const iconAsset = 'assets/icon/icon.png';

  static const version = '1.0.0';

  /// The support page. Payment providers change behind this address; the
  /// address itself does not, so a published build never goes stale.
  ///
  /// `from` tells that page which project sent the visitor. It is read in the
  /// page and thrown away.
  static const supportUrl =
      'https://stepintothecode.github.io/support/?from=housie-app';

  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.stepintothecode.housiebingo';

  static const githubUrl = 'https://github.com/stepintothecode/housie';
  static const youtubeUrl = 'https://www.youtube.com/@StepIntoTheCode';
}
