import 'package:flutter/material.dart';

class VipTier {
  const VipTier({
    required this.level,
    required this.name,
    required this.points,
    required this.price,
    required this.c1,
    required this.c2,
    required this.effect,
  });

  final int level; // 1..9
  final String name;
  final int points; // exp chahiye
  final int price; // coins (server par katte hain)
  final Color c1;
  final Color c2;
  final String effect; // room entry effect ka naam
}
