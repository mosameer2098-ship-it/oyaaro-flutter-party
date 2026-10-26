import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/country_data.dart';
import 'package:oyaroo/services/user_service.dart';
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
      context,
      MaterialPageRoute(builder: (_) => RoomScreen(roomId: id)),
    );
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

  String _category = 'Popular';

  Widget _popularTab() => ListView(
    padding: const EdgeInsets.only(bottom: 16),
    children: [
      const SizedBox(height: 4),
      _AutoSlideStrip(
        count: 8,
        height: 126,
        viewportFraction: 1,
        builder: (_, index) {
          const banners = [
            'assets/discover/events/recharge_event.png',
            'assets/discover/events/cp_star.png',
            'assets/discover/events/offline_recharge.png',
            'assets/discover/events/vip_exclusive_benefits.png',
            'assets/discover/events/weekly_party_star.png',
            'assets/discover/events/customised_gift_star.png',
            'assets/discover/events/room_support.png',
            'assets/discover/events/pk_battle.png',
          ];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                banners[index],
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: Color(0xFFFFD36B),
                  child: Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
          );
        },
      ),
      const SizedBox(height: 6),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            Expanded(
              child: _AutoSlideStrip(
                count: 5,
                height: 78,
                viewportFraction: 1,
                builder: (_, index) => _FeaturePlaceholder(
                  title: 'Ranking',
                  index: index,
                  icon: Icons.emoji_events_rounded,
                  colors: const [Color(0xFFFFD66B), Color(0xFFFFA63A)],
                ),
              ),
            ),
            Expanded(
              child: _AutoSlideStrip(
                count: 5,
                height: 78,
                viewportFraction: 1,
                builder: (_, index) => _FeaturePlaceholder(
                  title: 'CP',
                  index: index,
                  icon: Icons.favorite_rounded,
                  colors: const [Color(0xFFFFB5CE), Color(0xFFE975A8)],
                ),
              ),
            ),
            Expanded(
              child: _AutoSlideStrip(
                count: 5,
                height: 78,
                viewportFraction: 1,
                builder: (_, index) => _FeaturePlaceholder(
                  title: 'Family',
                  index: index,
                  icon: Icons.groups_rounded,
                  colors: const [Color(0xFFA9E9D9), Color(0xFF50BDA5)],
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            _categoryChip('Popular'),
            const SizedBox(width: 7),
            _categoryChip('Game'),
            const SizedBox(width: 7),
            _categoryChip('Video/Music'),
          ],
        ),
      ),
      const SizedBox(height: 10),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: RoomService.roomList(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('Rooms load nahi ho paaye.')),
            );
          }
          if (!snap.hasData) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final docs = snap.data!.docs.toList()
            ..sort(
              (a, b) =>
                  RoomService.occupiedCount(b.data())
                      .compareTo(RoomService.occupiedCount(a.data())),
            );

          final filtered = docs.where((doc) {
            final data = doc.data();
            final kind = '${data['category'] ?? data['type'] ?? 'Popular'}'
                .toLowerCase();
            if (_category == 'Game') return kind.contains('game');
            if (_category == 'Video/Music') {
              return kind.contains('video') ||
                  kind.contains('music') ||
                  kind.contains('karaoke');
            }
            return true;
          }).toList();

          if (filtered.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(26),
              child: Center(
                child: Text(
                  docs.isEmpty
                      ? 'Abhi koi room nahi hai'
                      : 'Is category mein abhi room nahi hai',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.brown.shade500,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: .76,
            ),
            itemCount: filtered.length,
            itemBuilder: (_, i) => _roomCard(filtered[i]),
          );
        },
      ),
    ],
  );

  Widget _categoryChip(String label) {
    final selected = _category == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _category = label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFFFC629) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? const Color(0xFFFFC629)
                  : const Color(0xFFFFE8A6),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              color: const Color(0xFF4B3510),
            ),
          ),
        ),
      ),
    );
  }

  Widget _roomCard(QueryDocumentSnapshot<Map<String, dynamic>> d) {
    final data = d.data();
    final live = RoomService.occupiedCount(data);
    final hostUid = '${data['hostUid'] ?? ''}';

    return GestureDetector(
      onTap: () => _openRoom(d.id),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFE5A0)),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withValues(alpha: .08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: hostUid.isEmpty
              ? const Stream<DocumentSnapshot<Map<String, dynamic>>>.empty()
              : UserService.profileStream(hostUid),
          builder: (context, profileSnap) {
            final profile = profileSnap.data?.data() ?? <String, dynamic>{};
            final photoUrl = '${profile['photoUrl'] ?? ''}'.trim();
            final country = '${profile['country'] ?? ''}'.trim();
            final matches = oyarooCountries.where(
              (c) => c['name']?.toLowerCase() == country.toLowerCase(),
            );
            final flag = matches.isEmpty ? '' : (matches.first['flag'] ?? '');

            Widget fallbackPhoto() => Image.asset(
              'assets/discover/default_avatar.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Icon(
                  Icons.graphic_eq_rounded,
                  size: 48,
                  color: Color(0xFFB69B67),
                ),
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    color: const Color(0xFFFFF7E4),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (photoUrl.isNotEmpty)
                          Image.network(
                            photoUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => fallbackPhoto(),
                          )
                        else
                          fallbackPhoto(),
                        Positioned(
                          top: 7,
                          right: 7,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: .65),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '🎙 $live',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(9, 7, 9, 9),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${data['name'] ?? ''}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF382A17),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (flag.isNotEmpty) ...[
                        const SizedBox(width: 5),
                        Text(flag, style: const TextStyle(fontSize: 17)),
                      ],
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _mineSubTab = 0;

  Widget _mineTab() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: RoomService.myRooms(),
    builder: (context, roomSnap) {
      if (roomSnap.hasError) {
        return const Center(child: Text('Aapka room load nahi ho paaya.'));
      }
      if (!roomSnap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final rooms = roomSnap.data!.docs;
      final uid = FirebaseAuth.instance.currentUser?.uid;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: rooms.isEmpty
                ? SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _createRoom,
                      icon: const Icon(Icons.add),
                      label: const Text('Create Room'),
                    ),
                  )
                : Card(
                    child: ListTile(
                      leading: const CircleAvatar(child: Icon(Icons.mic)),
                      title: Text(
                        (rooms.first.data()['name'] ?? 'My Room').toString(),
                      ),
                      subtitle: Text(
                        'Your room · ${RoomService.occupiedCount(rooms.first.data())} log',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openRoom(rooms.first.id),
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => setState(() => _mineSubTab = 0),
                  child: Text(
                    'Recently',
                    style: TextStyle(
                      fontWeight: _mineSubTab == 0
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () => setState(() => _mineSubTab = 1),
                  child: Text(
                    'Follow',
                    style: TextStyle(
                      fontWeight: _mineSubTab == 1
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: uid == null
                ? const Center(child: Text('Login karke rooms dekhein.'))
                : _mineSubTab == 0
                ? _recentlyVisitedMine(uid)
                : _followedMine(uid),
          ),
        ],
      );
    },
  );

  Widget _recentlyVisitedMine(String uid) =>
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('recent_rooms')
            .orderBy('visitedAt', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snap) {
          if (snap.hasError) {
            return const Center(
              child: Text('Recently rooms load nahi ho paaye.'),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text('Abhi koi recently visited room nahi hai.'),
            );
          }
          return ListView(
            children: docs.map((doc) {
              final data = doc.data();
              final id = (data['roomId'] ?? doc.id).toString();
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text((data['roomName'] ?? 'Room').toString()),
                subtitle: const Text('Recently visited'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openRoom(id),
              );
            }).toList(),
          );
        },
      );

  Widget _followedMine(
    String uid,
  ) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('following')
        .snapshots(),
    builder: (context, snap) {
      if (snap.hasError) {
        return const Center(child: Text('Follow list load nahi ho paayi.'));
      }
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final docs = snap.data!.docs;
      if (docs.isEmpty) {
        return const Center(
          child: Text('Abhi aapne kisi ko follow nahi kiya.'),
        );
      }
      return ListView(
        children: docs.map((doc) {
          final followedUid = doc.id;
          return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(followedUid)
                .snapshots(),
            builder: (context, profileSnap) {
              final profile = profileSnap.data?.data();
              final roomId = profile?['currentRoomId']?.toString();
              if (profile == null || roomId == null || roomId.isEmpty) {
                return const SizedBox.shrink();
              }
              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: RoomService.roomStream(roomId),
                builder: (context, roomSnap) {
                  final room = roomSnap.data?.data();
                  if (room == null) return const SizedBox.shrink();
                  final seats = (room['seats'] as List?) ?? [];
                  final onMic = seats.any(
                    (seat) =>
                        seat is Map && seat['uid']?.toString() == followedUid,
                  );
                  return ListTile(
                    leading: const Icon(Icons.account_circle_outlined),
                    title: Text(
                      (profile['name'] ?? profile['displayName'] ?? 'User')
                          .toString(),
                    ),
                    subtitle: Text(
                      '${room['name'] ?? 'Voice room'} · ${onMic ? 'On Mic' : 'On Room'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openRoom(roomId),
                  );
                },
              );
            },
          );
        }).toList(),
      );
    },
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

class _AutoSlideStrip extends StatefulWidget {
  const _AutoSlideStrip({
    required this.count,
    required this.height,
    required this.builder,
    this.viewportFraction = .92,
  });

  final int count;
  final double height;
  final double viewportFraction;
  final Widget Function(BuildContext, int) builder;

  @override
  State<_AutoSlideStrip> createState() => _AutoSlideStripState();
}

class _AutoSlideStripState extends State<_AutoSlideStrip> {
  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: widget.viewportFraction);
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_page + 1) % widget.count,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
    height: widget.height,
    child: PageView.builder(
      controller: _controller,
      itemCount: widget.count,
      onPageChanged: (page) => _page = page,
      itemBuilder: widget.builder,
    ),
  );
}

class _BannerPlaceholder extends StatelessWidget {
  const _BannerPlaceholder({required this.index});
  final int index;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFFFE9A5).withValues(alpha: .98 - (index % 3) * .08),
            const Color(0xFFFFC629),
            const Color(0xFFFFD98A),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: .12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 18,
            top: 10,
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 40,
              color: Colors.white.withValues(alpha: .55),
            ),
          ),
          Positioned(
            left: 18,
            bottom: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .7),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                'Banner ${index + 1}',
                style: const TextStyle(
                  color: Color(0xFF65450B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _FeaturePlaceholder extends StatelessWidget {
  const _FeaturePlaceholder({
    required this.title,
    required this.index,
    required this.icon,
    required this.colors,
  });

  final String title;
  final int index;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
    child: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: .16),
            blurRadius: 9,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 12,
            top: 8,
            child: Icon(
              icon,
              size: 34,
              color: Colors.white.withValues(alpha: .48),
            ),
          ),
          Positioned(
            left: 14,
            bottom: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Slide ${index + 1}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: .9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
