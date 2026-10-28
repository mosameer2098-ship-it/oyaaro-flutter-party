import 'package:flutter/material.dart';

enum HomeTab { mine, popular }

enum RoomCategory {
  popular('Popular'),
  game('Game'),
  videoMusic('Video/Music');

  const RoomCategory(this.label);

  final String label;
}

@immutable
class Room {
  const Room({
    required this.id,
    required this.name,
    required this.hostName,
    required this.listeners,
    required this.category,
    required this.color,
    this.language,
    this.isLive = false,
  });

  final String id;
  final String name;
  final String hostName;
  final int listeners;
  final RoomCategory category;
  final Color color;
  final String? language;

  /// Live state. Sample rooms set this for layout only; it must come from the
  /// backend once rooms are connected.
  final bool isLive;
}

@immutable
class HomeBanner {
  const HomeBanner({
    required this.title,
    required this.subtitle,
    required this.color,
    this.icon = Icons.graphic_eq_rounded,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;
}

@immutable
class FeatureItem {
  const FeatureItem({
    required this.label,
    required this.caption,
    required this.icon,
    required this.color,
  });

  final String label;
  final String caption;
  final IconData icon;
  final Color color;
}

/// Rooms in [category], most listeners first. Returns a new list and never
/// modifies [rooms].
List<Room> filterRooms(Iterable<Room> rooms, RoomCategory category) {
  final result = rooms.where((room) => room.category == category).toList();
  result.sort((a, b) => b.listeners.compareTo(a.listeners));
  return result;
}
