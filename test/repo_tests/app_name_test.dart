import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/app_info.dart';

/// The name lives in four places the Dart code cannot reach: the Android
/// manifest, the iOS plist twice, and the store listing. These fail if any of
/// them drifts away from AppInfo.
void main() {
  test('the full name mentions No Ads and fits a store title', () {
    expect(AppInfo.name, contains('No Ads'));
    // Play allows 30 characters and Apple allows 30 for the app name.
    expect(
      AppInfo.name.length,
      lessThanOrEqualTo(30),
      reason: '"${AppInfo.name}" is ${AppInfo.name.length} characters',
    );
  });

  test('the launcher label is short enough not to be truncated', () {
    // Android home screens cut a label at roughly thirteen characters.
    expect(
      AppInfo.shortName.length,
      lessThanOrEqualTo(13),
      reason: '"${AppInfo.shortName}" will show as truncated under the icon',
    );
  });

  test('the Android launcher label is AppInfo.shortName', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:label="${AppInfo.shortName}"'));
  });

  test('the iOS display name is AppInfo.shortName', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    for (final key in ['CFBundleDisplayName', 'CFBundleName']) {
      final match = RegExp(
        '<key>$key</key>\\s*<string>([^<]*)</string>',
        multiLine: true,
      ).firstMatch(plist);
      expect(match, isNotNull, reason: '$key is missing from Info.plist');
      expect(match!.group(1), AppInfo.shortName, reason: '$key is wrong');
    }
  });

  test('the store listing leads with the full name', () {
    final listing = File('docs/store-listing.md').readAsStringSync();
    expect(
      listing,
      contains(AppInfo.name),
      reason: 'docs/store-listing.md still shows an older title',
    );
  });
}
