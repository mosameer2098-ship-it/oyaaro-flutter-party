class MusicTrack {
  const MusicTrack({required this.id, required this.title, required this.artist, required this.url});

  final String id;
  final String title;
  final String artist;
  final String url; // https only (admin music_tracks collection se)

  static MusicTrack? fromMap(String id, Map<String, dynamic> d) {
    final url = d['url'] as String?;
    if (url == null || !url.startsWith('https://')) return null;
    return MusicTrack(
      id: id,
      title: d['title'] as String? ?? 'Track',
      artist: d['artist'] as String? ?? '',
      url: url,
    );
  }
}
