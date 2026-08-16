import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/app_info.dart';

/// The version shown on the support screen is a constant, because reading it
/// at runtime would mean another dependency. This is what stops it drifting
/// away from the version actually shipped.
void main() {
  test('AppInfo.version matches the version in pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([0-9]+\.[0-9]+\.[0-9]+)\+([0-9]+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(
      match,
      isNotNull,
      reason: 'pubspec.yaml needs a version like 1.0.0+1',
    );
    expect(
      match!.group(1),
      AppInfo.version,
      reason: 'bump AppInfo.version in lib/core/app_info.dart to match pubspec.yaml',
    );
  });

  test('the package name in pubspec.yaml is the one the imports use', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('name: housie_bingo_caller'));
  });
}
