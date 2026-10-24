import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/chat_handler.dart';
import 'package:oyaroo/screens/chat_screen.dart';
import 'package:oyaroo/services/chat_service.dart';

class MessageScreen extends StatelessWidget {
  const MessageScreen({super.key});

  DateTime _time(QueryDocumentSnapshot<Map<String, dynamic>> d) =>
      (d.data()['updatedAt'] as Timestamp?)?.toDate() ?? DateTime(2000);

  Future<void> _newChat(BuildContext context) async {
    final ctrl = TextEditingController();
    final uid = await showDialog<String>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Naya chat'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'Dusre user ki User ID'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, ctrl.text.trim()),
            child: const Text('Chat shuru karo'),
          ),
        ],
      ),
    );
    if (uid == null || uid.isEmpty || !context.mounted) return;
    final r = await ChatHandler().openDm(uid);
    if (!context.mounted) return;
    if (r is Ok<(String, String)>) {
      final (id, name) = r.value;
      Navigator.push(context,
          MaterialPageRoute(builder: (_) => ChatScreen(convId: id, title: name)));
    } else {
      showFailure(context, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    final myUid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _newChat(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ChatService.myConversations(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snap.data!.docs.toList()
            ..sort((a, b) => _time(b).compareTo(_time(a)));
          if (docs.isEmpty) {
            return const Center(
                child: Text('Abhi koi message nahi hai.\nUpar se naya chat shuru karein.',
                    textAlign: TextAlign.center));
          }
          return ListView(
            children: docs.map((d) {
              final data = d.data();
              final names = Map<String, dynamic>.from(data['names'] ?? {});
              final otherName = names.entries
                  .firstWhere((e) => e.key != myUid,
                      orElse: () => const MapEntry('', 'User'))
                  .value
                  .toString();
              return ListTile(
                leading: CircleAvatar(
                  child: Text(otherName.isEmpty ? '?' : otherName[0].toUpperCase()),
                ),
                title: Text(otherName),
                subtitle: Text('${data['lastText'] ?? ''}',
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => ChatScreen(convId: d.id, title: otherName)),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
