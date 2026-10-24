import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../lib/features/avatar_frames/avatar_frames.dart';

void main() {
  testWidgets('animated frame render hota hai aur dispose safe hai', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Center(
          child: AvatarWithFrame(
            frame: FrameCatalog.byId('role_superadmin'),
            radius: 30,
            child: const ColoredBox(color: Colors.purple),
          ),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(AnimatedAvatarFrame), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('frame null ho to plain avatar', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: AvatarWithFrame(frame: null, radius: 20, child: const ColoredBox(color: Colors.blue)),
      ),
    ));
    expect(find.byType(AnimatedAvatarFrame), findsNothing);
  });
}
