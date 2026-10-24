import 'package:oyaroo/core/result.dart';
import 'package:oyaroo/services/user_service.dart';

class ProfileHandler {
  Future<Result<void>> ensureUser() => Result.guard(() => UserService.ensureUser());

  Future<Result<void>> updateProfile(String rawName, String rawBio) async {
    final name = rawName.trim();
    final bio = rawBio.trim();
    if (name.isEmpty) return const Err<void>('Naam khali nahi ho sakta');
    if (name.length > 30) return const Err<void>('Naam 30 letters se chhota ho');
    if (bio.length > 150) return const Err<void>('Bio 150 letters se chhota ho');
    return Result.guard(() => UserService.updateProfile(name: name, bio: bio));
  }
}
