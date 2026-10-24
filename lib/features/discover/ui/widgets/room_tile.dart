import 'package:flutter/material.dart';

import '../../models/discover_room.dart';
import '../discover_theme.dart';

class RoomTile extends StatelessWidget {
  const RoomTile({super.key, required this.room, required this.onJoin});

  final DiscoverRoom room;
  final VoidCallback onJoin;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: DiscoverTheme.card(),
        child: ListTile(
          leading: const CircleAvatar(
            backgroundColor: DiscoverColors.surfaceHigh,
            child: Icon(Icons.graphic_eq, color: DiscoverColors.neonCyan),
          ),
          title: Text(room.name, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            'Host: ${room.hostName}  •  ${room.liveCount}/${room.seatCount} seats',
            style: const TextStyle(color: DiscoverColors.textDim),
          ),
          trailing: FilledButton(onPressed: onJoin, child: const Text('Join')),
        ),
      );
}
