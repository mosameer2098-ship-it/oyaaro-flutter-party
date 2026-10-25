import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
        count: 9,
        height: 142,
        builder: (_, index) => _BannerPlaceholder(index: index),
      ),
      const SizedBox(height: 8),
      _AutoSlideStrip(
        count: 5,
        height: 108,
        viewportFraction: .84,
        builder: (_, index) => _FeaturePlaceholder(
          title: 'Ranking',
          index: index,
          icon: Icons.emoji_events_rounded,
          colors: const [Color(0xFFFFD66B), Color(0xFFFFA63A)],
        ),
      ),
      const SizedBox(height: 6),
      _AutoSlideStrip(
        count: 5,
        height: 108,
        viewportFraction: .84,
        builder: (_, index) => _FeaturePlaceholder(
          title: 'CP',
          index: index,
          icon: Icons.favorite_rounded,
          colors: const [Color(0xFFFFB5CE), Color(0xFFE975A8)],
        ),
      ),
      const SizedBox(height: 6),
      _AutoSlideStrip(
        count: 5,
        height: 108,
        viewportFraction: .84,
        builder: (_, index) => _FeaturePlaceholder(
          title: 'Family',
          index: index,
          icon: Icons.groups_rounded,
          colors: const [Color(0xFFA9E9D9), Color(0xFF50BDA5)],
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
              childAspectRatio: .82,
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
              child: Icon(Icons.graphic_eq, size: 48, color: Colors.white),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '🎙 $live',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
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
                      fontSize: 15,
                    ),
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
                  subtitle: Text(
                    'Live: ${RoomService.occupiedCount(data)} log',
                  ),
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
