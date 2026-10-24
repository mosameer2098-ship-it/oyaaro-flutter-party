/// Account role. Staff roles ka frame fixed hota hai (user change nahi kar sakta).
enum AccountRole { user, agent, support, admin, superAdmin, bd, superBd }

extension AccountRoleX on AccountRole {
  static AccountRole parse(String? value) => switch (value) {
        'agent' => AccountRole.agent,
        'support' => AccountRole.support,
        'admin' => AccountRole.admin,
        'superadmin' => AccountRole.superAdmin,
        'bd' => AccountRole.bd,
        'superbd' => AccountRole.superBd,
        _ => AccountRole.user,
      };

  bool get isStaff => switch (this) {
        AccountRole.support ||
        AccountRole.admin ||
        AccountRole.superAdmin ||
        AccountRole.bd ||
        AccountRole.superBd =>
          true,
        _ => false,
      };

  /// Staff role ka frame id. Non-staff ke liye null.
  String? get roleFrameId => switch (this) {
        AccountRole.support => 'role_support',
        AccountRole.admin => 'role_admin',
        AccountRole.superAdmin => 'role_superadmin',
        AccountRole.bd => 'role_bd',
        AccountRole.superBd => 'role_superbd',
        _ => null,
      };
}
