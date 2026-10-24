import 'package:flutter/material.dart';

import '../../../shared/user_stream.dart';
import '../../services/vip_service.dart';
import '../catalog/vip_levels_catalog.dart';
import '../handlers/vip_center_handler.dart';
import '../logic/vip_rules.dart';
import '../widgets/privilege_grid.dart';
import '../widgets/vip_hero.dart';
import '../widgets/vip_identity_grid.dart';
import '../widgets/vip_status_bar.dart';

/// VIP Center: 9 tier tabs. Har tab par hero, identity items, privileges, aur status bar.
class VipCenterScreen extends StatefulWidget {
  const VipCenterScreen({super.key, required this.uid, this.onRecharge});

  final String uid;
  final VoidCallback? onRecharge;

  @override
  State<VipCenterScreen> createState() => _VipCenterScreenState();
}

class _VipCenterScreenState extends State<VipCenterScreen> {
  final _users = UserStream();
  late final VipCenterHandler _handler = VipCenterHandler(VipService());

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _users.watch(widget.uid),
      builder: (context, snap) {
        if (!snap.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
        final d = snap.data!;
        final current = ((d['vip'] as num?)?.toInt() ?? 0).clamp(0, VipLevelsCatalog.count);
        final points = (d['exp'] as num?)?.toInt() ?? 0;
        final coins = (d['coins'] as num?)?.toInt() ?? 0;
        final initial = current == 0 ? 0 : current - 1;

        return DefaultTabController(
          key: ValueKey('vip_$current'),
          length: VipLevelsCatalog.count,
          initialIndex: initial,
          child: Scaffold(
            backgroundColor: const Color(0xFF0E0718),
            appBar: AppBar(
              backgroundColor: const Color(0xFF0E0718),
              title: const Text('VIP'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [for (final l in VipLevelsCatalog.all) Tab(text: 'VIP ${l.level}')],
              ),
            ),
            body: TabBarView(
              children: [
                for (final l in VipLevelsCatalog.all)
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Center(child: VipHero(level: l)),
                      const SizedBox(height: 12),
                      Center(
                        child: Text('VIP ${l.level}  ${l.name}',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                      const SizedBox(height: 16),
                      const Text('Identity', style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      VipIdentityGrid(level: l),
                      const SizedBox(height: 16),
                      Text('${VipRules.privilegesUpTo(l.level).length} exclusive privileges',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 8),
                      PrivilegeGrid(tabLevel: l.level, userLevel: current, accent: l.accent),
                      const SizedBox(height: 16),
                      if (current < l.level)
                        ElevatedButton(
                          onPressed: () async {
                            final err = await _handler.buy(
                              currentLevel: current,
                              target: l.level,
                              points: points,
                              coins: coins,
                            );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(err ?? 'VIP ${l.level} mil gaya!'),
                            ));
                          },
                          child: Text('VIP ${l.level} lo (${l.price} coins)'),
                        ),
                      const SizedBox(height: 80),
                    ],
                  ),
              ],
            ),
            bottomNavigationBar: VipStatusBar(
              currentLevel: current,
              points: points,
              onRecharge: widget.onRecharge ?? () {},
            ),
          ),
        );
      },
    );
  }
}
