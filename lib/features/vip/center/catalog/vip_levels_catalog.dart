import 'package:flutter/material.dart';

import '../models/vip_level.dart';

/// 9 tiers. Points aur price v15 VipCatalog aur server buyVip se same.
class VipLevelsCatalog {
  const VipLevelsCatalog._();

  static const count = 9;

  static const all = <VipLevel>[
    VipLevel(level: 1, name: 'Hawk', creature: Creature.hawk, points: 1000, price: 500,
        c1: Color(0xFFCFD8DC), c2: Color(0xFF607D8B), accent: Color(0xFFFFFFFF)),
    VipLevel(level: 2, name: 'Fox', creature: Creature.fox, points: 5000, price: 1500,
        c1: Color(0xFFD7A77A), c2: Color(0xFF6D3B1F), accent: Color(0xFFFFE0B2)),
    VipLevel(level: 3, name: 'Owl', creature: Creature.owl, points: 20000, price: 3000,
        c1: Color(0xFFFFE082), c2: Color(0xFF8A5A00), accent: Color(0xFFFFF8E1)),
    VipLevel(level: 4, name: 'Cobra', creature: Creature.cobra, points: 60000, price: 6000,
        c1: Color(0xFFA5D6A7), c2: Color(0xFF1B5E20), accent: Color(0xFFC8E6C9)),
    VipLevel(level: 5, name: 'Shark', creature: Creature.shark, points: 150000, price: 12000,
        c1: Color(0xFF90CAF9), c2: Color(0xFF0D2F6B), accent: Color(0xFF18FFFF)),
    VipLevel(level: 6, name: 'Scorpion', creature: Creature.scorpion, points: 400000, price: 25000,
        c1: Color(0xFFEF9A9A), c2: Color(0xFF6B0F1A), accent: Color(0xFFFF5252)),
    VipLevel(level: 7, name: 'Pegasus', creature: Creature.pegasus, points: 900000, price: 50000,
        c1: Color(0xFFCE93D8), c2: Color(0xFF3E1A5C), accent: Color(0xFFE040FB)),
    VipLevel(level: 8, name: 'Kraken', creature: Creature.kraken, points: 1800000, price: 90000,
        c1: Color(0xFFB2EBF2), c2: Color(0xFF004D5C), accent: Color(0xFF69F0AE)),
    VipLevel(level: 9, name: 'Griffin', creature: Creature.griffin, points: 3500000, price: 150000,
        c1: Color(0xFFFFF176), c2: Color(0xFF4A148C), accent: Color(0xFFFFD700)),
  ];

  static VipLevel byLevel(int level) => all[level.clamp(1, count) - 1];
}
