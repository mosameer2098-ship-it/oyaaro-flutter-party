import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      if (FirebaseAuth.instance.currentUser?.uid != null) {
        try {
          await RoomService.ensureRoomCapacity(widget.roomId);
        } catch (error) {
          debugPrint('Oyaroo room capacity migration failed: $error');
        }
      }
      try {
        await RoomService.recordRoomVisit(widget.roomId);
      } catch (error) {
        debugPrint('Oyaroo room visit/presence save failed: $error');
      }
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
    unawaited(
      RoomService.clearCurrentRoom(widget.roomId).catchError((Object error) {
        debugPrint('Oyaroo room presence cleanup failed: $error');
      }),
    );
    _mic.dispose();
    super.dispose();
  }

  Future<void> _do(Future<Result<void>> Function() action) async {
    final r = await action();
    if (mounted) showFailure(context, r);
  }

  Future<void> _onSeatTap(
    int index,
    Map<String, dynamic> seat,
    bool isHost,
  ) async {
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
            context,
            MaterialPageRoute(
              builder: (_) => GameScreen(game: g, roomId: widget.roomId),
            ),
          );
        },
      ),
    );
  }

  Future<void> _spinNow() async {
    final r = await _spin.spin();
    if (!mounted) return;
    if (r is Ok<int>) {
      showMessage(
        context,
        r.value == 0
            ? 'Is baar koi prize nahi mila'
            : 'Aapne ${r.value} coins jeete!',
      );
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
                if (mounted)
                  setState(() {
                    _launch = spec;
                    _eventBy = who;
                  });
              });
            }
          } else if (m['type'] == 'gift') {
            final spec = GiftHelper.find('${m['text']}');
            if (spec != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted)
                  setState(() {
                    _gift = spec;
                    _eventBy = who;
                  });
              });
            }
          } else if (m['type'] == 'entry') {
            final n = int.tryParse('${m['text']}'.replaceAll('VIP', ''));
            if (n != null && n >= 1 && n <= Vip.all.length) {
              final tier = Vip.byLevel(n);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted)
                  setState(() {
                    _entry = tier;
                    _eventBy = who;
                  });
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
    final isOwner = index == 0;
    final isSuperMic = index == 1;
    final accent = isOwner
        ? const Color(0xFFB8860B)
        : isSuperMic
        ? const Color(0xFFB45BC8)
        : const Color(0xFF6575A8);

    return GestureDetector(
      onTap: () => _onSeatTap(index, seat, isHost),
      child: Container(
        constraints: const BoxConstraints(minHeight: 96),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: occupied ? Colors.white : const Color(0xFFF5F6FA),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: occupied ? accent : const Color(0xFFE1E4EC),
            width: isOwner || isSuperMic ? 1.8 : 1,
          ),
          boxShadow: [
            if (isOwner || isSuperMic)
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwner || isSuperMic)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text(
                  isOwner ? 'OWNER' : 'SUPER MIC',
                  style: TextStyle(
                    color: accent,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                  ),
                ),
              ),
            CircleAvatar(
              radius: isOwner || isSuperMic ? 25 : 21,
              backgroundColor: accent.withValues(alpha: 0.12),
              child: Icon(
                occupied
                    ? (isOwner ? Icons.workspace_premium : Icons.person)
                    : Icons.event_seat,
                color: accent,
                size: isOwner || isSuperMic ? 27 : 23,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              occupied ? '${seat['name'] ?? 'User'}' : 'Khali',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF252A3A),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (occupied && !isOwner)
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Icon(
                  muted ? Icons.mic_off : Icons.mic,
                  size: 15,
                  color: muted ? Colors.redAccent : Colors.green.shade700,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolbar() => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          tooltip: _mic.micOn ? 'Mute microphone' : 'Unmute microphone',
          onPressed: _toggleMic,
          icon: Icon(_mic.micOn ? Icons.mic : Icons.mic_off),
        ),
        TextButton.icon(
          onPressed: _showGifts,
          icon: const Icon(Icons.card_giftcard),
          label: const Text('Gift'),
        ),
        TextButton.icon(
          onPressed: _showRockets,
          icon: const Icon(Icons.rocket_launch),
          label: const Text('Rocket'),
        ),
        TextButton.icon(
          onPressed: _showGames,
          icon: const Icon(Icons.sports_esports),
          label: const Text('Games'),
        ),
        TextButton.icon(
          onPressed: _spinNow,
          icon: const Icon(Icons.casino),
          label: const Text('Spin'),
        ),
      ],
    ),
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
                  hintText: 'Message likho',
                  isDense: true,
                ),
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
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final isHost = data['hostUid'] == _uid;
        final count = data['seatCount'] as int;
        final seats = (data['seats'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _mic.sync(isHost, seats);

        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            titleSpacing: 12,
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9EAF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.groups_rounded,
                    color: Color(0xFF5966A8),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data['name'] ?? 'Room'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'ID: ${widget.roomId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                tooltip: 'Copy room details',
                icon: const Icon(Icons.share_outlined),
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text:
                          'Oyaroo Room: ${data['name'] ?? 'Room'}\n'
                          'Room ID: ${widget.roomId}',
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Room details copied')),
                    );
                  }
                },
              ),
              if (isHost)
                IconButton(
                  tooltip: 'Room settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RoomSettingsScreen(
                        roomId: widget.roomId,
                        current: count,
                      ),
                    ),
                  ),
                ),
              IconButton(
                tooltip: 'Exit room',
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.maybePop(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFF8F9FD), Color(0xFFF0F2F9)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Color(0xFFE5E8F1)),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.campaign_outlined,
                                color: Color(0xFF6575A8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Welcome to ${data['name'] ?? 'Oyaroo Room'} • '
                                  'Respect everyone and keep the room friendly.',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF3B4052),
                                    fontSize: 11,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.favorite_border,
                                size: 17,
                                color: Color(0xFFB45BC8),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: SizedBox(
                                height: 142,
                                child: _seatCard(0, seats[0], isHost),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: SizedBox(
                                height: 142,
                                child: _seatCard(
                                  1,
                                  seats.length > 1
                                      ? seats[1]
                                      : <String, dynamic>{
                                          'uid': null,
                                          'name': null,
                                          'muted': true,
                                        },
                                  isHost,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: GridView.count(
                          crossAxisCount: 3,
                          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                          mainAxisSpacing: 9,
                          crossAxisSpacing: 9,
                          childAspectRatio: 0.92,
                          children: [
                            for (var i = 2; i < 14; i++)
                              _seatCard(
                                i,
                                i < seats.length
                                    ? seats[i]
                                    : <String, dynamic>{
                                        'uid': null,
                                        'name': null,
                                        'muted': true,
                                      },
                                isHost,
                              ),
                          ],
                        ),
                      ),
                      _toolbar(),
                      const Divider(height: 1),
                      Expanded(flex: 2, child: _chatPanel()),
                    ],
                  ),
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
