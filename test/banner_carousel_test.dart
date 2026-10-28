import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/features/home/data/home_content.dart';
import 'package:oyaaro_party/features/home/widgets/banner_carousel.dart';

void main() {
  testWidgets('auto-advances through pages and wraps back to the first',
      (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(
            banners: sampleBanners.take(3).toList(),
            interval: const Duration(seconds: 2),
            onPageChanged: pages.add,
          ),
        ),
      ),
    );
    expect(pages, isEmpty);

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pages, contains(1));

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pages, contains(2));

    await tester.pump(const Duration(seconds: 2));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pages.last, 0);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('manual swipe is reported and the timer restarts afterwards',
      (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(
            banners: sampleBanners.take(3).toList(),
            interval: const Duration(seconds: 4),
            onPageChanged: pages.add,
          ),
        ),
      ),
    );

    await tester.drag(find.byType(PageView), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(pages, contains(1));

    final before = pages.length;
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));
    expect(pages.length, greaterThan(before));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('does not auto-advance when there is a single banner',
      (tester) async {
    final pages = <int>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BannerCarousel(
            banners: sampleBanners.take(1).toList(),
            interval: const Duration(seconds: 1),
            onPageChanged: pages.add,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(seconds: 5));
    expect(pages, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
