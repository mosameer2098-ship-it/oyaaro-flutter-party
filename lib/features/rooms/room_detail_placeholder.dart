import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../home/models/home_models.dart';

/// Room page opened from a Home card. It does not join audio. Live voice
/// arrives with the LiveKit stage.
class RoomDetailPlaceholder extends StatelessWidget {
  const RoomDetailPlaceholder({super.key, required this.room});

  final Room room;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OyaaroColors.background,
      appBar: AppBar(
        title: Text(room.name),
        backgroundColor: OyaaroColors.cream,
        foregroundColor: OyaaroColors.ink,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: room.color.withValues(alpha: 0.18),
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 44,
                  color: room.color,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                room.name,
                style: const TextStyle(
                  color: OyaaroColors.ink,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Hosted by ${room.hostName}',
                style: const TextStyle(color: OyaaroColors.muted),
              ),
              const SizedBox(height: 4),
              Text(
                '${room.listeners} listeners',
                style: const TextStyle(color: OyaaroColors.muted),
              ),
              const SizedBox(height: 24),
              const Text(
                'Joining voice rooms is not available yet. '
                'Live audio arrives with the LiveKit stage.',
                textAlign: TextAlign.center,
                style: TextStyle(color: OyaaroColors.ink),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
