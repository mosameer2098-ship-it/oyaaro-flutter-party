import 'package:flutter/material.dart';

import '../../shared/user_stream.dart';
import '../handlers/family_handler.dart';
import '../models/family_info.dart';
import '../services/family_service.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key, required this.uid});
  final String uid;

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  final _service = FamilyService();
  late final FamilyHandler _handler = FamilyHandler(_service);
  final _users = UserStream();
  final _name = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _show(String? msg) {
    if (!mounted || msg == null) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _users.watch(widget.uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final familyId = snap.data!['familyId'] as String?;
          return familyId == null ? _noFamily() : _inFamily(familyId);
        },
      ),
    );
  }

  Widget _noFamily() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Family ka naam'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async => _show(await _handler.create(_name.text)),
            child: const Text('Family banao'),
          ),
          const Divider(height: 32),
          const Text('Family join karein', style: TextStyle(fontWeight: FontWeight.bold)),
          StreamBuilder<List<FamilyInfo>>(
            stream: _service.watchAll(),
            builder: (context, snap) {
              if (snap.hasError) return const Text('List load nahi hui');
              final list = snap.data ?? const [];
              if (snap.hasData && list.isEmpty) return const Text('Abhi koi family nahi hai');
              return Column(
                children: [
                  for (final f in list)
                    ListTile(
                      title: Text(f.name),
                      subtitle: Text('${f.memberCount}/${FamilyHandler.maxMembers} members'),
                      trailing: TextButton(
                        onPressed: () async => _show(await _handler.join(f.id)),
                        child: const Text('Join'),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      );

  Widget _inFamily(String familyId) => StreamBuilder<FamilyInfo?>(
        stream: _service.watchFamily(familyId),
        builder: (context, snap) {
          final f = snap.data;
          if (f == null) return const Center(child: CircularProgressIndicator());
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(f.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              Text('${f.memberCount}/${FamilyHandler.maxMembers} members'),
              const SizedBox(height: 12),
              const Text('Members', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final m in f.members.entries)
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(m.value),
                  trailing: m.key == f.leaderUid ? const Text('Leader') : null,
                ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () async => _show(await _handler.leave()),
                child: const Text('Family chhodo'),
              ),
            ],
          );
        },
      );
}
