import 'package:flutter/material.dart';

import '../../models/load_state.dart';
import '../../state/discover_controller.dart';
import '../discover_theme.dart';
import '../widgets/room_tile.dart';
import '../widgets/state_views.dart';

/// Rooms search: real rooms, join ka callback host app ko jata hai (voice Zego host app mein hai)
class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key, required this.controller, required this.onJoinRoom});
  final DiscoverController controller;
  final void Function(String roomId) onJoinRoom;
  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _query,
            textInputAction: TextInputAction.search,
            onSubmitted: c.searchRooms,
            decoration: InputDecoration(
              hintText: 'Room ka naam likhein',
              prefixIcon: const Icon(Icons.graphic_eq, color: DiscoverColors.neonCyan),
              filled: true,
              fillColor: DiscoverColors.surface,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ),
        Expanded(
          child: ListenableBuilder(
            listenable: c,
            builder: (context, _) => switch (c.rooms) {
              LoadIdle() => const EmptyView(
                  message: 'Room ka naam type karke search karein', icon: Icons.meeting_room_outlined),
              LoadLoading() => const LoadingView(),
              LoadError(:final message) => ErrorView(
                  message: message, onRetry: () => c.searchRooms(_query.text)),
              LoadData(:final value) when value.isEmpty => const EmptyView(
                  message: 'Koi room nahi mila', icon: Icons.search_off),
              LoadData(:final value) => ListView(
                  children: [
                    for (final r in value)
                      RoomTile(room: r, onJoin: () => widget.onJoinRoom(r.id)),
                  ],
                ),
            },
          ),
        ),
      ],
    );
  }
}
