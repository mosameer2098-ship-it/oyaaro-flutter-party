import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/rockets.dart';
import 'package:oyaroo/helpers/rocket_painter.dart';

// Room mein rocket launch: animation + launch sound (sabko sunai deta hai)
class RocketLaunchOverlay extends StatefulWidget {
  final RocketSpec spec;
  final String senderName;
  final VoidCallback onDone;
  const RocketLaunchOverlay({
    super.key,
    required this.spec,
    required this.senderName,
    required this.onDone,
  });

  @override
  State<RocketLaunchOverlay> createState() => _RocketLaunchOverlayState();
}

class _RocketLaunchOverlayState extends State<RocketLaunchOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _player.play(AssetSource('sounds/rocket_launch.wav'));
    _c.forward().whenComplete(() {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeIn.transform(_c.value);
          final bottom = -120 + t * (height * 0.7);
          return Stack(
            children: [
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${widget.senderName} ne ${widget.spec.name} launch kiya!',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: bottom,
                child: Center(
                  child: SizedBox(
                    width: 120,
                    height: 200,
                    child: RocketPreview(spec: widget.spec),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
