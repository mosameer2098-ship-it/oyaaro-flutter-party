import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Do avatars ke beech ek shared couple frame. Colors couple theme se.
class CoupleAvatarPair extends StatefulWidget {
  const CoupleAvatarPair({
    super.key,
    required this.left,
    required this.right,
    required this.colors,
    this.radius = 30,
  });

  final Widget left;
  final Widget right;
  final List<Color> colors;
  final double radius;

  @override
  State<CoupleAvatarPair> createState() => _CoupleAvatarPairState();
}

class _CoupleAvatarPairState extends State<CoupleAvatarPair> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius;
    final size = r * 2 * 2.6;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _c,
            builder: (context, _) => CustomPaint(
              size: Size(size, size),
              painter: _CoupleRingPainter(colors: widget.colors, t: _c.value),
            ),
          ),
          Positioned(
            left: size * 0.12,
            child: _avatar(widget.left, r),
          ),
          Positioned(
            right: size * 0.12,
            child: _avatar(widget.right, r),
          ),
        ],
      ),
    );
  }

  Widget _avatar(Widget child, double r) => SizedBox(
        width: r * 2,
        height: r * 2,
        child: ClipOval(child: child),
      );
}

class _CoupleRingPainter extends CustomPainter {
  _CoupleRingPainter({required this.colors, required this.t});

  final List<Color> colors;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide;
    final ring = Rect.fromCircle(center: c, radius: s * 0.44);
    canvas.drawOval(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..shader = SweepGradient(
          colors: [...colors, colors.first],
          transform: GradientRotation(t * math.pi * 2),
        ).createShader(ring),
    );
    // Beech mein dil (heart)
    final pulse = 1 + 0.08 * math.sin(t * math.pi * 2);
    final h = s * 0.09 * pulse;
    final heart = Path()
      ..moveTo(c.dx, c.dy + h * 0.9)
      ..cubicTo(c.dx - h * 1.6, c.dy, c.dx - h * 0.6, c.dy - h * 1.3, c.dx, c.dy - h * 0.4)
      ..cubicTo(c.dx + h * 0.6, c.dy - h * 1.3, c.dx + h * 1.6, c.dy, c.dx, c.dy + h * 0.9)
      ..close();
    canvas.drawPath(heart, Paint()..color = colors.isNotEmpty ? colors.last : Colors.pink);
  }

  @override
  bool shouldRepaint(covariant _CoupleRingPainter old) => old.t != t || old.colors != colors;
}
