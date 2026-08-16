import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/screens/support_screen.dart';
import 'package:housie_bingo_caller/app/theme/app_theme.dart';
import 'package:housie_bingo_caller/core/app_info.dart';

import '../../support/fake_link_opener.dart';

void main() {
  late FakeLinkOpener links;

  /// A tall surface, so the whole page is laid out at once. A ListView never
  /// builds what is below the fold, and the default 800x600 test window cuts
  /// off everything under the support button.
  Future<void> pumpScreen(
    WidgetTester tester, {
    bool browserWorks = true,
  }) async {
    tester.view.physicalSize = const Size(400, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // There is no clipboard behind a test binding, and an unanswered platform
    // call throws. Answering it lets the copy path run as it does on a phone.
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(
      () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
    );

    links = FakeLinkOpener(succeeds: browserWorks);
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: SupportScreen(links: links),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'the support button opens the support page, tagged with this app',
    (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.text('Support this app'));
      await tester.pumpAndSettle();

      expect(links.opened, [AppInfo.supportUrl]);
      expect(links.opened.single, contains('from=housie-app'));
    },
  );

  testWidgets('a phone with no browser gets the link rather than nothing', (
    tester,
  ) async {
    await pumpScreen(tester, browserWorks: false);

    await tester.tap(find.text('Support this app'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Link copied'), findsOneWidget);
  });

  testWidgets('states the promises the support ask rests on', (tester) async {
    await pumpScreen(tester);

    expect(find.text('Free, and staying free'), findsOneWidget);
    expect(find.text('Works with no internet at all'), findsOneWidget);
    expect(find.text('Collects nothing, sends nothing'), findsOneWidget);
    expect(find.textContaining('buys no features'), findsOneWidget);
  });

  testWidgets('privacy is spelled out in full, not just claimed', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Privacy'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('collects nothing and sends nothing'),
      findsOneWidget,
    );
  });

  testWidgets('the version on screen is the one this build reports', (
    tester,
  ) async {
    await pumpScreen(tester);
    expect(find.text('${AppInfo.name} ${AppInfo.version}'), findsOneWidget);
  });
}
