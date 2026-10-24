/// Feature layer ka error. Message seedha user ko dikhane layak hota hai.
class FeatureException implements Exception {
  const FeatureException(this.message);
  final String message;
  @override
  String toString() => message;
}
