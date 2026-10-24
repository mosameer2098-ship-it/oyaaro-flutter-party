import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/cp_service.dart';

class CpHandler {
  Future<Result<void>> request(String convId) => Result.guard(() => CpService.request(convId));
  Future<Result<void>> accept(String convId) => Result.guard(() => CpService.accept(convId));
}
