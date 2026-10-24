import 'package:flutter/material.dart';

import '../../shared/user_stream.dart';
import '../../themes/catalog/theme_catalog.dart';

/// Mere items: owned themes, frames, VIP, family. Sab users doc se.
class MyItemsScreen extends StatelessWidget {
  const MyItemsScreen({super.key, required this.uid});
  final String uid;

  @override
  Widget build(BuildContext context) {
    final users = UserStream();
    return Scaffold(
      appBar: AppBar(title: const Text('My Items')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: users.watch(uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final themes = ((d['ownedThemes'] as List?) ?? const []).whereType<String>().toList();
          final frames = ((d['ownedFrames'] as List?) ?? const []).length;
          final vip = (d['vip'] as num?)?.toInt() ?? 0;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              ListTile(title: const Text('VIP'), trailing: Text(vip == 0 ? 'Nahi' : 'VIP $vip')),
              ListTile(title: const Text('Frames'), trailing: Text('$frames')),
              const Divider(),
              const Text('Themes', style: TextStyle(fontWeight: FontWeight.bold)),
              for (final id in themes)
                ListTile(title: Text(ThemeCatalog.byId(id)?.name ?? id)),
              if (themes.isEmpty) const Text('Abhi koi theme nahi'),
            ],
          );
        },
      ),
    );
  }
}
