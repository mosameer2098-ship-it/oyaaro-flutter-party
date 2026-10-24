import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/core/vip.dart';
import 'package:oyaroo/handlers/vip_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/services/user_service.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('VIP')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(uid),
        builder: (context, snap) {
          final d = snap.data?.data() ?? {};
          final vip = (d['vip'] ?? 0) as int;
          final exp = (d['exp'] ?? 0) as int;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Aapke points: ${formatCoins(exp)}  |  Current: ${vip == 0 ? 'Koi nahi' : 'VIP $vip'}'),
              const SizedBox(height: 12),
              for (final t in Vip.all) _card(context, t, vip, exp),
            ],
          );
        },
      ),
    );
  }

  Widget _card(BuildContext context, VipTier t, int vip, int exp) {
    final owned = vip >= t.level;
    final isNext = vip == t.level - 1;
    final String status;
    Widget? action;
    if (owned) {
      status = 'Active';
    } else if (!isNext) {
      status = 'Pehle VIP ${t.level - 1} lo';
    } else if (exp < t.points) {
      status = 'Points: ${formatCoins(exp)} / ${formatCoins(t.points)}';
    } else {
      status = 'Lock khula hai';
      action = ElevatedButton(
        onPressed: () => reportResult(context, VipHandler().buy(t.level),
            successMsg: 'VIP ${t.level} mil gaya!'),
        child: Text('Buy (${formatCoins(t.price)} ${Brand.coinName})'),
      );
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [t.c1, t.c2]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('VIP ${t.level} - ${t.name}',
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Entry: ${t.entryEffect}', style: const TextStyle(color: Colors.white)),
          Text('Points chahiye: ${formatCoins(t.points)}', style: const TextStyle(color: Colors.white)),
          Text('Price: ${formatCoins(t.price)} ${Brand.coinName}', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: Text(status, style: const TextStyle(color: Colors.white))),
              if (action != null) action,
            ],
          ),
        ],
      ),
    );
  }
}
