// Event gifts kab chalenge. Dates badalne ke liye yahan badlein.
class EventConfig {
  static const name = 'Festival Fest';
  static final start = DateTime(2026, 10, 1);
  static final end = DateTime(2026, 12, 31, 23, 59);

  static bool isActive([DateTime? now]) {
    final n = now ?? DateTime.now();
    return !n.isBefore(start) && !n.isAfter(end);
  }
}
