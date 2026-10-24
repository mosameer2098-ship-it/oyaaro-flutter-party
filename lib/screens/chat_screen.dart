import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/screens/gift_sheet.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/chat_handler.dart';
import 'package:oyaroo/screens/cp_panel.dart';
import 'package:oyaroo/services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final String convId;
  final String title;
  const ChatScreen({super.key, required this.convId, required this.title});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _chat = ChatHandler();
  final _ctrl = TextEditingController();
  late final Stream<QuerySnapshot<Map<String, dynamic>>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = ChatService.messages(widget.convId);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final r = await _chat.sendDm(widget.convId, _ctrl.text);
    if (!mounted) return;
    if (r is Ok<void>) {
      _ctrl.clear();
    } else {
      showFailure(context, r);
    }
  }

  void _giftSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetCtx) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: GiftSheet(
          categories: const [GiftCategory.cp, GiftCategory.friend],
          onPick: (g) async {
            Navigator.pop(sheetCtx);
            final r = await _chat.sendGiftDm(widget.convId, g.name);
            if (!mounted) return;
            if (r is Ok<void>) {
              showMessage(context, '${g.name} bheja!');
            } else {
              showFailure(context, r);
            }
          },
        ),
      ),
    );
  }

  void _cpSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => CpPanel(convId: widget.convId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(icon: const Icon(Icons.card_giftcard), tooltip: 'Gift', onPressed: _giftSheet),
          IconButton(icon: const Icon(Icons.favorite_border), tooltip: 'CP', onPressed: _cpSheet),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _stream,
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                final docs = snap.data!.docs;
                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final m = docs[i].data();
                    final mine = m['uid'] == _uid;
                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: mine ? Colors.amber.shade300 : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(m['type'] == 'gift' ? '🎁 ${m['text']}' : '${m['text'] ?? ''}'),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                          hintText: 'Message likho', isDense: true),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.send), onPressed: _send),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
