import '../../shared/callable_helper.dart';

/// VIP khareedna server par. Points aur coins server check karta hai.
class VipService {
  VipService({CallableHelper? callable}) : _call = callable ?? CallableHelper();

  final CallableHelper _call;

  Future<void> buy(int level) async {
    await _call.call('buyVip', {'level': level});
  }
}
