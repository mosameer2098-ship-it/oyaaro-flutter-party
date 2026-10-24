enum RewardKind {
  badge,
  coins,
  medal,
  frame,
  theme,
  vehicle,
  customId,
  background,
  superMic,
  openingPage,
  entrance,
}

class LevelReward {
  const LevelReward({
    required this.kind,
    required this.level,
    this.coins = 0,
    this.stars = 0,
    this.digits = 0,
    this.days = 0,
  });

  final RewardKind kind;
  final int level;
  final int coins; // coins reward ke liye
  final int stars; // medal / frame / vehicle rarity
  final int digits; // custom ID ke liye
  final int days; // validity

  /// Claim track karne ki unique key. Server par bhi isi format.
  String get key => '${kind.name}_$level';
}
