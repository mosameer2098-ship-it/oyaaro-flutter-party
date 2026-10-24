import 'package:cloud_firestore/cloud_firestore.dart';

class PkSession {
  const PkSession({
    required this.id,
    required this.roomA,
    required this.roomB,
    required this.scoreA,
    required this.scoreB,
    required this.endsAt,
    required this.active,
  });

  final String id;
  final String roomA;
  final String roomB;
  final int scoreA;
  final int scoreB;
  final DateTime endsAt;
  final bool active;

  Duration remaining(DateTime now) {
    final r = endsAt.difference(now);
    return r.isNegative ? Duration.zero : r;
  }

  static PkSession fromMap(String id, Map<String, dynamic> d) => PkSession(
        id: id,
        roomA: d['roomA'] as String? ?? '',
        roomB: d['roomB'] as String? ?? '',
        scoreA: (d['scoreA'] as num?)?.toInt() ?? 0,
        scoreB: (d['scoreB'] as num?)?.toInt() ?? 0,
        endsAt: (d['endsAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
        active: d['active'] == true,
      );
}
