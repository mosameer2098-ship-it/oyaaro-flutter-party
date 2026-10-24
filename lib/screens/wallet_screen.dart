import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/core/wallet_rules.dart';
import 'package:oyaroo/handlers/wallet_handler.dart';
import 'package:oyaroo/helpers/formatters.dart';
import 'package:oyaroo/screens/recharge_screen.dart';
import 'package:oyaroo/services/user_service.dart';

// Wallet: do tab. Coin (khareeda hua) aur Diamond (kamaya hua).
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _uid = FirebaseAuth.instance.currentUser!.uid;
  final _handler = WalletHandler();
  final _amount = TextEditingController(text: '100');

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
          bottom: const TabBar(tabs: [Tab(text: 'Coin'), Tab(text: 'Diamond')]),
        ),
        body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: UserService.profileStream(_uid),
          builder: (context, snap) {
            final d = snap.data?.data() ?? {};
            final coins = (d['coins'] ?? 0) as num;
            final diamonds = (d['diamonds'] ?? 0) as num;
            return TabBarView(
              children: [
                _coinTab(context, coins),
                _diamondTab(context, diamonds),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _coinTab(BuildContext context, num coins) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('${formatCoins(coins)} ${Brand.coinName}',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text(
              'Coin sirf khareedne se milte hain (admin ya agent se). '
              'Games aur gifts mein kharch hote hain. Ye cash mein wapas nahi hote.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const RechargeScreen())),
              child: const Text('Coin khareedein'),
            ),
          ],
        ),
      );

  Widget _diamondTab(BuildContext context, num diamonds) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Text('${formatCoins(diamonds)} Diamond',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              'Gift milne aur game jeetne par diamond milte hain. '
              '${WalletRules.convertDiamonds} diamond = ${WalletRules.convertCoins} ${Brand.coinName}. '
              'Diamond cash nahi hota.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kitne diamond convert karein (${WalletRules.convertDiamonds} ke multiple)',
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => reportResult(
                context,
                _handler.convert(int.tryParse(_amount.text.trim()) ?? 0),
                successMsg: 'Diamond coin mein convert ho gaye',
              ),
              child: Text('${Brand.coinName} mein convert karo'),
            ),
          ],
        ),
      );
}
