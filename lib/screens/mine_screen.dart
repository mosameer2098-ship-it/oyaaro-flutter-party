import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/handlers/room_handler.dart';
import 'package:oyaroo/screens/me_screen.dart';
import 'package:oyaroo/screens/room_screen.dart';
import 'package:oyaroo/services/room_service.dart';

class MineScreen extends StatefulWidget {
  const MineScreen({super.key});

  @override
  State<MineScreen> createState() => _MineScreenState();
}

class _MineScreenState extends State<MineScreen> {
  int _topTab = 0;
  int _roomTab = 0;
  bool _creating = false;

  String get _uid => FirebaseAuth.instance.currentUser!.uid;

  void _openRoom(String id) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RoomScreen(roomId: id)),
    );
  }

  Future<void> _createRoom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create Room'),
        content: TextField(
          controller: controller,
          maxLength: 40,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'Room ka naam'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || !mounted) return;

    setState(() => _creating = true);
    final result = await RoomHandler().createRoom(name);
    if (!mounted) return;
    setState(() => _creating = false);

    if (result is Ok<String>) {
      _openRoom(result.value);
    } else if (result is Err<String>) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFE878), Color(0xFFFFC928)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 8,
            left: 18,
            right: 10,
            bottom: 12,
          ),
          child: Row(
            children: [
              _headerTab('Mine', 0),
              const SizedBox(width: 22),
              _headerTab('Popular', 1),
              const Spacer(),
              IconButton(
                tooltip: 'Home',
                onPressed: () => setState(() => _topTab = 0),
                icon: const Icon(Icons.home_outlined),
              ),
              IconButton(
                tooltip: 'Search rooms',
                onPressed: _searchRooms,
                icon: const Icon(Icons.search),
              ),
              IconButton(
                tooltip: 'Profile and settings',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MeScreen()),
                ),
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ],
          ),
        ),
        Expanded(child: _topTab == 0 ? _buildMineBody() : _buildPopularRooms()),
      ],
    );
  }

  Widget _headerTab(String title, int index) => GestureDetector(
    onTap: () => setState(() => _topTab = index),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: _topTab == index ? FontWeight.w800 : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 24,
          height: 3,
          decoration: BoxDecoration(
            color: _topTab == index ? Colors.black87 : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ],
    ),
  );

  Widget _buildMineBody() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
      children: [
        _myRoomCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            _subTab('Recently', 0),
            const SizedBox(width: 22),
            _subTab('Follow', 1),
          ],
        ),
        const SizedBox(height: 12),
        if (_roomTab == 0) _recentRooms() else _followedUsers(),
      ],
    );
  }

  Widget _subTab(String title, int index) => GestureDetector(
    onTap: () => setState(() => _roomTab = index),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: _roomTab == index
                  ? FontWeight.bold
                  : FontWeight.normal,
              color: _roomTab == index ? Colors.black87 : Colors.black54,
            ),
          ),
          const SizedBox(height: 3),
          Container(
            width: 28,
            height: 3,
            decoration: BoxDecoration(
              color: _roomTab == index
                  ? const Color(0xFFFFC928)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _myRoomCard() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: RoomService.myRooms(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return _createRoomCard();
        }
        final room = docs.first;
        final data = room.data();
        return _roomTile(
          title: data['name']?.toString() ?? 'My Room',
          subtitle:
              'Your room · ${RoomService.occupiedCount(data)} seats occupied',
          icon: Icons.meeting_room_outlined,
          onTap: () => _openRoom(room.id),
          trailing: const Icon(Icons.chevron_right),
        );
      },
    );
  }

  Widget _createRoomCard() {
    return Material(
      color: const Color(0xFFFFF7D4),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _creating ? null : _createRoom,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.add, size: 30),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Room',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Apna voice room shuru karein',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
              if (_creating)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recentRooms() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: RoomService.recentlyVisitedRooms(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _empty('Recently rooms load nahi ho paaye.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return _empty('Abhi koi recently visited room nahi hai.');
        }
        return Column(
          children: docs.map((doc) {
            final data = doc.data();
            final id = data['roomId']?.toString() ?? doc.id;
            return _roomTile(
              title: data['roomName']?.toString() ?? 'Room',
              subtitle: 'Recently visited',
              icon: Icons.history,
              onTap: () => _openRoom(id),
              trailing: const Icon(Icons.chevron_right),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _followedUsers() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_uid)
          .collection('following')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _empty('Follow list load nahi ho paayi.');
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return _empty('Abhi aapne kisi ko follow nahi kiya.');
        return Column(
          children: docs.map((doc) => _followedUserTile(doc.id)).toList(),
        );
      },
    );
  }

  Widget _followedUserTile(String uid) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, profileSnapshot) {
        final profile = profileSnapshot.data?.data();
        final roomId = profile?['currentRoomId']?.toString();
        if (profile == null || roomId == null || roomId.isEmpty) {
          return const SizedBox.shrink();
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: RoomService.roomStream(roomId),
          builder: (context, roomSnapshot) {
            final room = roomSnapshot.data?.data();
            if (room == null) return const SizedBox.shrink();
            final seats = (room['seats'] as List?) ?? [];
            final onSeat = seats.any(
              (seat) => seat is Map && seat['uid']?.toString() == uid,
            );
            final status = onSeat ? 'On Mic' : 'On Room';
            final name = profile['name']?.toString() ?? 'User';
            return _roomTile(
              title: name,
              subtitle: room['name']?.toString() ?? 'Voice room',
              icon: Icons.account_circle_outlined,
              onTap: () => _openRoom(roomId),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD84D),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPopularRooms() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: RoomService.roomList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _empty('Rooms load nahi ho paaye.');
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return _empty('Abhi koi room available nahi hai.');
        return ListView(
          padding: const EdgeInsets.all(14),
          children: docs.map((doc) {
            final data = doc.data();
            return _roomTile(
              title: data['name']?.toString() ?? 'Room',
              subtitle: '${RoomService.occupiedCount(data)} seats occupied',
              icon: Icons.graphic_eq,
              onTap: () => _openRoom(doc.id),
              trailing: const Icon(Icons.chevron_right),
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _searchRooms() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search rooms'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Room ka naam'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
    final text = query?.trim().toLowerCase() ?? '';
    controller.dispose();
    if (text.isEmpty || !mounted) return;
    final result = await FirebaseFirestore.instance
        .collection('rooms')
        .where('nameLower', isGreaterThanOrEqualTo: text)
        .where('nameLower', isLessThanOrEqualTo: '$text\uf8ff')
        .limit(30)
        .get();
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => ListView(
        children: result.docs.map((doc) {
          final data = doc.data();
          return ListTile(
            leading: const Icon(Icons.meeting_room_outlined),
            title: Text(data['name']?.toString() ?? 'Room'),
            onTap: () {
              Navigator.pop(sheetContext);
              _openRoom(doc.id);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _roomTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Widget trailing,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0xFFF0F0F0)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFFFF1BD),
          child: Icon(icon, color: Colors.black87),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: trailing,
      ),
    );
  }

  Widget _empty(String message) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
    child: Center(child: Text(message, textAlign: TextAlign.center)),
  );
}
