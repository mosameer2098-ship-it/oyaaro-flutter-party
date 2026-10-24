import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/helpers/family_helper.dart';
import 'package:oyaroo/services/family_service.dart';

class FamilyHandler {
  Future<Result<void>> create(String rawName) async {
    final name = rawName.trim();
    final err = FamilyHelper.nameError(name);
    if (err != null) return Err<void>(err);
    return Result.guard(() => FamilyService.create(name));
  }

  Future<Result<void>> join(String id) => Result.guard(() => FamilyService.join(id));
  Future<Result<void>> leave() => Result.guard(() => FamilyService.leave());
}
