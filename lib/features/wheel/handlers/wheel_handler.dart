import '../../shared/feature_action.dart';
import '../models/wheel_round.dart';
import '../services/wheel_service.dart';

class WheelHandler {
  WheelHandler(this._service);

  final WheelService _service;

  static const minBet = 1;
  static const maxBet = 1000;

  /// Client check. Server bhi same check karta hai.
  static String? validateBet({
    required WheelRound? round,
    required String? segmentId,
    required int amount,
    required DateTime now,
  }) {
    if (round == null) return 'Abhi koi round nahi hai';
    if (!round.isBettingOpen(now)) return 'Betting band ho chuki hai, agle round ka intezaar karein';
    if (segmentId == null || WheelSegments.byId(segmentId) == null) return 'Segment chuniye';
    if (amount < minBet || amount > maxBet) return 'Bet $minBet se $maxBet ke beech ho';
    return null;
  }

  Future<String?> bet({
    required WheelRound? round,
    required String? segmentId,
    required int amount,
    DateTime? now,
  }) {
    final v = validateBet(round: round, segmentId: segmentId, amount: amount, now: now ?? DateTime.now());
    if (v != null) return Future.value(v);
    return FeatureAction.run(() => _service.placeBet(
          roundId: round!.id,
          segmentId: segmentId!,
          amount: amount,
        ));
  }
}
