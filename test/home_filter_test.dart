import 'package:flutter_test/flutter_test.dart';
import 'package:oyaaro_party/features/home/data/home_content.dart';
import 'package:oyaaro_party/features/home/models/home_models.dart';

void main() {
  group('filterRooms', () {
    test('returns only rooms in the requested category', () {
      for (final category in RoomCategory.values) {
        final rooms = filterRooms(sampleRooms, category);
        expect(rooms, isNotEmpty, reason: '${category.label} has no rooms');
        expect(
          rooms.every((room) => room.category == category),
          isTrue,
          reason: '${category.label} contains another category',
        );
      }
    });

    test('orders rooms by listeners, highest first', () {
      final rooms = filterRooms(sampleRooms, RoomCategory.popular);
      final counts = rooms.map((room) => room.listeners).toList();
      final sorted = [...counts]..sort((a, b) => b.compareTo(a));
      expect(counts, orderedEquals(sorted));
    });

    test('does not modify the source list', () {
      final before = sampleRooms.map((room) => room.id).toList();
      filterRooms(sampleRooms, RoomCategory.game);
      expect(sampleRooms.map((room) => room.id).toList(), before);
    });

    test('every sample room belongs to exactly one category', () {
      final total = RoomCategory.values
          .map((category) => filterRooms(sampleRooms, category).length)
          .reduce((a, b) => a + b);
      expect(total, sampleRooms.length);
    });
  });

  test('banner and feature content match the dashboard spec', () {
    expect(sampleBanners.length, 10);
    expect(sampleFeatures.length, 5);
    expect(
      sampleFeatures.map((item) => item.label).toList(),
      ['Ranking', 'CP', 'Family', 'Party', 'Stars'],
    );
  });
}
