import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../models/home_models.dart';

class RoomCard extends StatelessWidget {
  const RoomCard({super.key, required this.room, required this.onTap});

  final Room room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hostLine = room.language == null
        ? 'Hosted by ${room.hostName}'
        : 'Hosted by ${room.hostName} • ${room.language}';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: OyaaroColors.cream,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: room.color.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.graphic_eq_rounded,
                          size: 46,
                          color: room.color,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: _Pill(
                        label: room.category.label,
                        color: Colors.black54,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _Pill(
                        label: room.isLive ? 'LIVE' : null,
                        icon: Icons.mic_rounded,
                        text: '${room.listeners}',
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              child: Text(
                room.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: OyaaroColors.ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 11),
              child: Text(
                hostLine,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: OyaaroColors.muted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small rounded label. Shows an optional icon with text, or a plain label.
class _Pill extends StatelessWidget {
  const _Pill({
    this.label,
    this.icon,
    this.text,
    required this.color,
  });

  /// Plain label such as the category, or 'LIVE' for live rooms.
  final String? label;
  final IconData? icon;
  final String? text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    if (label != null) {
      children.add(
        Text(
          label!,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    if (icon != null) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(width: 6));
      }
      children.add(Icon(icon, size: 12, color: Colors.white));
      children.add(const SizedBox(width: 3));
      children.add(
        Text(
          text ?? '',
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}
