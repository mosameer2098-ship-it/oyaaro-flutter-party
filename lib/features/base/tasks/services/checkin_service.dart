import '../../../shared/callable_helper.dart';
import '../models/checkin_result.dart';

class CheckInService {
  CheckInService({CallableHelper? callable}) : _call = callable ?? CallableHelper();

  final CallableHelper _call;

  Future<CheckInResult> checkIn() async {
    final res = await _call.call('checkIn');
    return CheckInResult(
      reward: (res['reward'] as num?)?.toInt() ?? 0,
      streak: (res['streak'] as num?)?.toInt() ?? 0,
    );
  }
}
