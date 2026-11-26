/// Model prakiraan cuaca untuk satu hari dari array `daily` Open-Meteo.
class DailyForecast {
  final DateTime date;
  final double tempMax;
  final double tempMin;
  final int precipProbMax;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.tempMax,
    required this.tempMin,
    required this.precipProbMax,
    required this.weatherCode,
  });

  /// Mengubah struktur array paralel Open-Meteo (`daily`) menjadi `List<DailyForecast>`.
  static List<DailyForecast> listFromDailyJson(Map<String, dynamic> dailyJson) {
    final times = (dailyJson['time'] as List<dynamic>?) ?? const [];
    final maxTemps =
        (dailyJson['temperature_2m_max'] as List<dynamic>?) ?? const [];
    final minTemps =
        (dailyJson['temperature_2m_min'] as List<dynamic>?) ?? const [];
    final precipProbs =
        (dailyJson['precipitation_probability_max'] as List<dynamic>?) ??
            const [];
    final weatherCodes =
        (dailyJson['weather_code'] as List<dynamic>?) ?? const [];

    final List<DailyForecast> forecasts = [];

    for (int i = 0; i < times.length; i++) {
      final rawDate = times[i]?.toString() ?? '';
      final parsedDate = DateTime.tryParse(rawDate);
      if (parsedDate == null) continue;

      forecasts.add(
        DailyForecast(
          date: parsedDate,
          tempMax: _getDoubleAt(maxTemps, i),
          tempMin: _getDoubleAt(minTemps, i),
          precipProbMax: _getIntAt(precipProbs, i),
          weatherCode: _getIntAt(weatherCodes, i, fallback: -1),
        ),
      );
    }

    return forecasts;
  }

  static double _getDoubleAt(List<dynamic> list, int index) {
    if (index >= list.length || list[index] == null) return 0.0;
    return (list[index] as num).toDouble();
  }

  static int _getIntAt(List<dynamic> list, int index, {int fallback = 0}) {
    if (index >= list.length || list[index] == null) return fallback;
    return (list[index] as num).round();
  }
}
