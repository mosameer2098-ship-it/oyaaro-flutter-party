import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/app/oyaaro_app.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const OyaaroApp());
    await tester.pump();
  }

  testWidgets('Popular is selected by default and lists popular rooms',
      (tester) async {
    await pumpHome(tester);

    expect(find.text('Midnight Vibes'), findsOneWidget);
    expect(find.text('Music Addicts'), findsNothing);
    expect(find.text('Game Night'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Game filter shows only game rooms', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('category-game')));
    await tester.pumpAndSettle();

    expect(find.text('Game Night'), findsOneWidget);
    expect(find.text('Midnight Vibes'), findsNothing);
    expect(find.text('Music Addicts'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Video/Music filter shows only music rooms', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('category-videoMusic')));
    await tester.pumpAndSettle();

    expect(find.text('Music Addicts'), findsOneWidget);
    expect(find.text('Midnight Vibes'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Mine tab shows an empty state instead of popular rooms',
      (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const ValueKey('home-tab-mine')));
    await tester.pumpAndSettle();

    expect(
      find.text('Rooms you follow or join will appear here.'),
      findsOneWidget,
    );
    expect(find.text('Midnight Vibes'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('home-tab-popular')));
    await tester.pumpAndSettle();
    expect(find.text('Midnight Vibes'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('tapping a room card opens its room page', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.text('Midnight Vibes'));
    await tester.pumpAndSettle();

    expect(
      find.text('Joining voice rooms is not available yet. '
          'Live audio arrives with the LiveKit stage.'),
      findsOneWidget,
    );
    expect(find.text('Hosted by Aanya'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
