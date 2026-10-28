import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/app/oyaaro_app.dart';

void main() {
  testWidgets('bottom navigation has exactly Home, Message and Profile',
      (tester) async {
    await tester.pumpWidget(const OyaaroApp());

    final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
    final labels = bar.destinations
        .map((destination) => (destination as NavigationDestination).label)
        .toList();
    expect(labels, ['Home', 'Message', 'Profile']);
    expect(find.text('Rooms'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Message and Profile tabs switch to their pages', (tester) async {
    await tester.pumpWidget(const OyaaroApp());

    await tester.tap(find.text('Message'));
    await tester.pumpAndSettle();
    expect(find.text('Conversations arrive in a later stage.'), findsOneWidget);

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(
      find.text('Profile editing arrives in a later stage.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('home-tab-popular')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
