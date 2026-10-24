import 'package:flutter/material.dart';

import '../handlers/music_handler.dart';
import '../models/music_track.dart';
import '../services/music_service.dart';

class MusicScreen extends StatefulWidget {
  const MusicScreen({super.key});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final _service = MusicService();
  late final MusicHandler _handler = MusicHandler(_service);
  String? _playingId;

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _toggle(MusicTrack t) async {
    final err = _playingId == t.id ? await _handler.stop() : await _handler.play(t);
    if (!mounted) return;
    setState(() => _playingId = err == null && _playingId != t.id ? t.id : null);
    if (err != null) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Music')),
      body: StreamBuilder<List<MusicTrack>>(
        stream: _service.watchTracks(),
        builder: (context, snap) {
          if (snap.hasError) return const Center(child: Text('Tracks load nahi hue'));
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final list = snap.data!;
          if (list.isEmpty) return const Center(child: Text('Abhi koi track nahi hai (admin add karega)'));
          return ListView(
            children: [
              for (final t in list)
                ListTile(
                  leading: Icon(_playingId == t.id ? Icons.pause_circle : Icons.play_circle),
                  title: Text(t.title),
                  subtitle: Text(t.artist),
                  onTap: () => _toggle(t),
                ),
            ],
          );
        },
      ),
    );
  }
}
