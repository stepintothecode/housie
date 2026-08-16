import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/widgets/secret_tap.dart';

void main() {
  late int unlocked;

  Widget wrap({int taps = 7, Duration window = const Duration(seconds: 3)}) {
    unlocked = 0;
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SecretTap(
            taps: taps,
            window: window,
            onUnlocked: () => unlocked++,
            child: const SizedBox(width: 60, height: 60),
          ),
        ),
      ),
    );
  }

  testWidgets('stays shut until the last tap', (tester) async {
    await tester.pumpWidget(wrap());

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byType(SecretTap));
      await tester.pump();
      expect(unlocked, 0, reason: 'opened on tap ${i + 1} of 7');
    }

    await tester.tap(find.byType(SecretTap));
    await tester.pump();

    expect(unlocked, 1);
  });

  testWidgets('starts over, so it can be found twice', (tester) async {
    await tester.pumpWidget(wrap());

    for (var round = 0; round < 2; round++) {
      for (var i = 0; i < 7; i++) {
        await tester.tap(find.byType(SecretTap));
        await tester.pump();
      }
    }

    expect(unlocked, 2);
  });

  testWidgets('forgets taps that were too far apart', (tester) async {
    // A short window, so the gap can be waited out inside a test.
    await tester.pumpWidget(wrap(window: const Duration(milliseconds: 40)));

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byType(SecretTap));
      await tester.pump();
    }
    // The count is kept against the wall clock rather than a timer, so this
    // has to be a real pause rather than a pumped one.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 120)),
    );

    await tester.tap(find.byType(SecretTap));
    await tester.pump();

    expect(unlocked, 0, reason: 'the stale run should not have counted');
  });

  testWidgets('gives nothing away to a screen reader', (tester) async {
    await tester.pumpWidget(wrap());

    // No label and no tap action announced. Somebody exploring the screen
    // should not trip over it, which is the point of a hidden thing.
    final semantics = tester.getSemantics(find.byType(SecretTap));
    expect(semantics.label, isEmpty);
    expect(
      semantics.getSemanticsData().hasAction(SemanticsAction.tap),
      isFalse,
    );
  });
}
