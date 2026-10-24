import 'package:flutter/material.dart';

import '../../shared/user_stream.dart';
import '../catalog/vip_catalog.dart';
import '../handlers/vip_handler.dart';
import '../services/vip_service.dart';

class VipShopScreen extends StatefulWidget {
  const VipShopScreen({super.key, required this.uid});
  final String uid;

  @override
  State<VipShopScreen> createState() => _VipShopScreenState();
}

class _VipShopScreenState extends State<VipShopScreen> {
  final _handler = VipHandler(VipService());
  final _users = UserStream();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VIP')),
      body: StreamBuilder<Map<String, dynamic>>(
        stream: _users.watch(widget.uid),
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final d = snap.data!;
          final vip = (d['vip'] as num?)?.toInt() ?? 0;
          final exp = (d['exp'] as num?)?.toInt() ?? 0;
          final coins = (d['coins'] as num?)?.toInt() ?? 0;
          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Text('Points: $exp   |   ${vip == 0 ? 'Koi VIP nahi' : 'VIP $vip'}'),
              const SizedBox(height: 10),
              for (final t in VipCatalog.all)
                Container(
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
                      Text('Entry: ${t.effect}', style: const TextStyle(color: Colors.white)),
                      Text('Points: ${t.points}  |  Price: ${t.price}',
                          style: const TextStyle(color: Colors.white)),
                      const SizedBox(height: 8),
                      if (vip >= t.level)
                        const Text('Active', style: TextStyle(color: Colors.white))
                      else
                        ElevatedButton(
                          onPressed: () async {
                            final err = await _handler.buy(
                                currentVip: vip, exp: exp, coins: coins, level: t.level);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(err ?? 'VIP ${t.level} mil gaya!'),
                            ));
                          },
                          child: const Text('Buy'),
                        ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
