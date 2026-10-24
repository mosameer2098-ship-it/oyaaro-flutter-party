import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/catalog.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/room_handler.dart';
import 'package:oyaroo/screens/room_screen.dart';
import 'package:oyaroo/services/room_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _rooms = RoomHandler();
  int _tab = 1; // 0 = Mine, 1 = Popular

  void _openRoom(String id) {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => RoomScreen(roomId: id)));
  }

  Future<void> _createRoom() async {
    final ctrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Naya room'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Room ka naam'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text),
            child: const Text('Banao'),
          ),
        ],
      ),
    );
    if (name == null) return;
    final r = await _rooms.createRoom(name);
    if (!mounted) return;
    if (r is Ok<String>) {
      _openRoom(r.value);
    } else {
      showFailure(context, r);
    }
  }

  Widget _tabButton(String label, int i) => GestureDetector(
        onTap: () => setState(() => _tab = i),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: _tab == i ? FontWeight.bold : FontWeight.normal,
                color: _tab == i ? Colors.black : Colors.black45,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 3,
              width: 24,
              color: _tab == i ? Colors.black : Colors.transparent,
            ),
          ],
        ),
      );

  Widget _popularTab() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: RoomService.roomList(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs.toList()
            ..sort((a, b) => RoomService.occupiedCount(b.data())
                .compareTo(RoomService.occupiedCount(a.data())));
          if (docs.isEmpty) {
            return const Center(child: Text('Abhi koi room nahi hai'));
          }
          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemCount: docs.length,
            itemBuilder: (_, i) => _roomCard(docs[i]),
          );
        },
      );

  Widget _roomCard(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final live = RoomService.occupiedCount(data);
    return GestureDetector(
      onTap: () => _openRoom(d.id),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.amber.shade300, Colors.deepPurple.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            const Center(
                child: Icon(Icons.graphic_eq, size: 48, color: Colors.white)),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('🎙 $live',
                    style: const TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['name'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                  ),
                  Text(
                    'Host: ${data['hostName'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mineTab() => Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: RoomService.myRooms(),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snap.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Aapka koi room nahi hai.\nNeeche se naya room banayein.',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView(
                  children: docs.map((d) {
                    final data = d.data();
                    return ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.mic)),
                      title: Text('${data['name'] ?? ''}'),
                      subtitle: Text('Live: ${RoomService.occupiedCount(data)} log'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openRoom(d.id),
                    );
                  }).toList(),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createRoom,
                  icon: const Icon(Icons.add),
                  label: const Text('Naya room banao'),
                ),
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow.shade200, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0.0, 0.35],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tabButton('Mine', 0),
                  const SizedBox(width: 32),
                  _tabButton('Popular', 1),
                ],
              ),
            ),
            Expanded(child: _tab == 0 ? _mineTab() : _popularTab()),
          ],
        ),
      ),
    );
  }
}
