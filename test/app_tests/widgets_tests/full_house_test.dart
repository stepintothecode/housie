import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:housie_bingo_caller/app/theme/app_theme.dart';
import 'package:housie_bingo_caller/app/widgets/full_house.dart';

void main() {
  Widget wrap() => MaterialApp(
    theme: AppTheme.dark(),
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => FullHouse.celebrate(context),
            child: const Text('go'),
          ),
        ),
      ),
    ),
  );

  testWidgets('shouts, and rains balls', (tester) async {
    await tester.pumpWidget(wrap());

    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('FULL HOUSE!'), findsOneWidget);
    expect(find.textContaining('seventh tap'), findsOneWidget);
  });

  testWidgets('clears itself away without being asked', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // Nobody should be stuck looking at it, so it leaves on its own.
    expect(find.text('FULL HOUSE!'), findsNothing);
    expect(find.text('go'), findsOneWidget);
  });

  testWidgets('a tap skips it', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('FULL HOUSE!'), findsOneWidget);

    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(find.text('FULL HOUSE!'), findsNothing);
  });

  testWidgets('leaves nothing running behind it', (tester) async {
    await tester.pumpWidget(wrap());
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();

    // A leaked ticker fails the test outright, which is the assertion. This
    // just confirms the app underneath is usable again.
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('FULL HOUSE!'), findsOneWidget);
    await tester.pumpAndSettle();
  });
}
