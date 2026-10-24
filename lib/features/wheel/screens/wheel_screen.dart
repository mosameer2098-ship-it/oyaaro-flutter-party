import 'dart:async';

import 'package:flutter/material.dart';

import '../handlers/wheel_handler.dart';
import '../models/wheel_round.dart';
import '../services/wheel_service.dart';

class WheelScreen extends StatefulWidget {
  const WheelScreen({super.key});

  @override
  State<WheelScreen> createState() => _WheelScreenState();
}

class _WheelScreenState extends State<WheelScreen> {
  final _service = WheelService();
  late final WheelHandler _handler = WheelHandler(_service);
  String? _segment;
  int _amount = 10;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Segment Wheel')),
      body: StreamBuilder<WheelRound?>(
        stream: _service.watchLatestRound(),
        builder: (context, snap) {
          final round = snap.data;
          final now = DateTime.now();
          final open = round != null && round.isBettingOpen(now);
          final left = round?.bettingLeft(now) ?? Duration.zero;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Text(
                  open ? 'Betting: ${left.inSeconds}s' : 'Betting band',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              if (round != null && round.settled && round.resultSegmentId != null)
                Center(child: Text('Result: ${WheelSegments.byId(round.resultSegmentId!)?.label ?? ''}')),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                children: [
                  for (final s in WheelSegments.all)
                    InkWell(
                      onTap: open ? () => setState(() => _segment = s.id) : null,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _segment == s.id ? Colors.amber : Colors.purple.shade100,
                        ),
                        child: Text('${s.label}\nx${s.multiplier}', textAlign: TextAlign.center),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final a in const [10, 50, 100, 500])
                    ChoiceChip(
                      label: Text('$a'),
                      selected: _amount == a,
                      onSelected: (_) => setState(() => _amount = a),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: open
                    ? () async {
                        final err = await _handler.bet(
                          round: round,
                          segmentId: _segment,
                          amount: _amount,
                        );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(err ?? 'Bet laga diya'),
                        ));
                      }
                    : null,
                child: const Text('Bet lagao'),
              ),
            ],
          );
        },
      ),
    );
  }
}
