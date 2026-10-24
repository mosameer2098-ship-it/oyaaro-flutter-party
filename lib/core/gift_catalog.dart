import 'dart:math';
import 'package:flutter/material.dart';

enum GiftTier { small, medium, big, legendary }

// normal: room mein sabko | vip: VIP level chahiye | free: roz limited, coin nahi katte
// event: event ke time par | cp: CP DM mein | friend: DM mein dost ko
enum GiftCategory { normal, vip, free, event, cp, friend }

class GiftSpec {
  final String name;
  final int price; // coin cut (0 = free)
  final GiftTier tier;
  final GiftCategory category;
  final int minVip; // vip gifts ke liye
  final IconData icon;
  final Color c1;
  final Color c2;
  const GiftSpec({
    required this.name,
    required this.price,
    required this.tier,
    required this.category,
    this.minVip = 0,
    required this.icon,
    required this.c1,
    required this.c2,
  });
}

class GiftCatalog {
  static const freeDailyLimit = 5;

  static const _palette = <List<Color>>[
    [Color(0xFFFF5C8A), Color(0xFFC2185B)],
    [Color(0xFFFFB74D), Color(0xFFE65100)],
    [Color(0xFF80DEEA), Color(0xFF00838F)],
    [Color(0xFFA5D6A7), Color(0xFF2E7D32)],
    [Color(0xFFCE93D8), Color(0xFF6A1B9A)],
    [Color(0xFFFFF176), Color(0xFFF9A825)],
    [Color(0xFF90CAF9), Color(0xFF1565C0)],
    [Color(0xFFEF9A9A), Color(0xFFB71C1C)],
    [Color(0xFFB39DDB), Color(0xFF4527A0)],
    [Color(0xFFFFE082), Color(0xFF6D4C41)],
    [Color(0xFF80CBC4), Color(0xFF004D40)],
    [Color(0xFFBCAAA4), Color(0xFF3E2723)],
  ];

  static const _icons = <IconData>[
    Icons.local_florist, Icons.favorite, Icons.pets, Icons.cake, Icons.diamond,
    Icons.directions_car, Icons.flight, Icons.castle, Icons.workspace_premium, Icons.auto_awesome,
    Icons.emoji_events, Icons.military_tech, Icons.star, Icons.nightlight_round, Icons.wb_sunny,
    Icons.bolt, Icons.music_note, Icons.sailing, Icons.park, Icons.spa,
    Icons.redeem, Icons.theater_comedy, Icons.celebration, Icons.brightness_7, Icons.card_giftcard,
    Icons.volunteer_activism, Icons.handshake, Icons.stars, Icons.rocket_launch, Icons.new_releases,
  ];

  static const _normalBase = [
    'Rose', 'Heart', 'Teddy', 'Cake', 'Diamond', 'Sports Car', 'Private Jet', 'Castle',
    'Crown', 'Galaxy', 'Lion', 'Tiger', 'Dragon', 'Phoenix', 'Unicorn', 'Star', 'Moon',
    'Sun', 'Ring', 'Perfume', 'Guitar', 'Piano', 'Trophy', 'Medal', 'Yacht', 'Island',
    'Palace', 'Bear', 'Dolphin', 'Fox',
  ];
  static const _variants = ['Mini', 'Classic', 'Premium', 'Deluxe'];
  static const _variantPrice = [10, 50, 300, 1000];

  static const _cpNames = [
    'Love Letter', 'Couple Ring', 'Heart Lock', 'Twin Hearts', 'Cupid Arrow', 'Love Bird',
    'Love Tree', 'Moon Date', 'Sunset Date', 'Candle Dinner', 'Love Song', 'Promise Ring',
    'Teddy Pair', 'Love Balloon', 'Rose Bouquet', 'Kiss Emoji', 'Sweet Heart', 'Forever Ring',
    'Love Boat', 'Starry Night', 'Couple Crown', 'Love Cake', 'Love Wings', 'Infinity Band',
    'Hug Bear', 'Love Castle', 'Heart Sparkle', 'Cute Pair', 'Paper Hearts', 'Cupid Gold',
  ];

  static const _friendNames = [
    'Hug', 'Handshake', 'Buddy Badge', 'High Five', 'Friend Bracelet', 'Best Friend Cup',
    'Smile Pack', 'Team Flag', 'Thumbs Up', 'Party Hat', 'Friend Cake', 'Shared Ticket',
    'Buddy Bear', 'Wave Hello', 'Friend Star', 'Chill Pack', 'Friend Rocket', 'Pizza Night',
    'Coffee Date', 'Game Night',
  ];

  static const _vipNames = [
    'VIP Badge', 'VIP Crest', 'VIP Ticket', 'VIP Chair', 'VIP Champagne', 'VIP Limo',
    'VIP Yacht', 'VIP Lounge', 'VIP Diamond Card', 'VIP Gold Pass', 'VIP Jet Ticket',
    'VIP Mansion Key', 'VIP Spotlight', 'VIP Crown Seal', 'VIP Vault', 'VIP Star Ring',
    'VIP Throne', 'VIP Aurora', 'VIP Empire', 'VIP Legend',
  ];

  static const _freeNames = [
    'Free Flower', 'Free Wave', 'Free Clap', 'Free Hi', 'Free Sparkle', 'Free Smile',
    'Free Breeze', 'Free Echo', 'Free Bubble', 'Free Star',
  ];

  static const _eventNames = [
    'Diwali Diya', 'Holi Color', 'New Year Fireworks', 'Eid Crescent', 'Christmas Tree',
    'Independence Flag', 'Cricket Trophy', 'Festival Lamp', 'Summer Fest', 'Anniversary Cake',
  ];

  static final List<GiftSpec> all = _build();

  static GiftTier _tierOf(int price) {
    if (price <= 50) return GiftTier.small;
    if (price <= 300) return GiftTier.medium;
    if (price <= 3000) return GiftTier.big;
    return GiftTier.legendary;
  }

  static List<GiftSpec> _build() {
    final list = <GiftSpec>[];
    var idx = 0;
    GiftSpec make(String name, int price, GiftCategory cat, {int minVip = 0}) {
      final pair = _palette[idx % _palette.length];
      final spec = GiftSpec(
        name: name,
        price: price,
        tier: _tierOf(price),
        category: cat,
        minVip: minVip,
        icon: _icons[idx % _icons.length],
        c1: pair[0],
        c2: pair[1],
      );
      idx++;
      return spec;
    }

    // 30 x 4 = 120 normal gifts
    for (var b = 0; b < _normalBase.length; b++) {
      for (var v = 0; v < _variants.length; v++) {
        list.add(make('${_variants[v]} ${_normalBase[b]}',
            _variantPrice[v] * (1 + b % 5), GiftCategory.normal));
      }
    }
    // 30 CP gifts
    for (var i = 0; i < _cpNames.length; i++) {
      list.add(make(_cpNames[i], 50 * (i + 1), GiftCategory.cp));
    }
    // 20 friend gifts
    for (var i = 0; i < _friendNames.length; i++) {
      list.add(make(_friendNames[i], 20 * (i + 1), GiftCategory.friend));
    }
    // 20 VIP gifts (VIP 1 se 9 tak)
    for (var i = 0; i < _vipNames.length; i++) {
      list.add(make(_vipNames[i], 500 * (i + 1), GiftCategory.vip,
          minVip: min(9, i ~/ 2 + 1)));
    }
    // 10 free gifts
    for (final n in _freeNames) {
      list.add(make(n, 0, GiftCategory.free));
    }
    // 10 event gifts
    for (var i = 0; i < _eventNames.length; i++) {
      list.add(make(_eventNames[i], 100 * (i + 1), GiftCategory.event));
    }
    return list;
  }

  static GiftSpec? byName(String name) {
    for (final g in all) {
      if (g.name == name) return g;
    }
    return null;
  }

  static List<GiftSpec> byCategory(GiftCategory c) =>
      all.where((g) => g.category == c).toList();

  static Map<String, int> get priceMap => {for (final g in all) g.name: g.price};
}
