import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/catalog.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/screens/gift_sheet.dart';
import 'package:oyaroo/screens/gift_overlay.dart';

import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/rockets.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/core/vip.dart';
import 'package:oyaroo/handlers/bag_handler.dart';
import 'package:oyaroo/handlers/chat_handler.dart';
import 'package:oyaroo/handlers/gift_handler.dart';
import 'package:oyaroo/handlers/room_handler.dart';
import 'package:oyaroo/handlers/room_mic_controller.dart';
import 'package:oyaroo/handlers/rocket_handler.dart';
import 'package:oyaroo/handlers/seat_handler.dart';
import 'package:oyaroo/handlers/spin_handler.dart';
import 'package:oyaroo/screens/game_screen.dart';
import 'package:oyaroo/screens/games_sheet.dart';
import 'package:oyaroo/screens/rocket_overlay.dart';
import 'package:oyaroo/screens/rocket_sheet.dart';
import 'package:oyaroo/screens/room_settings_screen.dart';
import 'package:oyaroo/screens/vip_entry_overlay.dart';
import 'package:oyaroo/services/room_service.dart';
import 'package:oyaroo/services/user_service.dart';

class RoomScreen extends StatefulWidget {
  final String roomId;
  const RoomScreen({super.key, required this.roomId});
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _seat = SeatHandler();
  final _giftHandler = GiftHandler();
  final _rocket = RocketHandler();
  final _spin = SpinHandler();
  final _chat = ChatHandler();
  final _roomH = RoomHandler();
  final _bag = BagHandler();
  final _chatCtrl = TextEditingController();
  late final RoomMicController _mic;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _roomStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _msgStream;
  String _name = 'User';

  // Animation ka state (rocket + VIP entry)
  bool _bootstrapped = false;
  String? _seenMsgId;
  RocketSpec? _launch;
  VipTier? _entry;
  String _eventBy = '';
  GiftSpec? _gift;

  @override
  void initState() {
    super.initState();
    _mic = RoomMicController(roomId: widget.roomId, uid: _uid);
    _roomStream = RoomService.roomStream(widget.roomId);
    _msgStream = RoomService.messages(widget.roomId);
    _init();
  }

  Future<void> _init() async {
    final n = await Result.guard(() => UserService.myName());
    if (n is Ok<String>) _name = n.value;
    final j = await _mic.join(_name);
    if (!mounted) return;
    showFailure(context, j);
    if (j is Ok<void>) {
      final vip = await Result.guard(() => UserService.myVip());
      if (vip is Ok<int>) {
        await _roomH.announceEntry(widget.roomId, _name, vip.value);
      }
    }
    setState(() {});
  }

  @override
  void dispose() {
    _chatCtrl.dispose();
    _seat.leave(widget.roomId);
    _mic.dispose();
    super.dispose();
  }

  Future<void> _do(Future<Result<void>> Function() action) async {
    final r = await action();
    if (mounted) showFailure(context, r);
  }

  Future<void> _onSeatTap(int index, Map<String, dynamic> seat, bool isHost) async {
    if (seat['uid'] == _uid && index > 0) {
      await _mic.stopPublishing();
      await _do(() => _seat.leave(widget.roomId));
    } else if (seat['uid'] == null) {
      final taken = await _seat.take(widget.roomId, index);
      if (!mounted) return;
      if (taken is Err<void>) {
        showFailure(context, taken);
        return;
      }
      await _mic.startPublishing();
      await _do(() => _seat.setMyMuted(widget.roomId, !_mic.micOn));
    } else if (isHost && index > 0) {
      _hostSeatMenu(index, seat);
    }
  }

  void _hostSeatMenu(int index, Map<String, dynamic> seat) {
    final muted = seat['muted'] == true;
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(muted ? Icons.mic : Icons.mic_off),
              title: Text(muted ? 'Unmute karo' : 'Mute karo'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _do(() => _seat.hostSetMuted(widget.roomId, index, !muted));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_remove),
              title: const Text('Seat se hatao'),
              onTap: () {
                Navigator.pop(sheetCtx);
                _do(() => _seat.kick(widget.roomId, index));
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleMic() async {
    final r = await _mic.toggle();
    if (!mounted) return;
    setState(() {});
    showFailure(context, r);
    await _do(() => _seat.setMyMuted(widget.roomId, !_mic.micOn));
  }

  void _showGifts() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: GiftSheet(
          categories: const [
            GiftCategory.normal,
            GiftCategory.vip,
            GiftCategory.free,
            GiftCategory.event,
          ],
          onPick: (g) {
            Navigator.pop(sheetCtx);
            _do(() async {
              final r = await _giftHandler.send(widget.roomId, _name, g.name);
              if (r is Ok<void> && mounted) {
                showMessage(context, '${g.name} bheja!');
              }
              return r;
            });
          },
        ),
      ),
    );
  }

  void _showRockets() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: RocketSheet(
          onLaunch: (spec) {
            Navigator.pop(sheetCtx);
            _do(() => _rocket.launch(widget.roomId, _name, spec.id));
          },
        ),
      ),
    );
  }

  void _showGames() {
    showModalBottomSheet(
      context: context,
      builder: (sheetCtx) => GamesSheet(
        onPick: (g) {
          Navigator.pop(sheetCtx);
          Navigator.push(
              context, MaterialPageRoute(builder: (_) => GameScreen(game: g, roomId: widget.roomId)));
        },
      ),
    );
  }

  Future<void> _spinNow() async {
    final r = await _spin.spin();
    if (!mounted) return;
    if (r is Ok<int>) {
      showMessage(context,
          r.value == 0 ? 'Is baar koi prize nahi mila' : 'Aapne ${r.value} coins jeete!');
    } else {
      showFailure(context, r);
    }
  }

  Future<void> _sendChat() async {
    final r = await _chat.sendRoomMessage(widget.roomId, _name, _chatCtrl.text);
    if (!mounted) return;
    if (r is Ok<void>) {
      _chatCtrl.clear();
    } else {
      showFailure(context, r);
    }
  }

  // Naye messages dekhta hai: rocket ya VIP entry ho to animation chalata hai
  // (pehli baar load par purane events ka animation nahi chalta)
  Widget _eventFeed() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _msgStream,
        builder: (context, snap) {
          if (snap.hasData && snap.data!.docs.isNotEmpty) {
            final newest = snap.data!.docs.first;
            if (!_bootstrapped) {
              _bootstrapped = true;
              _seenMsgId = newest.id;
            } else if (newest.id != _seenMsgId) {
              _seenMsgId = newest.id;
              final m = newest.data();
              final who = '${m['name'] ?? ''}';
              if (m['type'] == 'rocket') {
                final spec = Rockets.byId('${m['text']}');
                if (spec != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _launch = spec; _eventBy = who; });
                  });
                }
              } else if (m['type'] == 'gift') {
                final spec = GiftHelper.find('${m['text']}');
                if (spec != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _gift = spec; _eventBy = who; });
                  });
                }
              } else if (m['type'] == 'entry') {
                final n = int.tryParse('${m['text']}'.replaceAll('VIP', ''));
                if (n != null && n >= 1 && n <= Vip.all.length) {
                  final tier = Vip.byLevel(n);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() { _entry = tier; _eventBy = who; });
                  });
                }
              }
            }
          }
          return const SizedBox.shrink();
        },
      );

  Future<void> _claimBag(String bagId) async {
    final r = await _bag.claim(bagId);
    if (!mounted) return;
    if (r is Ok<void>) {
      showMessage(context, 'Bag claim ho gaya! Diamond mil gaye.');
    } else {
      showFailure(context, r);
    }
  }

  Widget _seatCard(int index, Map<String, dynamic> seat, bool isHost) {
    final occupied = seat['uid'] != null;
    final muted = seat['muted'] == true;
    return GestureDetector(
      onTap: () => _onSeatTap(index, seat, isHost),
      child: Container(
        decoration: BoxDecoration(
          color: occupied ? Colors.deepPurple.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: index == 0 ? 30 : 22,
              child: Icon(occupied ? Icons.person : Icons.event_seat),
            ),
            const SizedBox(height: 4),
            Text(
              occupied ? '${seat['name'] ?? ''}' : 'Khali',
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
            if (occupied) Icon(muted ? Icons.mic_off : Icons.mic, size: 14),
            if (index == 0)
              const Text('Host',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton.icon(
              onPressed: _showGifts,
              icon: const Icon(Icons.card_giftcard),
              label: const Text('Gift')),
          TextButton.icon(
              onPressed: _showRockets,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Rocket')),
          TextButton.icon(
              onPressed: _showGames,
              icon: const Icon(Icons.sports_esports),
              label: const Text('Games')),
          TextButton.icon(
              onPressed: _spinNow,
              icon: const Icon(Icons.casino),
              label: const Text('Spin')),
        ],
      );

  Widget _chatPanel() => Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _msgStream,
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                final docs = snap.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final m = docs[i].data();
                    final type = m['type'];
                    final String line;
                    if (type == 'gift') {
                      line = 'Gift bheja: ${m['text']}';
                    } else if (type == 'rocket') {
                      final spec = Rockets.byId('${m['text']}');
                      line = 'Rocket launch: ${spec?.name ?? ''}';
                    } else if (type == 'bag') {
                      line = 'Lucky Bag bheja. Claim karne ke liye tap karein';
                    } else if (type == 'entry') {
                      line = 'Room mein aaye (${m['text']})';
                    } else {
                      line = '${m['text'] ?? ''}';
                    }
                    return ListTile(
                      dense: true,
                      title: Text('${m['name'] ?? ''}'),
                      subtitle: Text(line),
                      onTap: type == 'bag' ? () => _claimBag('${m['text']}') : null,
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatCtrl,
                    decoration: const InputDecoration(
                        hintText: 'Message likho', isDense: true),
                    onSubmitted: (_) => _sendChat(),
                  ),
                ),
                IconButton(icon: const Icon(Icons.send), onPressed: _sendChat),
              ],
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _roomStream,
      builder: (context, snap) {
        final data = snap.data?.data();
        if (data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final isHost = data['hostUid'] == _uid;
        final count = data['seatCount'] as int;
        final seats = (data['seats'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _mic.sync(isHost, seats);

        return Scaffold(
          appBar: AppBar(
            title: Text('${data['name'] ?? 'Room'}'),
            actions: [
              IconButton(
                icon: Icon(_mic.micOn ? Icons.mic : Icons.mic_off),
                onPressed: _toggleMic,
              ),
              if (isHost)
                IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          RoomSettingsScreen(roomId: widget.roomId, current: count),
                    ),
                  ),
                ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: SizedBox(
                        width: 140,
                        height: 140,
                        child: _seatCard(0, seats[0], isHost),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: GridView.count(
                        crossAxisCount: 3,
                        padding: const EdgeInsets.all(12),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        children: [
                          for (var i = 1; i < count; i++) _seatCard(i, seats[i], isHost),
                        ],
                      ),
                    ),
                    _toolbar(),
                    const Divider(height: 1),
                    Expanded(flex: 2, child: _chatPanel()),
                  ],
                ),
              ),
              _eventFeed(),
              if (_entry != null)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: VipEntryOverlay(
                    key: ValueKey('vip-$_seenMsgId'),
                    tier: _entry!,
                    name: _eventBy,
                    onDone: () => setState(() => _entry = null),
                  ),
                ),
              if (_gift != null)
                Positioned.fill(
                  child: GiftOverlay(
                    key: ValueKey('gift-$_seenMsgId'),
                    spec: _gift!,
                    senderName: _eventBy,
                    onDone: () => setState(() => _gift = null),
                  ),
                ),
              if (_launch != null)
                Positioned.fill(
                  child: RocketLaunchOverlay(
                    key: ValueKey('rocket-$_seenMsgId'),
                    spec: _launch!,
                    senderName: _eventBy,
                    onDone: () => setState(() => _launch = null),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
