import 'package:flutter_test/flutter_test.dart';
import 'package:responsi2farrelathalladhia/models/location.dart';
import 'package:responsi2farrelathalladhia/models/weather_data.dart';

void main() {
  test('Parsing LocationModel dari JSON Geocoding API berhasil', () {
    final json = {
      'id': 1627896,
      'name': 'Semarang',
      'country': 'Indonesia',
      'admin1': 'Jawa Tengah',
      'latitude': -6.9667,
      'longitude': 110.4167,
    };

    final location = LocationModel.fromJson(json);

    expect(location.id, 1627896);
    expect(location.name, 'Semarang');
    expect(location.subtitle, 'Jawa Tengah, Indonesia');
    expect(location.latitude, -6.9667);
  });

  test('Parsing WeatherData dari JSON Forecast API berhasil', () {
    final json = {
      'timezone': 'Asia/Jakarta',
      'current': {
        'temperature_2m': 31.2,
        'relative_humidity_2m': 72,
        'apparent_temperature': 35.4,
        'precipitation': 0.5,
        'weather_code': 2,
        'wind_speed_10m': 12.3,
      },
      'daily': {
        'time': ['2026-11-25', '2026-11-26'],
        'weather_code': [2, 61],
        'temperature_2m_max': [33.0, 30.5],
        'temperature_2m_min': [25.0, 24.5],
        'precipitation_probability_max': [40, 80],
      },
    };

    final weather = WeatherData.fromJson(json);

    expect(weather.timezone, 'Asia/Jakarta');
    expect(weather.current.temperature, 31.2);
    expect(weather.current.humidity, 72);
    expect(weather.daily.length, 2);
    expect(weather.todayPrecipProbability, 40);
  });
}
