import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../handlers/referral_handler.dart';
import '../services/referral_service.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _service = ReferralService();
  late final ReferralHandler _handler = ReferralHandler(_service);
  final _code = TextEditingController();

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invite & Referral')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          StreamBuilder<String?>(
            stream: _service.watchMyCode(),
            builder: (context, snap) {
              final code = snap.data;
              if (code == null) {
                return ElevatedButton(
                  onPressed: () async {
                    await _service.ensureCode();
                  },
                  child: const Text('Mera referral code banao'),
                );
              }
              return ListTile(
                title: Text(code, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                subtitle: const Text('Dost ko ye code do. Dono ko coins milenge.'),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copy ho gaya')));
                  },
                ),
              );
            },
          ),
          const Divider(height: 32),
          TextField(
            controller: _code,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Kisi ka referral code daalein'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () async {
              final err = await _handler.redeem(_code.text);
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err ?? 'Referral use ho gaya, coins mil gaye!'),
              ));
            },
            child: const Text('Use karo'),
          ),
        ],
      ),
    );
  }
}
