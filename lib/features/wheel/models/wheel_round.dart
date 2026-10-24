import 'package:cloud_firestore/cloud_firestore.dart';

class WheelSegment {
  const WheelSegment({required this.id, required this.label, required this.multiplier});
  final String id;
  final String label;
  final int multiplier;
}

/// Sab segments. Server (wheel rounds) mein bhi same.
class WheelSegments {
  const WheelSegments._();
  static const all = <WheelSegment>[
    WheelSegment(id: 'apple', label: 'Apple', multiplier: 5),
    WheelSegment(id: 'mango', label: 'Mango', multiplier: 5),
    WheelSegment(id: 'melon', label: 'Melon', multiplier: 2),
    WheelSegment(id: 'pizza', label: 'Pizza', multiplier: 25),
    WheelSegment(id: 'burger', label: 'Burger', multiplier: 15),
    WheelSegment(id: 'fish', label: 'Fish', multiplier: 10),
    WheelSegment(id: 'berry', label: 'Berry', multiplier: 5),
    WheelSegment(id: 'lemon', label: 'Lemon', multiplier: 5),
  ];
  static WheelSegment? byId(String id) {
    for (final s in all) {
      if (s.id == id) return s;
    }
    return null;
  }
}

/// Ek shared round. Betting window ke andar sab bet lagate hain, phir result aata hai.
class WheelRound {
  const WheelRound({
    required this.id,
    required this.bettingEndsAt,
    required this.settled,
    required this.resultSegmentId,
  });

  final String id;
  final DateTime bettingEndsAt;
  final bool settled;
  final String? resultSegmentId;

  bool isBettingOpen(DateTime now) => !settled && now.isBefore(bettingEndsAt);

  Duration bettingLeft(DateTime now) {
    final d = bettingEndsAt.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  static WheelRound fromMap(String id, Map<String, dynamic> d) => WheelRound(
        id: id,
        bettingEndsAt: (d['bettingEndsAt'] as Timestamp?)?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
        settled: d['settled'] == true,
        resultSegmentId: d['resultSegmentId'] as String?,
      );
}
