import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/vip_level.dart';

/// Har tier ka original creature emblem. t = 0..1 animation. Koi copied artwork nahi.
class CreatureEmblemPainter extends CustomPainter {
  CreatureEmblemPainter({required this.level, required this.t});

  final VipLevel level;
  final double t;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = size.center(Offset.zero);
    final ring = Rect.fromCircle(center: c, radius: s * 0.48);

    canvas.drawCircle(c, s * 0.48, Paint()..color = const Color(0xFF14091F));
    canvas.drawCircle(
      c,
      s * 0.48,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.03
        ..shader = SweepGradient(
          colors: [level.c1, level.accent, level.c2, level.c1],
          transform: GradientRotation(t * _twoPi),
        ).createShader(ring),
    );

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [level.c1, level.c2],
      ).createShader(Rect.fromCircle(center: c, radius: s * 0.4));
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = s * 0.02
      ..strokeCap = StrokeCap.round
      ..color = level.accent;

    switch (level.creature) {
      case Creature.hawk:
        _hawk(canvas, c, s, fill, t);
      case Creature.fox:
        _fox(canvas, c, s, fill);
      case Creature.owl:
        _owl(canvas, c, s, fill, line);
      case Creature.cobra:
        _cobra(canvas, c, s, fill, line, t);
      case Creature.shark:
        _shark(canvas, c, s, fill, line, t);
      case Creature.scorpion:
        _scorpion(canvas, c, s, fill, line);
      case Creature.pegasus:
        _pegasus(canvas, c, s, fill, t);
      case Creature.kraken:
        _kraken(canvas, c, s, line, t);
      case Creature.griffin:
        _griffin(canvas, c, s, fill, t);
    }
  }

  Offset _p(Offset c, double s, double dx, double dy) => c + Offset(s * dx, s * dy);

  void _poly(Canvas canvas, Offset c, double s, List<Offset> pts, Paint paint) {
    final path = Path()..moveTo(_p(c, s, pts[0].dx, pts[0].dy).dx, _p(c, s, pts[0].dx, pts[0].dy).dy);
    for (final o in pts.skip(1)) {
      final q = _p(c, s, o.dx, o.dy);
      path.lineTo(q.dx, q.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _hawk(Canvas canvas, Offset c, double s, Paint fill, double t) {
    final flap = math.sin(t * _twoPi) * 0.05;
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(c.dx, c.dy - s * 0.02)
        ..quadraticBezierTo(c.dx + side * s * 0.42, c.dy - s * (0.30 + flap), c.dx + side * s * 0.38, c.dy + s * 0.12)
        ..lineTo(c.dx + side * s * 0.10, c.dy + s * 0.04)
        ..close();
      canvas.drawPath(wing, fill);
    }
    canvas.drawCircle(_p(c, s, 0, -0.14), s * 0.09, fill);
    _poly(canvas, c, s, const [Offset(-0.02, -0.12), Offset(0.02, -0.12), Offset(0, -0.02)],
        Paint()..color = const Color(0xFFFFD54F));
  }

  void _fox(Canvas canvas, Offset c, double s, Paint fill) {
    _poly(canvas, c, s, const [
      Offset(-0.28, -0.22), Offset(-0.12, -0.30), Offset(0, -0.18), Offset(0.12, -0.30),
      Offset(0.28, -0.22), Offset(0.18, 0.12), Offset(0, 0.30), Offset(-0.18, 0.12),
    ], fill);
    canvas.drawCircle(_p(c, s, -0.10, -0.04), s * 0.035, Paint()..color = Colors.black);
    canvas.drawCircle(_p(c, s, 0.10, -0.04), s * 0.035, Paint()..color = Colors.black);
  }

  void _owl(Canvas canvas, Offset c, double s, Paint fill, Paint line) {
    canvas.drawCircle(_p(c, s, 0, 0.02), s * 0.25, fill);
    _poly(canvas, c, s, const [Offset(-0.22, -0.10), Offset(-0.14, -0.30), Offset(-0.06, -0.12)], fill);
    _poly(canvas, c, s, const [Offset(0.22, -0.10), Offset(0.14, -0.30), Offset(0.06, -0.12)], fill);
    for (final dx in [-0.09, 0.09]) {
      canvas.drawCircle(_p(c, s, dx, -0.02), s * 0.085, Paint()..color = Colors.white);
      canvas.drawCircle(_p(c, s, dx, -0.02), s * 0.04, Paint()..color = Colors.black);
    }
    canvas.drawLine(_p(c, s, -0.03, 0.08), _p(c, s, 0.03, 0.08), line);
  }

  void _cobra(Canvas canvas, Offset c, double s, Paint fill, Paint line, double t) {
    final hood = Path()
      ..moveTo(c.dx - s * 0.14, c.dy + s * 0.25)
      ..quadraticBezierTo(c.dx - s * 0.36, c.dy - s * 0.05, c.dx - s * 0.12, c.dy - s * 0.28)
      ..lineTo(c.dx + s * 0.12, c.dy - s * 0.28)
      ..quadraticBezierTo(c.dx + s * 0.36, c.dy - s * 0.05, c.dx + s * 0.14, c.dy + s * 0.25)
      ..close();
    canvas.drawPath(hood, fill);
    final sway = math.sin(t * _twoPi) * s * 0.03;
    final body = Path()
      ..moveTo(c.dx, c.dy + s * 0.25)
      ..quadraticBezierTo(c.dx + sway, c.dy + s * 0.36, c.dx - sway, c.dy + s * 0.42);
    canvas.drawPath(body, line);
    canvas.drawCircle(_p(c, s, 0, -0.12), s * 0.03, Paint()..color = Colors.black);
  }

  void _shark(Canvas canvas, Offset c, double s, Paint fill, Paint line, double t) {
    _poly(canvas, c, s, const [Offset(0, -0.32), Offset(0.16, 0.02), Offset(-0.02, 0.02)], fill);
    final shift = math.sin(t * _twoPi) * s * 0.03;
    final wave = Path()..moveTo(c.dx - s * 0.38, c.dy + s * 0.20);
    for (var i = 1; i <= 8; i++) {
      final x = c.dx - s * 0.38 + s * 0.76 * i / 8;
      final y = c.dy + s * 0.20 + math.sin(i * 1.2 + t * _twoPi) * s * 0.04 + shift * 0.1;
      wave.lineTo(x, y);
    }
    canvas.drawPath(wave, line);
  }

  void _scorpion(Canvas canvas, Offset c, double s, Paint fill, Paint line) {
    canvas.drawOval(Rect.fromCenter(center: _p(c, s, 0, 0.08), width: s * 0.36, height: s * 0.22), fill);
    final tail = Path()
      ..moveTo(c.dx + s * 0.14, c.dy + s * 0.02)
      ..quadraticBezierTo(c.dx + s * 0.34, c.dy - s * 0.06, c.dx + s * 0.22, c.dy - s * 0.30)
      ..quadraticBezierTo(c.dx + s * 0.12, c.dy - s * 0.38, c.dx + s * 0.06, c.dy - s * 0.28);
    canvas.drawPath(tail, line);
    canvas.drawCircle(_p(c, s, 0.06, -0.28), s * 0.04, Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(_p(c, s, -0.30, 0.02), s * 0.06, fill);
    canvas.drawCircle(_p(c, s, -0.22, 0.14), s * 0.05, fill);
  }

  void _pegasus(Canvas canvas, Offset c, double s, Paint fill, double t) {
    final flap = math.sin(t * _twoPi) * 0.06;
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(c.dx + side * s * 0.05, c.dy - s * 0.02)
        ..quadraticBezierTo(c.dx + side * s * 0.36, c.dy - s * (0.34 + flap), c.dx + side * s * 0.30, c.dy + s * 0.04)
        ..close();
      canvas.drawPath(wing, fill);
    }
    canvas.drawOval(Rect.fromCenter(center: _p(c, s, 0, 0.06), width: s * 0.36, height: s * 0.18), fill);
    _poly(canvas, c, s, const [Offset(-0.22, 0.02), Offset(-0.30, -0.12), Offset(-0.14, -0.04)], fill);
    _poly(canvas, c, s, const [Offset(-0.28, -0.14), Offset(-0.34, -0.26), Offset(-0.24, -0.16)],
        Paint()..color = const Color(0xFFFFD54F));
  }

  void _kraken(Canvas canvas, Offset c, double s, Paint line, double t) {
    final dome = Rect.fromCircle(center: _p(c, s, 0, -0.06), radius: s * 0.22);
    canvas.drawArc(dome, math.pi, math.pi, true, Paint()..color = const Color(0xFF80DEEA));
    for (var k = 0; k < 4; k++) {
      final x0 = c.dx + s * (-0.16 + k * 0.10);
      final path = Path()..moveTo(x0, c.dy + s * 0.02);
      for (var i = 1; i <= 6; i++) {
        final y = c.dy + s * 0.02 + s * 0.08 * i;
        final x = x0 + math.sin(i * 1.1 + k + t * _twoPi) * s * 0.05;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, line);
    }
  }

  void _griffin(Canvas canvas, Offset c, double s, Paint fill, double t) {
    final flap = math.sin(t * _twoPi) * 0.05;
    for (final side in [-1.0, 1.0]) {
      final wing = Path()
        ..moveTo(c.dx + side * s * 0.08, c.dy - s * 0.04)
        ..quadraticBezierTo(c.dx + side * s * 0.42, c.dy - s * (0.26 + flap), c.dx + side * s * 0.36, c.dy + s * 0.12)
        ..lineTo(c.dx + side * s * 0.10, c.dy + s * 0.06)
        ..close();
      canvas.drawPath(wing, fill);
    }
    canvas.drawCircle(_p(c, s, 0.04, -0.14), s * 0.09, fill);
    _poly(canvas, c, s, const [Offset(0.11, -0.16), Offset(0.22, -0.12), Offset(0.11, -0.10)],
        Paint()..color = const Color(0xFFFFD54F));
    canvas.drawOval(Rect.fromCenter(center: _p(c, s, -0.02, 0.16), width: s * 0.26, height: s * 0.18), fill);
  }

  @override
  bool shouldRepaint(covariant CreatureEmblemPainter old) =>
      old.t != t || old.level.level != level.level;
}
