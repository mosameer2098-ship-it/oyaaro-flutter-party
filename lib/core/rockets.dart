import 'package:flutter/material.dart';

// Rocket ka look aur price. RocketPainter isi se draw karta hai.
class RocketSpec {
  final String id;
  final String name;
  final int price;
  final Color body;
  final Color accent;
  final Color fin;
  final bool pointedNose;
  final int finCount; // 2 ya 4
  final bool boosters; // side boosters
  final int stripes; // body par accent stripes
  const RocketSpec({
    required this.id,
    required this.name,
    required this.price,
    required this.body,
    required this.accent,
    required this.fin,
    required this.pointedNose,
    required this.finCount,
    this.boosters = false,
    this.stripes = 1,
  });
}

class Rockets {
  static const all = <RocketSpec>[
    RocketSpec(id: 'falcon_lite', name: 'Falcon Lite', price: 50,
        body: Color(0xFFF5F5F5), accent: Color(0xFF212121), fin: Color(0xFF757575),
        pointedNose: true, finCount: 2, stripes: 1),
    RocketSpec(id: 'aurora_one', name: 'Aurora One', price: 150,
        body: Color(0xFFE3F2FD), accent: Color(0xFF00ACC1), fin: Color(0xFF1565C0),
        pointedNose: true, finCount: 4, boosters: true, stripes: 2),
    RocketSpec(id: 'ironclad', name: 'Ironclad', price: 400,
        body: Color(0xFF90A4AE), accent: Color(0xFFFF6D00), fin: Color(0xFF37474F),
        pointedNose: false, finCount: 2, boosters: true, stripes: 3),
    RocketSpec(id: 'nebula_x', name: 'Nebula X', price: 1000,
        body: Color(0xFF283593), accent: Color(0xFFE91E63), fin: Color(0xFF1A237E),
        pointedNose: true, finCount: 4, stripes: 1),
    RocketSpec(id: 'solar_prime', name: 'Solar Prime', price: 2500,
        body: Color(0xFFFFF8E1), accent: Color(0xFFFFB300), fin: Color(0xFF8D6E63),
        pointedNose: false, finCount: 4, boosters: true, stripes: 2),
  ];

  static RocketSpec? byId(String id) {
    for (final r in all) {
      if (r.id == id) return r;
    }
    return null;
  }
}
