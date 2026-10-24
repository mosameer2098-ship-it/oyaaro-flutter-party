import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/frame_spec.dart';

/// Frame ko canvas par draw karta hai. t = 0..1 (animation loop ka progress).
/// Wings, ring, crown, gems aur sparkles, sab spec ke parameters se.
class FrameArtPainter extends CustomPainter {
  FrameArtPainter({required this.spec, required this.t, this.reduceMotion = false});

  final FrameSpec spec;
  final double t;
  final bool reduceMotion;

  static const _twoPi = math.pi * 2;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final s = size.shortestSide;
    final r = s * 0.34;
    final p = spec.palette;
    final tt = reduceMotion ? 0.0 : t;
    final pulse = 0.5 + 0.5 * math.sin(tt * _twoPi);

    // Glow
    canvas.drawCircle(
      c,
      s * 0.5,
      Paint()
        ..shader = RadialGradient(colors: [
          p.glow.withValues(alpha: 0.30 + 0.15 * pulse),
          p.glow.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: s * 0.5)),
    );

    _wings(canvas, c, r, s, tt);

    // Ring: sweep gradient ghoomta hai (shimmer)
    final ringRect = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * 0.035
        ..shader = SweepGradient(
          colors: [p.primary, p.accent, p.secondary, p.primary],
          transform: GradientRotation(tt * _twoPi),
        ).createShader(ringRect),
    );

    _crown(canvas, c, r, s);
    _gems(canvas, c, r, s, tt, pulse);
    if (spec.animationStyle == 3) _sparkles(canvas, c, r, s, tt);
  }

  void _wings(Canvas canvas, Offset c, double r, double s, double tt) {
    final feathers = 4 + spec.wingStyle % 5; // 4..8
    final flutterAmp = spec.animationStyle == 2 ? 0.09 : 0.03;
    final p = spec.palette;
    for (final side in [-1.0, 1.0]) {
      for (var i = 0; i < feathers; i++) {
        final spread = i / (feathers - 1);
        final baseAngle = side < 0
            ? math.pi - (0.2 + 0.9 * spread)
            : (0.2 + 0.9 * spread);
        final angle = baseAngle + side * math.sin(tt * _twoPi + i * 0.7) * flutterAmp;
        final dir = Offset(math.cos(angle), math.sin(angle));
        final perp = Offset(-dir.dy, dir.dx);
        final base = c + dir * (r * 0.95);
        final len = s * (0.20 + 0.06 * math.sin(i * 1.3 + spec.wingStyle));
        final tip = base + dir * len;
        final ctrl = base + dir * (len * 0.55) + perp * (len * 0.22 * side);
        final feather = Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy)
          ..quadraticBezierTo(ctrl.dx - perp.dx * len * 0.3, ctrl.dy - perp.dy * len * 0.3, base.dx, base.dy)
          ..close();
        canvas.drawPath(
          feather,
          Paint()
            ..shader = LinearGradient(colors: [
              p.primary.withValues(alpha: 0.95),
              p.secondary.withValues(alpha: 0.7),
            ]).createShader(Rect.fromPoints(base, tip)),
        );
        canvas.drawPath(
          feather,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = s * 0.006
            ..color = p.accent.withValues(alpha: 0.8),
        );
      }
    }
  }

  void _crown(Canvas canvas, Offset c, double r, double s) {
    final points = 3 + spec.crownStyle; // 3..7
    final base = c + Offset(0, -r * 1.05);
    final w = s * 0.22;
    final path = Path()..moveTo(base.dx - w / 2, base.dy);
    final steps = points * 2;
    for (var k = 1; k <= steps; k++) {
      final x = base.dx - w / 2 + w * k / steps;
      final y = base.dy - (k.isOdd ? s * 0.12 : s * 0.03);
      path.lineTo(x, y);
    }
    path
      ..lineTo(base.dx + w / 2, base.dy + s * 0.02)
      ..close();
    final rect = Rect.fromLTWH(base.dx - w / 2, base.dy - s * 0.12, w, s * 0.14);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [spec.palette.accent, spec.palette.primary],
        ).createShader(rect),
    );
    canvas.drawCircle(base + Offset(0, -s * 0.03), s * 0.018, Paint()..color = spec.palette.glow);
  }

  void _gems(Canvas canvas, Offset c, double r, double s, double tt, double pulse) {
    final angles = <double>[math.pi / 2, if (spec.gemStyle == 1) ...[math.pi / 4, 3 * math.pi / 4]];
    final scale = spec.animationStyle == 1 ? 0.25 : 0.1;
    for (final a in angles) {
      final pos = c + Offset(math.cos(a), math.sin(a)) * r;
      final radius = s * 0.035 * (1 + scale * pulse);
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..shader = RadialGradient(colors: [spec.palette.accent, spec.palette.primary])
              .createShader(Rect.fromCircle(center: pos, radius: radius)),
      );
      canvas.drawCircle(pos + Offset(-radius * 0.3, -radius * 0.3), radius * 0.25,
          Paint()..color = Colors.white.withValues(alpha: 0.85));
    }
  }

  void _sparkles(Canvas canvas, Offset c, double r, double s, double tt) {
    for (var k = 0; k < 6; k++) {
      final a = tt * _twoPi + k * _twoPi / 6;
      final pos = c + Offset(math.cos(a), math.sin(a)) * (r * 1.25);
      final radius = s * 0.012 * (0.6 + 0.4 * math.sin(tt * _twoPi * 2 + k));
      canvas.drawCircle(pos, radius, Paint()..color = spec.palette.glow.withValues(alpha: 0.9));
    }
  }

  @override
  bool shouldRepaint(covariant FrameArtPainter oldDelegate) =>
      oldDelegate.spec.id != spec.id ||
      oldDelegate.t != t ||
      oldDelegate.reduceMotion != reduceMotion;
}
