import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/gift_catalog.dart';
import 'package:oyaroo/helpers/gift_helper.dart';
import 'package:oyaroo/services/user_service.dart';

// Har gift ka medal aur aapne kitne baar bheja
class MedalScreen extends StatelessWidget {
  const MedalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Medals')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(uid),
        builder: (context, snap) {
          final medals = Map<String, dynamic>.from(snap.data?.data()?['medals'] ?? {});
          final total = medals.values.fold<int>(0, (a, b) => a + (b as int));
          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Total medals: $total',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              for (final g in GiftCatalog.all)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: g.c1,
                    child: Icon(g.icon, color: Colors.white),
                  ),
                  title: Text(g.name),
                  subtitle: Text('${GiftHelper.categoryName(g.category)}  |  ${GiftHelper.tierName(g.tier)}'),
                  trailing: Text('x${medals[g.name] ?? 0}',
                      style: TextStyle(
                          color: (medals[g.name] ?? 0) > 0 ? Colors.black : Colors.grey)),
                ),
            ],
          );
        },
      ),
    );
  }
}
