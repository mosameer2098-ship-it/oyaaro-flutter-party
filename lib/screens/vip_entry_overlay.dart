import 'package:flutter/material.dart';
import 'package:oyaroo/core/vip.dart';

// VIP user ki entry: upar se banner aata hai aur chala jata hai
class VipEntryOverlay extends StatefulWidget {
  final VipTier tier;
  final String name;
  final VoidCallback onDone;
  const VipEntryOverlay({super.key, required this.tier, required this.name, required this.onDone});

  @override
  State<VipEntryOverlay> createState() => _VipEntryOverlayState();
}

class _VipEntryOverlayState extends State<VipEntryOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3));
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
          final opacity = v < 0.15 ? v / 0.15 : (v > 0.85 ? (1 - v) / 0.15 : 1.0);
          return Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [widget.tier.c1, widget.tier.c2]),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.name} VIP ${widget.tier.level} ke saath aaya! (${widget.tier.entryEffect})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
