import 'package:flutter/material.dart';

class VipTier {
  final int level; // 1..9
  final String name;
  final int points; // ye points (exp) chahiye lock khulne ke liye
  final int price; // coins
  final Color c1;
  final Color c2;
  final String entryEffect;
  const VipTier({
    required this.level,
    required this.name,
    required this.points,
    required this.price,
    required this.c1,
    required this.c2,
    required this.entryEffect,
  });
}

class Vip {
  static const all = <VipTier>[
    VipTier(level: 1, name: 'Silver', points: 1000, price: 500,
        c1: Color(0xFFCFD8DC), c2: Color(0xFF78909C), entryEffect: 'Silver Glow'),
    VipTier(level: 2, name: 'Bronze', points: 5000, price: 1500,
        c1: Color(0xFFD7A77A), c2: Color(0xFF8D5524), entryEffect: 'Bronze Sparks'),
    VipTier(level: 3, name: 'Gold', points: 20000, price: 3000,
        c1: Color(0xFFFFE082), c2: Color(0xFFFF8F00), entryEffect: 'Gold Rain'),
    VipTier(level: 4, name: 'Emerald', points: 60000, price: 6000,
        c1: Color(0xFFA5D6A7), c2: Color(0xFF2E7D32), entryEffect: 'Emerald Wave'),
    VipTier(level: 5, name: 'Sapphire', points: 150000, price: 12000,
        c1: Color(0xFF90CAF9), c2: Color(0xFF0D47A1), entryEffect: 'Sapphire Pulse'),
    VipTier(level: 6, name: 'Ruby', points: 400000, price: 25000,
        c1: Color(0xFFEF9A9A), c2: Color(0xFFB71C1C), entryEffect: 'Ruby Burst'),
    VipTier(level: 7, name: 'Amethyst', points: 900000, price: 50000,
        c1: Color(0xFFCE93D8), c2: Color(0xFF6A1B9A), entryEffect: 'Amethyst Halo'),
    VipTier(level: 8, name: 'Diamond', points: 1800000, price: 90000,
        c1: Color(0xFFE1F5FE), c2: Color(0xFF4FC3F7), entryEffect: 'Diamond Flash'),
    VipTier(level: 9, name: 'Royal', points: 3500000, price: 150000,
        c1: Color(0xFFFFF176), c2: Color(0xFF4A148C), entryEffect: 'Royal Crown'),
  ];

  static VipTier byLevel(int level) => all[level - 1];
}
