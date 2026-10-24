// Hamara apna error: message seedha user ko dikhane layak hota hai
class AppException implements Exception {
  final String message;
  const AppException(this.message);
  @override
  String toString() => message;
}
