import 'package:oyaroo/core/brand.dart';
import 'package:oyaroo/core/app_exception.dart';
import 'package:oyaroo/core/recharge_packages.dart';
import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/payment_gateway.dart';
import 'package:oyaroo/services/recharge_service.dart';

class RechargeHandler {
  final PaymentGateway _gateway;
  RechargeHandler({PaymentGateway? gateway})
      : _gateway = gateway ?? UnconfiguredGateway();

  // Online: gateway se payment, phir server par verify + credit
  Future<Result<void>> online(int amount) async {
    if (RechargePackages.byAmount(amount) == null) {
      return const Err<void>('Package galat hai');
    }
    return Result.guard(() async {
      final paymentId = await _gateway.pay(amount);
      if (paymentId == null) throw const AppException('Payment cancel ho gaya');
      await RechargeService.confirmOnline(amount, paymentId);
    });
  }

  // Agent: apne stock se user ko coins
  Future<Result<void>> agent(String toUid, int amount) async {
    if (toUid.length < 10) return const Err<void>('User ID sahi daalein');
    if (RechargePackages.byAmount(amount) == null) {
      return const Err<void>('Package galat hai');
    }
    return Result.guard(() => RechargeService.agentTransfer(toUid, amount));
  }

  Future<Result<void>> setRole(String uid, String role) async {
    if (uid.length < 10) return const Err<void>('User ID sahi daalein');
    return Result.guard(() => RechargeService.setRole(uid, role));
  }

  Future<Result<void>> addStock(String agentUid, int coins) async {
    if (agentUid.length < 10) return const Err<void>('Agent ki User ID sahi daalein');
    if (coins <= 0) return const Err<void>('Coins 0 se zyada hon');
    return Result.guard(() => RechargeService.addStock(agentUid, coins));
  }
}
