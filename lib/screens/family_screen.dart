import 'package:oyaroo/core/brand.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/family_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/services/family_service.dart';
import 'package:oyaroo/services/user_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});
  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _handler = FamilyHandler();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: UserService.profileStream(_uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final famId = snap.data!.data()?['familyId'] as String?;
          return famId == null ? _noFamily() : _inFamily(famId);
        },
      ),
    );
  }

  Widget _noFamily() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Aap kisi family mein nahi ho.', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            decoration: InputDecoration(
              labelText: 'Family ka naam (3-20 letters)',
              helperText: 'Banane ka kharch: ${FamilyService.createCost} ${Brand.coinName}',
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => reportResult(context, _handler.create(_name.text),
                successMsg: 'Family ban gayi!'),
            child: const Text('Family banao'),
          ),
          const Divider(height: 32),
          const Text('Family join karein', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FamilyService.allFamilies(),
            builder: (context, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final docs = snap.data!.docs;
              if (docs.isEmpty) return const Text('Abhi koi family nahi hai');
              return Column(
                children: [
                  for (final d in docs)
                    ListTile(
                      title: Text('${d.data()['name'] ?? ''}'),
                      subtitle: Text(
                          '${d.data()['memberCount'] ?? 0} / ${FamilyService.maxMembers} members'),
                      trailing: TextButton(
                        onPressed: () => reportResult(context, _handler.join(d.id),
                            successMsg: 'Family join ho gayi!'),
                        child: const Text('Join'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      );

  Widget _inFamily(String famId) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FamilyService.family(famId),
        builder: (context, snap) {
          final d = snap.data?.data();
          if (d == null) return const Center(child: CircularProgressIndicator());
          final members = Map<String, dynamic>.from(d['members'] ?? {}).values.toList();
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('${d['name'] ?? ''}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('Members: ${formatCoins((d['memberCount'] ?? 0) as num)} / ${FamilyService.maxMembers}'),
              const SizedBox(height: 12),
              const Text('Members', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final m in members) ListTile(leading: const Icon(Icons.person), title: Text('$m')),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => reportResult(context, _handler.leave(),
                    successMsg: 'Aap family chhod chuke ho'),
                child: const Text('Family chhodo'),
              ),
            ],
          );
        },
      );
}
