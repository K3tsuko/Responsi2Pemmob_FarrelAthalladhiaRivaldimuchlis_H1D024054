/// Helper sederhana untuk memformat tanggal ke Bahasa Indonesia tanpa setup locale tambahan.
class DateFormatter {
  static const List<String> _days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _shortMonths = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Mengubah DateTime menjadi format label hari prakiraan (mis. "Hari Ini", "Besok", atau "Jumat").
  static String formatForecastDay(DateTime date, {int? index}) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';
    return _days[date.weekday - 1];
  }

  /// Mengubah DateTime menjadi format tanggal singkat (mis. "25 Nov").
  static String formatShortDate(DateTime date) {
    final month = _shortMonths[date.month - 1];
    return '${date.day} $month';
  }

  /// Mengubah DateTime menjadi format jam:menit (mis. "14:30").
  static String formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
