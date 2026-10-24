import 'package:flutter/material.dart';
import 'package:oyaroo/core/game_rules.dart';

// Room ke games. Naam aur artwork apne hain.
class GameCatalog {
  static const lucky = <GameSpec>[
    GameSpec(id: 'lucky_seven_pro', name: 'Lucky Seven Pro', subtitle: 'Teen 7 par sabse bada',
        kind: GameKind.slot, icon: Icons.casino, c1: Color(0xFFFFB300), c2: Color(0xFFD32F2F),
        symbols: ['7', 'BAR', 'CHERRY', 'BELL', 'LEMON'],
        multipliers: {'7': 50, 'BAR': 20, 'CHERRY': 10, 'BELL': 5, 'LEMON': 3}),
    GameSpec(id: 'baby_fruits', name: 'Baby Fruits', subtitle: 'Teen same fruit par jackpot',
        kind: GameKind.slot, icon: Icons.emoji_nature, c1: Color(0xFF66BB6A), c2: Color(0xFF1565C0),
        symbols: ['APPLE', 'GRAPE', 'MANGO', 'BANANA'],
        multipliers: {'APPLE': 8, 'GRAPE': 6, 'MANGO': 10, 'BANANA': 4}),
    GameSpec(id: 'lucky_fruit', name: 'Lucky Fruit', subtitle: 'Orange aur cherry sabse achhe',
        kind: GameKind.slot, icon: Icons.eco, c1: Color(0xFFFF7043), c2: Color(0xFF2E7D32),
        symbols: ['ORANGE', 'CHERRY', 'GRAPE'],
        multipliers: {'ORANGE': 10, 'CHERRY': 20, 'GRAPE': 6}),
    GameSpec(id: 'fruit_garden', name: 'Fruit Garden', subtitle: '12 cell mein se ek chuno',
        kind: GameKind.fruit, icon: Icons.grid_view, c1: Color(0xFF43A047), c2: Color(0xFFF9A825)),
    GameSpec(id: 'crash_rocket', name: 'Crash Rocket', subtitle: 'Target se pehle rocket phate to jeetein',
        kind: GameKind.crash, icon: Icons.rocket_launch, c1: Color(0xFF42A5F5), c2: Color(0xFF0D47A1)),
    GameSpec(id: 'jester_star', name: 'Jester Star', subtitle: 'Star par x25 tak',
        kind: GameKind.slot, icon: Icons.theater_comedy, c1: Color(0xFFFF4081), c2: Color(0xFF7B1FA2),
        symbols: ['HAT', 'BALL', 'STAR'], multipliers: {'HAT': 15, 'BALL': 10, 'STAR': 25}),
    GameSpec(id: 'super_gems', name: 'Super Gems', subtitle: 'Diamond teen par x50',
        kind: GameKind.slot, icon: Icons.diamond, c1: Color(0xFF26C6DA), c2: Color(0xFF283593),
        symbols: ['RUBY', 'EMERALD', 'SAPPHIRE', 'DIAMOND'],
        multipliers: {'RUBY': 5, 'EMERALD': 10, 'SAPPHIRE': 20, 'DIAMOND': 50}),
    GameSpec(id: 'classic_777', name: 'Classic 777', subtitle: 'Teen 7 par x100',
        kind: GameKind.slot, icon: Icons.casino, c1: Color(0xFFE53935), c2: Color(0xFFFFD600),
        symbols: ['7', 'BAR', 'BELL'], multipliers: {'7': 100, 'BAR': 25, 'BELL': 8}),
    GameSpec(id: 'mega_jackpot', name: 'Mega Jackpot', subtitle: 'JACKPOT teen par x200',
        kind: GameKind.slot, icon: Icons.stars, c1: Color(0xFF8E24AA), c2: Color(0xFFFFC107),
        symbols: ['STAR', 'CROWN', 'JACKPOT'],
        multipliers: {'STAR': 10, 'CROWN': 30, 'JACKPOT': 200}),
    GameSpec(id: 'lucky_reels', name: 'Lucky Reels', subtitle: 'Chaar symbol, sabse achha LUCKY',
        kind: GameKind.slot, icon: Icons.bolt, c1: Color(0xFFFFEE58), c2: Color(0xFF6D4C41),
        symbols: ['LUCKY', 'SEVEN', 'BAR', 'CHERRY'],
        multipliers: {'LUCKY': 30, 'SEVEN': 9, 'BAR': 4, 'CHERRY': 3}),
    GameSpec(id: 'gift_wheel', name: 'Gift Wheel', subtitle: '1 ya 10 draw, prize pao',
        kind: GameKind.wheel, icon: Icons.pie_chart, c1: Color(0xFFAB47BC), c2: Color(0xFF311B92),
        prizes: [0, 0, 0, 1, 2, 5, 10, 25, 50]),
  ];

  static const party = <GameSpec>[
    GameSpec(id: 'lucky_bag', name: 'Lucky Bag', subtitle: 'Amount aur users chuno, room mein bhejo',
        kind: GameKind.bagSend, icon: Icons.wallet_giftcard, c1: Color(0xFFE53935), c2: Color(0xFFFFB300)),
  ];

  static GameSpec? byId(String id) {
    for (final g in [...lucky, ...party]) {
      if (g.id == id) return g;
    }
    return null;
  }
}
