import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/main.dart';

void main() {
  testWidgets('Oyaaro opens Home and switches navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OyaaroApp());

    expect(find.text('Oyaaro'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);

    await tester.tap(find.text('Messages').last);
    await tester.pumpAndSettle();
    expect(find.text('Your conversations will appear here.'), findsOneWidget);

    await tester.tap(find.text('Rooms').last);
    await tester.pumpAndSettle();
    expect(find.text('Voice Rooms'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('Your Profile'), findsOneWidget);
  });
}
