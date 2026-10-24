import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/recharge_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/services/recharge_service.dart';

// Admin panel: roles, agent stock, aur recharge ka log
class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _handler = RechargeHandler();
  final _roleUid = TextEditingController();
  final _agentUid = TextEditingController();
  final _stock = TextEditingController();
  String _role = 'agent';

  @override
  void dispose() {
    _roleUid.dispose();
    _agentUid.dispose();
    _stock.dispose();
    super.dispose();
  }

  Widget _section(String title, List<Widget> children) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...children,
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _section('Role set karein', [
            TextField(controller: _roleUid, decoration: const InputDecoration(labelText: 'User ID')),
            DropdownButton<String>(
              value: _role,
              items: const [
                DropdownMenuItem(value: 'user', child: Text('user')),
                DropdownMenuItem(value: 'agent', child: Text('agent')),
                DropdownMenuItem(value: 'admin', child: Text('admin')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'agent'),
            ),
            ElevatedButton(
              onPressed: () => reportResult(context,
                  _handler.setRole(_roleUid.text.trim(), _role),
                  successMsg: 'Role save ho gaya'),
              child: const Text('Save role'),
            ),
          ]),
          _section('Agent stock badhayein', [
            TextField(controller: _agentUid, decoration: const InputDecoration(labelText: 'Agent User ID')),
            TextField(
              controller: _stock,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Kitne ${Brand.coinName}'),
            ),
            ElevatedButton(
              onPressed: () => reportResult(context,
                  _handler.addStock(_agentUid.text.trim(), int.tryParse(_stock.text) ?? 0),
                  successMsg: 'Stock badh gaya'),
              child: const Text('Stock add karo'),
            ),
          ]),
          _section('Recent recharges', [
            StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: RechargeService.recentRecharges(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Text('Abhi koi recharge nahi hai');
                return Column(
                  children: [
                    for (final d in docs)
                      ListTile(
                        dense: true,
                        title: Text(
                            '₹${d.data()['amount']}  |  ${formatCoins((d.data()['coins'] ?? 0) as num)} ${Brand.coinName}'),
                        subtitle: Text('${d.data()['method']}  ->  ${d.data()['toUid'] ?? d.data()['uid']}'),
                      ),
                  ],
                );
              },
            ),
          ]),
        ],
      ),
    );
  }
}
