import 'package:flutter/material.dart';

import '../handlers/checkin_handler.dart';
import '../models/checkin_result.dart';
import '../services/checkin_service.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final _handler = CheckInHandler(CheckInService());
  int? _lastReward;
  int _streak = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daily Check-in')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Streak: $_streak din', style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text('Agla reward: ${CheckInResult.nextReward(_streak)} coins'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final err = await _handler.run((r) {
                  setState(() {
                    _lastReward = r.reward;
                    _streak = r.streak;
                  });
                });
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(err ?? 'Check-in ho gaya! +$_lastReward coins'),
                ));
              },
              child: const Text('Aaj ka check-in karo'),
            ),
          ],
        ),
      ),
    );
  }
}
