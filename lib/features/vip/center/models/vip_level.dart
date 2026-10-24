import 'package:flutter/material.dart';

/// VIP tier ka creature (original emblem, koi copied artwork nahi)
enum Creature { hawk, fox, owl, cobra, shark, scorpion, pegasus, kraken, griffin }

class VipLevel {
  const VipLevel({
    required this.level,
    required this.name,
    required this.creature,
    required this.points,
    required this.price,
    required this.c1,
    required this.c2,
    required this.accent,
  });

  final int level; // 1..9
  final String name;
  final Creature creature;
  final int points; // exp chahiye (server buyVip se same)
  final int price; // coins (server par katte hain)
  final Color c1;
  final Color c2;
  final Color accent;

  String get title => 'VIP $level  $name';
}
