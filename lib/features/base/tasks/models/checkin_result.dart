class CheckInResult {
  const CheckInResult({required this.reward, required this.streak});
  final int reward;
  final int streak;

  /// Streak ke hisaab se agle din ka reward (max 7 din)
  static int nextReward(int currentStreak) => 50 * (currentStreak + 1).clamp(1, 7);
}
