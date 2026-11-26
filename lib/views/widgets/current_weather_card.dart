import 'package:flutter/material.dart';

import '../../core/utils/date_formatter.dart';
import '../../core/utils/weather_code.dart';
import '../../models/location.dart';
import '../../models/weather_data.dart';

/// Kartu utama di Home Screen untuk menampilkan lokasi aktif, suhu saat ini, kondisi cuaca, dan suhu terasa.
class CurrentWeatherCard extends StatelessWidget {
  final LocationModel location;
  final WeatherData weather;

  const CurrentWeatherCard({
    super.key,
    required this.location,
    required this.weather,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final current = weather.current;
    final weatherInfo = mapWeatherCode(current.weatherCode);

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris nama kota & lokasi wilayah
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: colorScheme.onPrimaryContainer,
                  size: 22,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      if (location.subtitle.isNotEmpty)
                        Text(
                          location.subtitle,
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Suhu utama dan ikon kondisi cuaca
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature.round()}°C',
                        style: textTheme.displayLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        weatherInfo.description,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Terasa seperti ${current.apparentTemperature.round()}°C',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  weatherInfo.icon,
                  size: 72,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi waktu pembaruan terakhir
            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 14,
                  color: colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Diperbarui pukul ${DateFormatter.formatTime(weather.fetchedAt)} • ${weather.timezone}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
