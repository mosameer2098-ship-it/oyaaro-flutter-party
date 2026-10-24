import 'package:flutter/material.dart';
import 'package:oyaroo/core/catalog.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/core/ui.dart';
import 'package:oyaroo/handlers/seat_handler.dart';

class RoomSettingsScreen extends StatefulWidget {
  final String roomId;
  final int current;
  const RoomSettingsScreen({super.key, required this.roomId, required this.current});
  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  final _seat = SeatHandler();
  late int _count = widget.current;

  Future<void> _save() async {
    final r = await _seat.setSeatCount(widget.roomId, _count);
    if (!mounted) return;
    if (r is Ok<void>) {
      Navigator.pop(context);
    } else {
      showFailure(context, r);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room settings')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Seats: $_count (host ke seat ke saath)',
                style: const TextStyle(fontSize: 18)),
            Slider(
              value: _count.toDouble(),
              min: 1,
              max: Catalog.maxSeats.toDouble(),
              divisions: Catalog.maxSeats - 1,
              label: '$_count',
              onChanged: (v) => setState(() => _count = v.round()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _save, child: const Text('Save')),
          ],
        ),
      ),
    );
  }
}
