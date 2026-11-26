import 'package:flutter/material.dart';

/// Representasi hasil terjemahan kode cuaca WMO menjadi label Indonesia dan ikon.
class WeatherCodeInfo {
  final String description;
  final IconData icon;

  const WeatherCodeInfo({
    required this.description,
    required this.icon,
  });
}

/// Memetakan kode cuaca standar WMO dari Open-Meteo ke deskripsi bahasa Indonesia dan IconData.
WeatherCodeInfo mapWeatherCode(int code) {
  switch (code) {
    case 0:
      return const WeatherCodeInfo(
        description: 'Cerah',
        icon: Icons.wb_sunny_rounded,
      );
    case 1:
      return const WeatherCodeInfo(
        description: 'Cerah Berawan',
        icon: Icons.wb_cloudy_outlined,
      );
    case 2:
      return const WeatherCodeInfo(
        description: 'Berawan',
        icon: Icons.cloud_queue_rounded,
      );
    case 3:
      return const WeatherCodeInfo(
        description: 'Mendung',
        icon: Icons.cloud_rounded,
      );
    case 45:
    case 48:
      return const WeatherCodeInfo(
        description: 'Kabut',
        icon: Icons.foggy,
      );
    case 51:
    case 53:
    case 55:
    case 56:
    case 57:
      return const WeatherCodeInfo(
        description: 'Gerimis',
        icon: Icons.grain_rounded,
      );
    case 61:
    case 63:
    case 65:
    case 66:
    case 67:
      return const WeatherCodeInfo(
        description: 'Hujan',
        icon: Icons.water_drop_rounded,
      );
    case 71:
    case 73:
    case 75:
    case 77:
      return const WeatherCodeInfo(
        description: 'Salju',
        icon: Icons.ac_unit_rounded,
      );
    case 80:
    case 81:
    case 82:
      return const WeatherCodeInfo(
        description: 'Hujan Lebat Sesaat',
        icon: Icons.umbrella_rounded,
      );
    case 85:
    case 86:
      return const WeatherCodeInfo(
        description: 'Hujan Salju',
        icon: Icons.cloudy_snowing,
      );
    case 95:
      return const WeatherCodeInfo(
        description: 'Badai Petir',
        icon: Icons.thunderstorm_rounded,
      );
    case 96:
    case 99:
      return const WeatherCodeInfo(
        description: 'Badai Petir & Hujan Es',
        icon: Icons.thunderstorm_outlined,
      );
    default:
      return const WeatherCodeInfo(
        description: 'Cuaca Tidak Diketahui',
        icon: Icons.help_outline_rounded,
      );
  }
}
