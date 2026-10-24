class FamilyInfo {
  const FamilyInfo({
    required this.id,
    required this.name,
    required this.leaderUid,
    required this.memberCount,
    required this.members,
  });

  final String id;
  final String name;
  final String leaderUid;
  final int memberCount;
  final Map<String, String> members; // uid -> naam

  static FamilyInfo fromMap(String id, Map<String, dynamic> d) => FamilyInfo(
        id: id,
        name: d['name'] as String? ?? 'Family',
        leaderUid: d['leaderUid'] as String? ?? '',
        memberCount: (d['memberCount'] as num?)?.toInt() ?? 0,
        members: ((d['members'] as Map?) ?? const {})
            .map((k, v) => MapEntry(k.toString(), v.toString())),
      );
}
