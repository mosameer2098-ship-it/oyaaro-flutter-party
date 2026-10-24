/// CP bond: ek DM conversation par. Level 1..15 bond messages se.
class CoupleBond {
  const CoupleBond({
    required this.convId,
    required this.status,
    required this.requestedBy,
    required this.exp,
    required this.coupleThemeId,
  });

  static const maxLevel = 15;
  static const titles = [
    'Jaan-Pehchan', 'Dost', 'Achha Dost', 'Pakka Dost', 'Jigri Dost', 'Yaar', 'Bestie', 'Shaan',
    'Sirtaaj', 'Mehboob', 'Hamsafar', 'Rooh', 'Dil ka Tukda', 'Soulmate', 'Legend',
  ];

  final String convId;
  final String status; // none | pending | active
  final String? requestedBy;
  final int exp;
  final String? coupleThemeId;

  bool get isActive => status == 'active';
  bool get isPending => status == 'pending';

  int get level {
    var l = 1;
    while (l < maxLevel && exp >= requiredExp(l + 1)) {
      l++;
    }
    return l;
  }

  static int requiredExp(int level) => 20 * (level - 1) * level ~/ 2;

  String get title => titles[level - 1];

  static CoupleBond fromMap(String convId, Map<String, dynamic> d) {
    final cp = (d['cp'] as Map?) ?? const {};
    return CoupleBond(
      convId: convId,
      status: cp['status'] as String? ?? 'none',
      requestedBy: cp['by'] as String?,
      exp: (d['cpExp'] as num?)?.toInt() ?? 0,
      coupleThemeId: d['coupleTheme'] as String?,
    );
  }
}
