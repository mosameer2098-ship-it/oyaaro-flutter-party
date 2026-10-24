import 'package:flutter/material.dart';

import '../models/level_reward.dart';

/// Original art (code se). Koi copied image nahi. Final art baad mein assets se replace hoga.
const _palettes = <List<Color>>[
  [Color(0xFFCFD8DC), Color(0xFF546E7A)],
  [Color(0xFFD7A77A), Color(0xFF6D3B1F)],
  [Color(0xFFFFE082), Color(0xFF8A5A00)],
  [Color(0xFFA5D6A7), Color(0xFF1B5E20)],
  [Color(0xFF90CAF9), Color(0xFF0D2F6B)],
  [Color(0xFFEF9A9A), Color(0xFF6B0F1A)],
  [Color(0xFFCE93D8), Color(0xFF3E1A5C)],
  [Color(0xFFB2EBF2), Color(0xFF004D5C)],
  [Color(0xFFFFF176), Color(0xFF4A148C)],
  [Color(0xFFFFD700), Color(0xFF7A4A00)],
];

List<Color> paletteFor(int level) => _palettes[((level - 1) ~/ 10).clamp(0, 9)];

class RewardArt extends StatelessWidget {
  const RewardArt({super.key, required this.reward, this.size = 80});

  final LevelReward reward;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pal = paletteFor(reward.level);
    final box = SizedBox(width: size, height: size);
    switch (reward.kind) {
      case RewardKind.badge:
        return box.copyWithChild(CustomPaint(painter: ShieldPainter(colors: pal, label: 'Lv.${reward.level}', stars: 0)));
      case RewardKind.medal:
        return box.copyWithChild(CustomPaint(painter: ShieldPainter(colors: pal, label: 'Lv ${reward.level}', stars: reward.stars)));
      case RewardKind.frame:
        return box.copyWithChild(CustomPaint(painter: RingPainter(colors: pal, label: 'Lv.${reward.level}')));
      case RewardKind.coins:
        return box.copyWithChild(CustomPaint(painter: CoinStackPainter()));
      case RewardKind.vehicle:
        return _tile(pal, Icons.directions_car_filled, 'Lv.${reward.level}');
      case RewardKind.theme:
        return _tile(pal, Icons.wallpaper, 'Theme');
      case RewardKind.customId:
        return _tile(pal, Icons.badge_outlined, '${reward.digits}-digit ID');
      case RewardKind.background:
        return _tile(pal, Icons.portrait, 'Background');
      case RewardKind.superMic:
        return _tile(pal, Icons.mic, 'Super Mic');
      case RewardKind.openingPage:
        return _tile(pal, Icons.phone_android, 'Cover');
      case RewardKind.entrance:
        return _tile(pal, Icons.login, 'Entrance');
    }
  }

  Widget _tile(List<Color> pal, IconData icon, String label) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: pal, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFFD54F), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: size * 0.4),
            Text(label, style: TextStyle(color: Colors.white, fontSize: size * 0.12)),
          ],
        ),
      );
}

extension _Boxed on SizedBox {
  Widget copyWithChild(Widget child) => SizedBox(width: width, height: height, child: child);
}

Path _shield(Rect r) {
  final p = Path()
    ..moveTo(r.center.dx, r.top)
    ..lineTo(r.right, r.top + r.height * 0.18)
    ..lineTo(r.right, r.top + r.height * 0.55)
    ..quadraticBezierTo(r.right, r.bottom, r.center.dx, r.bottom)
    ..quadraticBezierTo(r.left, r.bottom, r.left, r.top + r.height * 0.55)
    ..lineTo(r.left, r.top + r.height * 0.18)
    ..close();
  return p;
}

void _drawLabel(Canvas canvas, String label, Offset center, double fontSize, double maxWidth) {
  final tp = TextPainter(
    text: TextSpan(
      text: label,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: fontSize),
    ),
    textDirection: TextDirection.ltr,
  )..layout(maxWidth: maxWidth);
  tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
}

class ShieldPainter extends CustomPainter {
  ShieldPainter({required this.colors, required this.label, required this.stars});

  final List<Color> colors;
  final String label;
  final int stars;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Rect.fromLTWH(size.width * 0.12, size.height * 0.06, size.width * 0.76, size.height * 0.8);
    final path = _shield(r);
    canvas.drawPath(
      path,
      Paint()..shader = LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(r),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.04
        ..color = const Color(0xFFFFD54F),
    );
    _drawLabel(canvas, label, r.center, size.width * 0.14, r.width);
    for (var i = 0; i < stars; i++) {
      final x = size.width * (0.5 + (i - (stars - 1) / 2) * 0.12);
      canvas.drawCircle(Offset(x, size.height * 0.94), size.width * 0.04, Paint()..color = const Color(0xFFFFD54F));
    }
  }

  @override
  bool shouldRepaint(covariant ShieldPainter old) =>
      old.label != label || old.stars != stars || old.colors != colors;
}

class RingPainter extends CustomPainter {
  RingPainter({required this.colors, required this.label});

  final List<Color> colors;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final ring = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: size.width * 0.8,
      height: size.height * 0.7,
    );
    canvas.drawOval(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.width * 0.08
        ..shader = SweepGradient(colors: [...colors, colors.first]).createShader(ring),
    );
    final tag = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.88), width: size.width * 0.7, height: size.height * 0.16);
    canvas.drawRRect(RRect.fromRectAndRadius(tag, const Radius.circular(6)), Paint()..color = colors.last);
    _drawLabel(canvas, label, tag.center, size.width * 0.1, tag.width);
  }

  @override
  bool shouldRepaint(covariant RingPainter old) => old.label != label || old.colors != colors;
}

class CoinStackPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const gold = [Color(0xFFFFF176), Color(0xFFFFB300), Color(0xFF8D6E00)];
    for (var i = 2; i >= 0; i--) {
      final c = Offset(size.width * 0.5 + i * size.width * 0.06, size.height * 0.6 - i * size.height * 0.06);
      final rect = Rect.fromCircle(center: c, radius: size.width * 0.3);
      canvas.drawCircle(
        c,
        size.width * 0.3,
        Paint()..shader = const RadialGradient(colors: gold).createShader(rect),
      );
      canvas.drawCircle(
        c,
        size.width * 0.3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFF8D6E00),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CoinStackPainter old) => false;
}
