import 'dart:ui' show Color;

import 'account_role.dart';

enum FrameCategory { role, vip, standard }

/// Frame ke rang. Ek palette se glow, ring aur gems ke rang aate hain.
class FramePalette {
  final String name;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color glow;
  const FramePalette({
    required this.name,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.glow,
  });
}

/// Ek frame ka poora description. Painter isi se draw karta hai.
class FrameSpec {
  final String id;
  final String name;
  final FrameCategory category;
  final FramePalette palette;
  final int wingStyle; // 0..9: feather count aur shape
  final int crownStyle; // 0..4: crown ke points
  final int gemStyle; // 0..1: gems ki sankhya
  final int animationStyle; // 0 shimmer, 1 gem pulse, 2 wing flutter, 3 sparkle orbit
  final int price; // standard frames ka coin price (host economy par lagta hai)
  final int? vipLevel; // vip frames ke liye
  final AccountRole? role; // role frames ke liye

  const FrameSpec({
    required this.id,
    required this.name,
    required this.category,
    required this.palette,
    required this.wingStyle,
    required this.crownStyle,
    required this.gemStyle,
    required this.animationStyle,
    this.price = 0,
    this.vipLevel,
    this.role,
  });
}
