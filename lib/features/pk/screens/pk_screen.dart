import 'dart:async';

import 'package:flutter/material.dart';

import '../handlers/pk_handler.dart';
import '../models/pk_session.dart';
import '../services/pk_service.dart';

class PkScreen extends StatefulWidget {
  const PkScreen({super.key, required this.roomId});
  final String roomId;

  @override
  State<PkScreen> createState() => _PkScreenState();
}

class _PkScreenState extends State<PkScreen> {
  final _service = PkService();
  late final PkHandler _handler = PkHandler(_service);
  final _opponent = TextEditingController();
  int _minutes = 5;
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
    _opponent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group PK')),
      body: StreamBuilder<PkSession?>(
        stream: _service.watchRoomSession(widget.roomId),
        builder: (context, snap) {
          final s = snap.data;
          if (s == null || !s.active) return _startForm();
          final total = (s.scoreA + s.scoreB).clamp(1, 1 << 30);
          final left = s.remaining(DateTime.now());
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Bacha time: ${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                LinearProgressIndicator(value: s.scoreA / total, minHeight: 14),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text('Room A: ${s.scoreA}'), Text('Room B: ${s.scoreB}')],
                ),
                const SizedBox(height: 8),
                const Text('Gift jo room mein aayenge, wo score mein jaayenge.'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _startForm() => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _opponent,
            decoration: const InputDecoration(labelText: 'Opponent Room ID'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              for (final m in PkHandler.allowedMinutes)
                ChoiceChip(
                  label: Text('$m min'),
                  selected: _minutes == m,
                  onSelected: (_) => setState(() => _minutes = m),
                ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final err = await _handler.start(
                roomId: widget.roomId,
                opponentRoomId: _opponent.text.trim(),
                minutes: _minutes,
              );
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(err ?? 'PK shuru ho gaya!'),
              ));
            },
            child: const Text('PK shuru karo'),
          ),
        ],
      );
}
