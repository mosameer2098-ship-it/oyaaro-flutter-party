// Input check. Dusre helpers isi ko call karte hain.
class ValidationHelper {
  static String? nameError(String raw, {int min = 1, int max = 30}) {
    final n = raw.trim();
    if (n.length < min) {
      return min == 1 ? 'Naam khali nahi ho sakta' : 'Naam $min letters se bada ho';
    }
    if (n.length > max) return 'Naam $max letters se chhota ho';
    return null;
  }

  static String? uidError(String raw) =>
      raw.trim().length < 10 ? 'User ID sahi daalein' : null;

  static String? positiveInt(int v, String label) =>
      v <= 0 ? '$label 0 se zyada hon' : null;
}
