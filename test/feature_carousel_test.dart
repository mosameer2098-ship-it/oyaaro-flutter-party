import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/features/home/data/home_content.dart';
import 'package:oyaaro_party/features/home/widgets/feature_carousel.dart';

void main() {
  testWidgets('shows three cards at once on a phone-width screen',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeatureCarousel(items: sampleFeatures),
        ),
      ),
    );

    expect(tester.getTopLeft(find.text('Ranking')).dx, lessThan(390));
    expect(tester.getTopLeft(find.text('CP')).dx, lessThan(390));
    expect(tester.getTopLeft(find.text('Family')).dx, lessThan(390));
    expect(tester.getTopLeft(find.text('Stars')).dx, greaterThan(390));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('auto-slides horizontally toward the remaining cards',
      (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FeatureCarousel(
            items: sampleFeatures,
            interval: Duration(seconds: 2),
          ),
        ),
      ),
    );

    final before = tester.getTopLeft(find.text('CP')).dx;
    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 700));
    final after = tester.getTopLeft(find.text('CP')).dx;

    expect(after, lessThan(before));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
