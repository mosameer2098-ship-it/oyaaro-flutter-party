import 'package:flutter/material.dart';

import '../models/vip_level.dart';
import '../painting/entry_effect_painter.dart';

/// VIP user room mein aaye to 3D entry effect. Ek baar chalta hai, phir onDone.
class VipEntryOverlay3D extends StatefulWidget {
  const VipEntryOverlay3D({super.key, required this.level, required this.name, required this.onDone});

  final VipLevel level;
  final String name;
  final VoidCallback onDone;

  @override
  State<VipEntryOverlay3D> createState() => _VipEntryOverlay3DState();
}

class _VipEntryOverlay3DState extends State<VipEntryOverlay3D> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 2600));

  @override
  void initState() {
    super.initState();
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final v = _c.value;
          final fade = v > 0.8 ? ((1 - v) / 0.2).clamp(0.0, 1.0).toDouble() : 1.0;
          return Opacity(
            opacity: fade,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(painter: EntryEffect3DPainter(t: v, color: widget.level.accent)),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [widget.level.c1, widget.level.c2]),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.name} ${widget.level.title} ke saath aaya',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
