import 'package:flutter/material.dart';

import '../handlers/room_roles_handler.dart';
import '../models/room_role.dart';
import '../services/room_roles_service.dart';

/// Seat requests ki list (approve / reject) aur role change (sirf host).
class RoomMembersScreen extends StatefulWidget {
  const RoomMembersScreen({
    super.key,
    required this.roomId,
    required this.myUid,
    required this.myRole,
  });

  final String roomId;
  final String myUid;
  final RoomRole myRole;

  @override
  State<RoomMembersScreen> createState() => _RoomMembersScreenState();
}

class _RoomMembersScreenState extends State<RoomMembersScreen> {
  final _service = RoomRolesService();
  late final RoomRolesHandler _handler = RoomRolesHandler(_service);

  void _show(String? msg) {
    if (!mounted || msg == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Members')),
      body: StreamBuilder<List<SeatRequest>>(
        stream: _service.watchSeatRequests(widget.roomId),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Requests load nahi hui'));
          final list = snap.data ?? const <SeatRequest>[];
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          if (list.isEmpty) return const Center(child: Text('Abhi koi seat request nahi hai'));
          return ListView(
            children: [
              for (final r in list)
                ListTile(
                  title: Text('Seat ${r.seatIndex}'),
                  subtitle: Text('User: ${r.uid}'),
                  trailing: Wrap(spacing: 6, children: [
                    TextButton(
                      onPressed: () async => _show(await _handler.resolveSeat(
                        roomId: widget.roomId, uid: r.uid, myRole: widget.myRole, approve: true)),
                      child: const Text('Approve'),
                    ),
                    TextButton(
                      onPressed: () async => _show(await _handler.resolveSeat(
                        roomId: widget.roomId, uid: r.uid, myRole: widget.myRole, approve: false)),
                      child: const Text('Reject'),
                    ),
                  ]),
                ),
            ],
          );
        },
      ),
    );
  }
}
