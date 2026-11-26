import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/weather_data.dart';

/// Service khusus untuk mengambil data cuaca terkini dan prakiraan 7 hari dari Open-Meteo.
class WeatherService {
  static const String _host = 'api.open-meteo.com';
  static const String _path = '/v1/forecast';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  WeatherService({http.Client? client}) : _client = client ?? http.Client();

  /// Melakukan HTTP GET ke Weather Forecast API berdasarkan koordinat lintang & bujur.
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https(_host, _path, {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
      'timezone': 'auto',
      'forecast_days': '7',
    });

    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mengambil data cuaca (Kode server: ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format respons data cuaca tidak valid.');
    }

    return WeatherData.fromJson(decoded);
  }
}
