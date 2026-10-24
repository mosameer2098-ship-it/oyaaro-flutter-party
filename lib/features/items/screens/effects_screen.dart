import 'package:flutter/material.dart';

import '../../vip/catalog/vip_catalog.dart';

/// Effects: VIP level ke hisaab se room entry effects. Unlock VIP se hota hai.
class EffectsScreen extends StatelessWidget {
  const EffectsScreen({super.key, required this.vip});
  final int vip;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Effects')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final t in VipCatalog.all)
            ListTile(
              leading: CircleAvatar(backgroundColor: t.c1),
              title: Text(t.effect),
              subtitle: Text('VIP ${t.level} (${t.name})'),
              trailing: vip >= t.level ? const Icon(Icons.check, color: Colors.green) : const Icon(Icons.lock),
            ),
        ],
      ),
    );
  }
}
