import 'package:flutter/material.dart';

import '../../shared/user_stream.dart';
import '../catalog/theme_catalog.dart';
import '../handlers/theme_handler.dart';
import '../models/theme_spec.dart';
import '../services/theme_service.dart';

class ThemeStoreScreen extends StatefulWidget {
  const ThemeStoreScreen({super.key, required this.uid});
  final String uid;

  @override
  State<ThemeStoreScreen> createState() => _ThemeStoreScreenState();
}

class _ThemeStoreScreenState extends State<ThemeStoreScreen> {
  final _handler = ThemeHandler(ThemeService());
  final _users = UserStream();

  Future<void> _run(Future<String?> action, String okMsg) async {
    final err = await action;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err ?? okMsg)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Themes'),
          bottom: const TabBar(tabs: [Tab(text: 'Room'), Tab(text: 'Couple')]),
        ),
        body: StreamBuilder<Map<String, dynamic>>(
          stream: _users.watch(widget.uid),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final d = snap.data!;
            final owned = ((d['ownedThemes'] as List?) ?? const []).whereType<String>().toList();
            final roomEq = d['equippedRoomTheme'] as String?;
            final coupleEq = d['equippedCoupleTheme'] as String?;
            return TabBarView(children: [
              _grid(ThemeCatalog.room, owned, roomEq, () {}),
              _grid(ThemeCatalog.couple, owned, coupleEq, () {}),
            ]);
          },
        ),
      ),
    );
  }

  Widget _grid(List<ThemeSpec> list, List<String> owned, String? equipped, VoidCallback unusedCallback) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.9,
      ),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final t = list[i];
        final isOwned = ThemeHandler.isOwned(owned, t.id);
        final isEquipped = equipped == t.id;
        return Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: t.colors),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(isEquipped ? 'Equipped' : isOwned ? 'Owned' : '${t.price} coins',
                  style: const TextStyle(color: Colors.white70)),
              ElevatedButton(
                onPressed: () {
                  if (isOwned) {
                    _run(_handler.equip(t.id), 'Theme laga diya');
                  } else {
                    _run(_handler.buy(t.id), 'Theme khareed liya');
                  }
                },
                child: Text(isOwned ? 'Equip' : 'Buy'),
              ),
            ],
          ),
        );
      },
    );
  }
}
