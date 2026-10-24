import 'package:flutter/material.dart';

enum ThemeKind { room, couple }

/// Room background theme ya couple theme (CP profile + couple frame).
class ThemeSpec {
  const ThemeSpec({
    required this.id,
    required this.name,
    required this.kind,
    required this.price,
    required this.colors,
  });

  final String id; // room_01.. | couple_01..
  final String name;
  final ThemeKind kind;
  final int price; // coins, server par katte hain
  final List<Color> colors;
}
