import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:oyaroo/core/game_rules.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/bag_handler.dart';
import 'package:oyaroo/handlers/game_handler.dart';
import 'package:oyaroo/helpers/coin_helper.dart';
import 'package:oyaroo/helpers/game_helper.dart';
import 'package:oyaroo/services/user_service.dart';

// Ek screen sab games ke liye. Controls game ki kind ke hisaab se badalte hain.
class GameScreen extends StatefulWidget {
  final GameSpec game;
  final String? roomId; // lucky bag ke liye
  const GameScreen({super.key, required this.game, this.roomId});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _handler = GameHandler();
  final _bag = BagHandler();
  final _bet = TextEditingController(text: '10');
  late final String _uid;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _balance;
  double _target = 2.0;
  bool _advanced = false;
  int _draws = 1;
  int _cell = 1;
  int _bagAmount = GameHelper.bagAmounts.first;
  int _bagUsers = GameHelper.bagUsers.first;
  bool _busy = false;
  String _result = '';

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser!.uid;
    _balance = UserService.profileStream(_uid);
  }

  @override
  void dispose() {
    _bet.dispose();
    super.dispose();
  }

  int get _betValue => int.tryParse(_bet.text.trim()) ?? 0;

  // Kitne coin katenge (advanced slot 2x, wheel draws ke hisaab se)
  int get _cost {
    if (widget.game.kind == GameKind.slot && _advanced) return _betValue * 2;
    if (widget.game.kind == GameKind.wheel) return _betValue * _draws;
    return _betValue;
  }

  Future<void> _run({int? pick}) async {
    setState(() => _busy = true);
    final r = await _handler.play(
      widget.game,
      _betValue,
      pick: pick ?? (widget.game.kind == GameKind.fruit ? _cell : null),
      target: _target,
      advanced: _advanced,
      draws: _draws,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    if (r is Ok<GameOutcome>) {
      setState(() => _result = r.value.text);
      showMessage(context, GameHelper.resultLabel(r.value.payout));
    } else {
      showFailure(context, r);
    }
  }

  Future<void> _sendBag() async {
    final roomId = widget.roomId;
    if (roomId == null) {
      showMessage(context, 'Room ke andar se bag bhejein');
      return;
    }
    setState(() => _busy = true);
    final r = await _bag.send(roomId, _bagAmount, _bagUsers);
    if (!mounted) return;
    setState(() => _busy = false);
    if (r is Ok<void>) {
      showMessage(context, 'Lucky Bag room mein bhej diya');
      Navigator.pop(context);
    } else {
      showFailure(context, r);
    }
  }

  Widget _chips<T>(List<T> items, T selected, String Function(T) label, void Function(T) onTap) =>
      Wrap(
        spacing: 8,
        children: [
          for (final i in items)
            ChoiceChip(
              label: Text(label(i)),
              selected: selected == i,
              onSelected: (_) => setState(() => onTap(i)),
            ),
        ],
      );

  Widget _playButton(String label, {VoidCallback? onTap}) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _busy ? null : (onTap ?? () => _run()),
          child: Text(label),
        ),
      );

  Widget _controls() {
    final g = widget.game;
    switch (g.kind) {
      case GameKind.slot:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mode'),
            _chips<bool>([false, true], _advanced, (a) => a ? 'Advanced (2x)' : 'Basic',
                (a) => _advanced = a),
            const SizedBox(height: 8),
            Text('Symbols: ${g.symbols.join(', ')}'),
            const SizedBox(height: 12),
            _playButton('Spin (${CoinHelper.format(_cost)} coins)'),
          ],
        );
      case GameKind.wheel:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _chips<int>([1, 10], _draws, (d) => d == 1 ? '1 Draw' : '10 Draws', (d) => _draws = d),
            const SizedBox(height: 8),
            Text('Prizes: ${g.prizes.map((m) => 'x$m').join(', ')}'),
            const SizedBox(height: 12),
            _playButton('Ghumao (${CoinHelper.format(_cost)} coins)'),
          ],
        );
      case GameKind.crash:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Target chuno'),
            _chips<double>(GameHelper.crashTargets, _target, (t) => '${t}x', (t) => _target = t),
            const SizedBox(height: 12),
            _playButton('Play'),
          ],
        );
      case GameKind.fruit:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ek cell chuno'),
            const SizedBox(height: 8),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              children: [
                for (var i = 1; i <= 12; i++)
                  InkWell(
                    onTap: () => setState(() => _cell = i),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: _cell == i ? Colors.amber.shade300 : Colors.green.shade100,
                      ),
                      child: Text('$i', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            _playButton('Cell $_cell par bet lagao'),
          ],
        );
      case GameKind.bagSend:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Amount'),
            _chips<int>(GameHelper.bagAmounts, _bagAmount, (a) => CoinHelper.format(a),
                (a) => _bagAmount = a),
            const SizedBox(height: 8),
            const Text('Kitne users claim karenge'),
            _chips<int>(GameHelper.bagUsers, _bagUsers, (u) => '$u', (u) => _bagUsers = u),
            const SizedBox(height: 12),
            _playButton('Bag bhejo (${CoinHelper.format(_bagAmount)} coins)', onTap: _sendBag),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBag = widget.game.kind == GameKind.bagSend;
    return Scaffold(
      appBar: AppBar(title: Text(widget.game.name)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: _balance,
            builder: (context, snap) {
              final coins = (snap.data?.data()?['coins'] ?? 0) as num;
              return Text('Coins: ${CoinHelper.label(coins)}',
                  style: const TextStyle(fontWeight: FontWeight.bold));
            },
          ),
          const SizedBox(height: 8),
          Text(widget.game.subtitle),
          const SizedBox(height: 16),
          if (!isBag) ...[
            TextField(
              controller: _bet,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Bet (${GameHelper.minBet} se ${GameHelper.maxBet})',
              ),
            ),
            const SizedBox(height: 16),
          ],
          _controls(),
          const SizedBox(height: 24),
          Text(_result, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
