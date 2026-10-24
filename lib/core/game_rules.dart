import 'package:flutter/material.dart';

// slot: 3 reel | wheel: prize wheel (1 ya 10 draw) | crash: target | fruit: 12 cell grid
// bagSend: lucky bag bhejna (users claim karte hain)
enum GameKind { slot, wheel, crash, fruit, bagSend }

class GameSpec {
  final String id;
  final String name;
  final String subtitle;
  final GameKind kind;
  final IconData icon;
  final Color c1;
  final Color c2;
  final List<String> symbols;
  final Map<String, int> multipliers;
  final List<int> prizes;
  const GameSpec({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.kind,
    required this.icon,
    required this.c1,
    required this.c2,
    this.symbols = const [],
    this.multipliers = const {},
    this.prizes = const [],
  });
}

class GameOutcome {
  final int payout; // Diamond mein jeet (0 = haar)
  final String text;
  const GameOutcome(this.payout, this.text);
}
