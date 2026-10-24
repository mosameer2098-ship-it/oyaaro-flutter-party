import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/cp_levels.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/cp_handler.dart';
import 'package:oyaroo/services/chat_service.dart';

// Chat ke andar CP ka panel: request, accept, aur bond level
class CpPanel extends StatelessWidget {
  final String convId;
  const CpPanel({super.key, required this.convId});

  @override
  Widget build(BuildContext context) {
    final me = FirebaseAuth.instance.currentUser!.uid;
    final handler = CpHandler();
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: ChatService.convStream(convId),
      builder: (context, snap) {
        final d = snap.data?.data() ?? {};
        final cp = Map<String, dynamic>.from(d['cp'] ?? {});
        final status = cp['status'] ?? 'none';
        final exp = (d['cpExp'] ?? 0) as int;
        final lvl = CpLevels.levelFor(exp);
        final cur = CpLevels.requiredExp(lvl);
        final next = lvl >= CpLevels.maxLevel ? cur : CpLevels.requiredExp(lvl + 1);
        final progress = lvl >= CpLevels.maxLevel ? 1.0 : (exp - cur) / (next - cur);

        final Widget action;
        if (status == 'active') {
          action = const Text('CP active hai');
        } else if (status == 'pending' && cp['by'] == me) {
          action = const Text('Request bhej di, jawab ka intezar hai');
        } else if (status == 'pending') {
          action = ElevatedButton(
            onPressed: () => reportResult(context, handler.accept(convId),
                successMsg: 'CP accept ho gaya!'),
            child: const Text('Accept karo'),
          );
        } else {
          action = ElevatedButton(
            onPressed: () => reportResult(context, handler.request(convId),
                successMsg: 'CP request bhej di'),
            child: const Text('CP request bhejo'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: CpLevels.colorFor(lvl),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('CP Lv $lvl / ${CpLevels.maxLevel}  -  ${CpLevels.titles[lvl - 1]}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: progress.clamp(0.0, 1.0).toDouble()),
              const SizedBox(height: 4),
              Text('Bond exp: $exp (next level: $next)'),
              const SizedBox(height: 16),
              action,
            ],
          ),
        );
      },
    );
  }
}
