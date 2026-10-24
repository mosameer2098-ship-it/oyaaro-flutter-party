import 'dart:ui' show Color;
import '../models/account_role.dart';
import '../models/frame_spec.dart';

/// Frame catalog: 5 role frames + 9 VIP frames + 1000 standard frames.
/// Standard frames parameter combinations se bante hain (10 palette x 10 wing x 5 crown x 2 gem = 1000 unique).
class FrameCatalog {
  static const standardCount = 1000;

  static const _wingNames = [
    'Phoenix', 'Seraph', 'Griffin', 'Lotus', 'Eagle',
    'Starling', 'Aurora', 'Thorn', 'Dragon', 'Halo',
  ];

  static const _palettes = <FramePalette>[
    FramePalette(name: 'Violet', primary: Color(0xFF9C6BFF), secondary: Color(0xFFE1B3FF), accent: Color(0xFFFFD86B), glow: Color(0xFFB388FF)),
    FramePalette(name: 'Pearl', primary: Color(0xFFEFF6FF), secondary: Color(0xFFBFD8F5), accent: Color(0xFFE8C872), glow: Color(0xFFFFFFFF)),
    FramePalette(name: 'Crimson', primary: Color(0xFFD7263D), secondary: Color(0xFFFF8A80), accent: Color(0xFFFFD54F), glow: Color(0xFFFF5252)),
    FramePalette(name: 'Ivory', primary: Color(0xFFFFF8E7), secondary: Color(0xFFF0D9A0), accent: Color(0xFFC9A227), glow: Color(0xFFFFF3C4)),
    FramePalette(name: 'Emerald', primary: Color(0xFF2E9E6A), secondary: Color(0xFFA5F3C9), accent: Color(0xFFFFD86B), glow: Color(0xFF69F0AE)),
    FramePalette(name: 'Sapphire', primary: Color(0xFF1E5EFF), secondary: Color(0xFF9DD9FF), accent: Color(0xFFE0F7FA), glow: Color(0xFF18FFFF)),
    FramePalette(name: 'Obsidian', primary: Color(0xFF2B2B3A), secondary: Color(0xFF8A8AA8), accent: Color(0xFFE5C07B), glow: Color(0xFFB388FF)),
    FramePalette(name: 'Amber', primary: Color(0xFFFF9800), secondary: Color(0xFFFFE0B2), accent: Color(0xFFFFF59D), glow: Color(0xFFFFC107)),
    FramePalette(name: 'Rose', primary: Color(0xFFE91E63), secondary: Color(0xFFF8BBD0), accent: Color(0xFFFFD1DC), glow: Color(0xFFFF4DFF)),
    FramePalette(name: 'Aurora', primary: Color(0xFF00E5FF), secondary: Color(0xFFB388FF), accent: Color(0xFF69F0AE), glow: Color(0xFF18FFFF)),
  ];

  static final List<FrameSpec> roleFrames = [
    const FrameSpec(id: 'role_support', name: 'Support Crest', category: FrameCategory.role,
        palette: FramePalette(name: 'Support', primary: Color(0xFF26C6DA), secondary: Color(0xFFB2EBF2), accent: Color(0xFFFFFFFF), glow: Color(0xFF18FFFF)),
        wingStyle: 2, crownStyle: 1, gemStyle: 0, animationStyle: 0, role: AccountRole.support),
    const FrameSpec(id: 'role_admin', name: 'Admin Sovereign', category: FrameCategory.role,
        palette: FramePalette(name: 'Admin', primary: Color(0xFFB71C1C), secondary: Color(0xFFFFD54F), accent: Color(0xFFFFF176), glow: Color(0xFFFF5252)),
        wingStyle: 5, crownStyle: 4, gemStyle: 1, animationStyle: 1, role: AccountRole.admin),
    const FrameSpec(id: 'role_superadmin', name: 'Super Admin Eclipse', category: FrameCategory.role,
        palette: FramePalette(name: 'Eclipse', primary: Color(0xFF212121), secondary: Color(0xFFFFD700), accent: Color(0xFFE040FB), glow: Color(0xFFFFD700)),
        wingStyle: 9, crownStyle: 4, gemStyle: 1, animationStyle: 3, role: AccountRole.superAdmin),
    const FrameSpec(id: 'role_bd', name: 'BD Emerald', category: FrameCategory.role,
        palette: FramePalette(name: 'BD', primary: Color(0xFF00897B), secondary: Color(0xFFC0C0C0), accent: Color(0xFF69F0AE), glow: Color(0xFF69F0AE)),
        wingStyle: 4, crownStyle: 2, gemStyle: 0, animationStyle: 2, role: AccountRole.bd),
    const FrameSpec(id: 'role_superbd', name: 'Super BD Platinum', category: FrameCategory.role,
        palette: FramePalette(name: 'Platinum', primary: Color(0xFFE0E0E0), secondary: Color(0xFFFF4DFF), accent: Color(0xFF18FFFF), glow: Color(0xFFFF4DFF)),
        wingStyle: 7, crownStyle: 3, gemStyle: 1, animationStyle: 3, role: AccountRole.superBd),
  ];

  static final List<FrameSpec> vipFrames = [
    for (var i = 0; i < _vipPalettes.length; i++)
      FrameSpec(id: 'vip_${i + 1}', name: 'VIP ${i + 1} ${_vipPalettes[i].name}', category: FrameCategory.vip,
          palette: _vipPalettes[i], wingStyle: i, crownStyle: (i ~/ 2).clamp(0, 4),
          gemStyle: i >= 4 ? 1 : 0, animationStyle: i % 4, vipLevel: i + 1),
  ];

  static const _vipPalettes = <FramePalette>[
    FramePalette(name: 'Silver', primary: Color(0xFFCFD8DC), secondary: Color(0xFF78909C), accent: Color(0xFFFFFFFF), glow: Color(0xFFB0BEC5)),
    FramePalette(name: 'Bronze', primary: Color(0xFFD7A77A), secondary: Color(0xFF8D5524), accent: Color(0xFFFFE0B2), glow: Color(0xFFD7A77A)),
    FramePalette(name: 'Gold', primary: Color(0xFFFFE082), secondary: Color(0xFFFF8F00), accent: Color(0xFFFFF8E1), glow: Color(0xFFFFD54F)),
    FramePalette(name: 'Emerald', primary: Color(0xFFA5D6A7), secondary: Color(0xFF2E7D32), accent: Color(0xFFC8E6C9), glow: Color(0xFF69F0AE)),
    FramePalette(name: 'Sapphire', primary: Color(0xFF90CAF9), secondary: Color(0xFF0D47A1), accent: Color(0xFFE3F2FD), glow: Color(0xFF18FFFF)),
    FramePalette(name: 'Ruby', primary: Color(0xFFEF9A9A), secondary: Color(0xFFB71C1C), accent: Color(0xFFFFCDD2), glow: Color(0xFFFF5252)),
    FramePalette(name: 'Amethyst', primary: Color(0xFFCE93D8), secondary: Color(0xFF6A1B9A), accent: Color(0xFFF3E5F5), glow: Color(0xFFE040FB)),
    FramePalette(name: 'Diamond', primary: Color(0xFFE1F5FE), secondary: Color(0xFF4FC3F7), accent: Color(0xFFFFFFFF), glow: Color(0xFF80D8FF)),
    FramePalette(name: 'Royal', primary: Color(0xFFFFF176), secondary: Color(0xFF4A148C), accent: Color(0xFFFFFDE7), glow: Color(0xFFE040FB)),
  ];

  static final List<FrameSpec> standardFrames = List.generate(standardCount, (i) {
    // Mixed-radix index: i = p + 10*w + 100*c + 500*g, har i ke liye unique combination
    final p = i % 10;
    final w = (i ~/ 10) % 10;
    final c = (i ~/ 100) % 5;
    final g = (i ~/ 500) % 2;
    final palette = _palettes[p];
    return FrameSpec(
      id: 'std_${(i + 1).toString().padLeft(4, '0')}',
      name: '${palette.name} ${_wingNames[w]} #${i + 1}',
      category: FrameCategory.standard,
      palette: palette,
      wingStyle: w,
      crownStyle: c,
      gemStyle: g,
      animationStyle: i % 4,
      price: 500 + (i ~/ 100) * 500,
    );
  });

  static final List<FrameSpec> all = [...roleFrames, ...vipFrames, ...standardFrames];

  static final Map<String, FrameSpec> _byId = {for (final f in all) f.id: f};

  static FrameSpec? byId(String id) => _byId[id];

  static FrameSpec vipFrame(int level) => _byId['vip_${level.clamp(1, 9)}']!;
}
