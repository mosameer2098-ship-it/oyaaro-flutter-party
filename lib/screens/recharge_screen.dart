import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/frames.dart';
import 'package:oyaroo/core/recharge_packages.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/recharge_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/helpers/frame_ring.dart';
import 'package:oyaroo/services/user_service.dart';

class RechargeScreen extends StatelessWidget {
  const RechargeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final handler = RechargeHandler();
    return Scaffold(
      appBar: AppBar(title: const Text('Recharge')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(uid),
        builder: (context, snap) {
          final coins = (snap.data?.data()?['coins'] ?? 0) as num;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Aapka balance: ${formatCoins(coins)} ${Brand.coinName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text('Online recharge', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final p in RechargePackages.all) _card(context, handler, p),
              const Divider(height: 32),
              const Text('Agent se recharge', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Agent ko neeche wali ID dikhayein. Agent cash lekar aapke coins bhej dega.'),
              Row(
                children: [
                  Expanded(
                    child: SelectableText(uid, style: const TextStyle(color: Colors.grey)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: uid));
                      showMessage(context, 'ID copy ho gayi');
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, RechargeHandler h, RechargePackage p) {
    final frame = Frames.byMilestone(p.frame);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            FrameAvatar(
              milestone: p.frame,
              radius: 26,
              child: Text('₹${p.amount}', style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('₹${p.amount} = ${formatCoins(p.coins)} ${Brand.coinName}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('Bonus 10%: +${formatCoins(p.bonus)} ${Brand.coinName}'),
                  Text('Frame theme: ${frame.name}'),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () => reportResult(context, h.online(p.amount),
                  successMsg: 'Recharge ho gaya!'),
              child: const Text('Online'),
            ),
          ],
        ),
      ),
    );
  }
}
