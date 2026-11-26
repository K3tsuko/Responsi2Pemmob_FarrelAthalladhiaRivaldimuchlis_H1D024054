import 'current_weather.dart';
import 'daily_forecast.dart';

/// Model gabungan respons lengkap dari Open-Meteo Forecast API.
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> daily;
  final String timezone;
  final DateTime fetchedAt;

  const WeatherData({
    required this.current,
    required this.daily,
    required this.timezone,
    required this.fetchedAt,
  });

  /// Peluang hujan maksimum hari ini (diambil aman dari item pertama daily).
  int get todayPrecipProbability =>
      daily.isNotEmpty ? daily.first.precipProbMax : 0;

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentMap = json['current'] as Map<String, dynamic>?;
    final dailyMap = json['daily'] as Map<String, dynamic>?;

    if (currentMap == null) {
      throw const FormatException('Data cuaca terkini tidak ditemukan di respons API.');
    }

    return WeatherData(
      current: CurrentWeather.fromJson(currentMap),
      daily: dailyMap != null
          ? DailyForecast.listFromDailyJson(dailyMap)
          : const [],
      timezone: (json['timezone'] as String?) ?? 'auto',
      fetchedAt: DateTime.now(),
    );
  }
}
