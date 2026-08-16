import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/core/app_info.dart';

void main() {
  group('support link', () {
    test('points at the support page over https', () {
      final uri = Uri.parse(AppInfo.supportUrl);
      expect(uri.scheme, 'https');
      expect(uri.host, 'stepintothecode.github.io');
      expect(uri.path, '/support/');
    });

    test('names this project, so the page can greet the visitor', () {
      // The value has to match the key in the support repo's projects.js.
      // Changing one without the other quietly drops the greeting.
      expect(
        Uri.parse(AppInfo.supportUrl).queryParameters['from'],
        'housie-app',
      );
    });
  });

  test('the play store link uses the package id this app ships under', () {
    final uri = Uri.parse(AppInfo.playStoreUrl);
    expect(uri.queryParameters['id'], 'com.stepintothecode.housiebingo');
  });

  test('every outbound link is https', () {
    final links = [
      AppInfo.supportUrl,
      AppInfo.playStoreUrl,
      AppInfo.githubUrl,
      AppInfo.youtubeUrl,
    ];
    for (final link in links) {
      expect(Uri.parse(link).scheme, 'https', reason: '$link is not https');
    }
  });
}
