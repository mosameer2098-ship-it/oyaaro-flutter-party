import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/level_service.dart';

class LevelHandler {
  Future<Result<void>> claim(int milestone) => Result.guard(() => LevelService.claim(milestone));
  Future<Result<void>> equip(int milestone) => Result.guard(() => LevelService.equip(milestone));
}
