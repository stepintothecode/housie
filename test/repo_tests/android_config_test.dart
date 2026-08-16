import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/theme/tokens.dart';

/// The Android configuration is invisible from Dart, so nothing else would
/// notice any of this going missing until someone tried the app on a phone.
void main() {
  final manifest = File('android/app/src/main/AndroidManifest.xml')
      .readAsStringSync();

  group('permissions', () {
    test('asks for VIBRATE, or the haptics setting does nothing', () {
      // Without this the vibration switch appears to work, no vibration ever
      // happens, and nothing in the logs says why.
      expect(
        manifest,
        contains('android.permission.VIBRATE'),
        reason: 'the vibration motor cannot be driven without this',
      );
    });

    test('does not ask for INTERNET', () {
      // The store listing, the about screen and the privacy policy all say
      // the app cannot reach the network. This is what makes that true.
      expect(
        manifest,
        isNot(contains('android.permission.INTERNET')),
        reason: 'the app claims in three places that it has no network access',
      );
    });

    test('asks for nothing else', () {
      final asked = RegExp(r'android\.permission\.([A-Z_]+)')
          .allMatches(manifest)
          .map((m) => m.group(1))
          .toSet();
      expect(asked, {
        'VIBRATE',
      }, reason: 'a new permission appeared; every one of them needs a reason');
    });
  });

  test('lets the screen rotate', () {
    // A fixed screenOrientation here would override the in-app rotate button.
    expect(manifest, isNot(contains('android:screenOrientation')));
  });

  group('the window background matches the app', () {
    // Android paints this behind the app while it re-lays-out, which is what
    // is on screen mid-rotation. A mismatch shows as a flash of the wrong
    // colour, so the two have to be kept in step by hand.
    String colourIn(String path) {
      final xml = File(path).readAsStringSync();
      final match = RegExp(
        r'<color name="app_background">#([0-9A-Fa-f]{6})</color>',
      ).firstMatch(xml);
      expect(match, isNotNull, reason: 'app_background is missing from $path');
      return match!.group(1)!.toUpperCase();
    }

    String hexOf(Color colour) => (colour.toARGB32() & 0xFFFFFF)
        .toRadixString(16)
        .padLeft(6, '0')
        .toUpperCase();

    test('light', () {
      expect(
        colourIn('android/app/src/main/res/values/app_colors.xml'),
        hexOf(Palette.light.background),
      );
    });

    test('dark', () {
      expect(
        colourIn('android/app/src/main/res/values-night/app_colors.xml'),
        hexOf(Palette.dark.background),
      );
    });
  });
}
