import 'package:oyaroo/helpers/validation_helper.dart';
import 'package:oyaroo/services/family_service.dart';

class FamilyHelper {
  static String? nameError(String name) =>
      ValidationHelper.nameError(name, min: 3, max: 20);

  static int slotsLeft(int memberCount) => FamilyService.maxMembers - memberCount;

  static bool isFull(int memberCount) => memberCount >= FamilyService.maxMembers;
}
