import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/cp_levels.dart';
import 'package:oyaroo/services/chat_service.dart';
import 'package:oyaroo/screens/chat_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Me > CP / Friend: sabhi CP bonds ki list
class CpScreen extends StatelessWidget {
  const CpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('CP / Friend')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ChatService.myConversations(),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!.docs.where((d) {
            final cp = d.data()['cp'] as Map?;
            return cp != null && cp['status'] != 'none';
          }).toList();
          if (docs.isEmpty) {
            return const Center(
              child: Text('Abhi koi CP nahi hai.\nChat mein jaakar CP request bhejein.',
                  textAlign: TextAlign.center),
            );
          }
          return ListView(
            children: docs.map((d) {
              final data = d.data();
              final names = Map<String, dynamic>.from(data['names'] ?? {});
              final otherName = names.entries
                  .firstWhere((e) => e.key != me, orElse: () => const MapEntry('', 'User'))
                  .value
                  .toString();
              final lvl = CpLevels.levelFor((data['cpExp'] ?? 0) as int);
              final status = (data['cp'] as Map)['status'];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: CpLevels.colorFor(lvl),
                  child: Text('$lvl', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(otherName),
                subtitle: Text('${CpLevels.titles[lvl - 1]}  -  ${status == 'active' ? 'Active' : 'Pending'}'),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ChatScreen(convId: d.id, title: otherName))),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
