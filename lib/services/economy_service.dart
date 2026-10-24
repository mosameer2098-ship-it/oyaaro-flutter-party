import 'package:cloud_functions/cloud_functions.dart';
import 'package:oyaroo/core/game_rules.dart';

// Sab economy badlav server par. Client sirf call karta hai.
class EconomyService {
  static final _fn = FirebaseFunctions.instance;

  static Future<void> sendGift({
    required String type,
    required String target,
    required String gift,
  }) async {
    await _fn.httpsCallable('sendGift').call({'type': type, 'target': target, 'gift': gift});
  }

  static Future<int> convertDiamonds(int amount) async {
    final r = await _fn.httpsCallable('convertDiamonds').call({'amount': amount});
    final data = Map<String, dynamic>.from(r.data as Map);
    return (data['coins'] as num).toInt();
  }

  static Future<GameOutcome> playGame({
    required String gameId,
    required int bet,
    int? pick,
    double? target,
    bool advanced = false,
    int draws = 1,
  }) async {
    final r = await _fn.httpsCallable('playGame').call({
      'gameId': gameId,
      'bet': bet,
      'pick': pick,
      'target': target,
      'advanced': advanced,
      'draws': draws,
    });
    final data = Map<String, dynamic>.from(r.data as Map);
    return GameOutcome((data['payout'] as num).toInt(), '${data['text']}');
  }

  static Future<void> sendBag({
    required String roomId,
    required int amount,
    required int users,
  }) async {
    await _fn.httpsCallable('sendBag').call({'roomId': roomId, 'amount': amount, 'users': users});
  }

  static Future<int> claimBag(String bagId) async {
    final r = await _fn.httpsCallable('claimBag').call({'bagId': bagId});
    final data = Map<String, dynamic>.from(r.data as Map);
    return (data['diamonds'] as num).toInt();
  }
}
