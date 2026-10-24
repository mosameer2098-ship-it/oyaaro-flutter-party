import 'package:oyaroo/core/result.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/recharge_packages.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/recharge_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/services/recharge_service.dart';

// Agent ka desk: user ID daal kar coins bhejna
class AgentDeskScreen extends StatefulWidget {
  const AgentDeskScreen({super.key});
  @override
  State<AgentDeskScreen> createState() => _AgentDeskScreenState();
}

class _AgentDeskScreenState extends State<AgentDeskScreen> {
  final _handler = RechargeHandler();
  final _user = TextEditingController();
  int _amount = RechargePackages.all.first.amount;
  bool _busy = false;

  @override
  void dispose() {
    _user.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    setState(() => _busy = true);
    final r = await _handler.agent(_user.text.trim(), _amount);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r is Ok<void>) {
      _user.clear();
      showMessage(context, 'Coins bhej diye!');
    } else {
      showFailure(context, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agent Desk')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: RechargeService.myStock(),
            builder: (context, snap) {
              final stock = (snap.data?.data()?['stock'] ?? 0) as num;
              return Text('Aapka stock: ${formatCoins(stock)} ${Brand.coinName}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _user,
            decoration: const InputDecoration(labelText: 'User ID'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final p in RechargePackages.all)
                ChoiceChip(
                  label: Text('₹${p.amount} (${formatCoins(p.coins)})'),
                  selected: _amount == p.amount,
                  onSelected: (_) => setState(() => _amount = p.amount),
                ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _busy ? null : _send,
            child: const Text('Coins bhejo'),
          ),
        ],
      ),
    );
  }
}
