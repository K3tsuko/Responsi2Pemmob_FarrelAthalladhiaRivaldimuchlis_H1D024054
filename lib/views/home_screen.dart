import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/weather_data.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_card.dart';
import 'widgets/daily_forecast_list.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/weather_detail_tile.dart';

/// Layar utama aplikasi: menampilkan cuaca terkini, detail tambahan, akses cepat favorit, dan prakiraan 7 hari.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearchScreen(BuildContext context) async {
    // Reset input pencarian sebelum membuka layar pencarian
    context.read<SearchViewModel>().clearSearch();
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  Future<void> _toggleCurrentFavorite(BuildContext context) async {
    final weatherVm = context.read<WeatherViewModel>();
    final searchVm = context.read<SearchViewModel>();
    final location = weatherVm.selectedLocation;

    final added = await searchVm.toggleFavorite(location);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${location.name} ditambahkan ke favorit'
                : '${location.name} dihapus dari favorit',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final searchVm = context.watch<SearchViewModel>();
    final isCurrentFavorite = searchVm.isFavorite(weatherVm.selectedLocation);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca'),
        actions: [
          IconButton(
            tooltip: isCurrentFavorite
                ? 'Hapus kota dari favorit'
                : 'Simpan kota ke favorit',
            onPressed: () => _toggleCurrentFavorite(context),
            icon: Icon(
              isCurrentFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color: isCurrentFavorite ? Colors.amber : null,
            ),
          ),
          IconButton(
            tooltip: 'Cari kota',
            onPressed: () => _openSearchScreen(context),
            icon: const Icon(Icons.search_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Akses cepat berpindah kota dari daftar favorit (chip horizontal)
            if (searchVm.favorites.isNotEmpty) _buildFavoriteChips(context),

            // Konten utama mengikuti status WeatherViewModel
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _buildBodyByStatus(context, weatherVm),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteChips(BuildContext context) {
    final weatherVm = context.watch<WeatherViewModel>();
    final favorites = context.watch<SearchViewModel>().favorites;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final fav = favorites[index];
          final isSelected = fav.id == weatherVm.selectedLocation.id;

          return ChoiceChip(
            label: Text(fav.name),
            selected: isSelected,
            avatar: isSelected ? null : const Icon(Icons.star_rounded, size: 16),
            onSelected: (_) {
              if (!isSelected) {
                context.read<WeatherViewModel>().selectLocation(fav);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildBodyByStatus(BuildContext context, WeatherViewModel weatherVm) {
    switch (weatherVm.status) {
      case WeatherStatus.initial:
      case WeatherStatus.loading:
        return LoadingView(
          key: const ValueKey('loading'),
          message: 'Memuat cuaca untuk ${weatherVm.selectedLocation.name}...',
        );
      case WeatherStatus.error:
        return ErrorView(
          key: const ValueKey('error'),
          message: weatherVm.errorMessage ?? 'Gagal memuat data cuaca.',
          onRetry: () => weatherVm.fetchWeather(),
        );
      case WeatherStatus.empty:
        return const EmptyView(
          key: ValueKey('empty'),
          icon: Icons.cloud_queue_rounded,
          title: 'Data cuaca tidak tersedia',
          subtitle: 'Silakan pilih kota lain melalui menu pencarian.',
        );
      case WeatherStatus.success:
        final weather = weatherVm.weatherData;
        if (weather == null) {
          return const EmptyView(
            key: ValueKey('empty-null'),
            title: 'Data cuaca kosong',
          );
        }
        return _buildSuccessContent(context, weatherVm, weather);
    }
  }

  Widget _buildSuccessContent(
    BuildContext context,
    WeatherViewModel weatherVm,
    WeatherData weather,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final current = weather.current;

    return RefreshIndicator(
      key: ValueKey('success-${weatherVm.selectedLocation.id}'),
      onRefresh: () => weatherVm.fetchWeather(isRefresh: true),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          // Kartu suhu dan kondisi terkini
          CurrentWeatherCard(
            location: weatherVm.selectedLocation,
            weather: weather,
          ),
          const SizedBox(height: 16),

          // Bagian detail cuaca tambahan dengan layout responsif (2 kolom di HP, 4 kolom di layar lebar)
          Text('Detail Cuaca', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              const double spacing = 10;
              final int columns = constraints.maxWidth >= 600 ? 4 : 2;
              final double itemWidth =
                  (constraints.maxWidth - (spacing * (columns - 1))) / columns;

              final details = [
                WeatherDetailTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Kelembapan',
                  value: '${current.humidity}%',
                ),
                WeatherDetailTile(
                  icon: Icons.air_rounded,
                  label: 'Kecepatan Angin',
                  value: '${current.windSpeed.toStringAsFixed(1)} km/j',
                ),
                WeatherDetailTile(
                  icon: Icons.grain_rounded,
                  label: 'Curah Hujan',
                  value: '${current.precipitation.toStringAsFixed(1)} mm',
                ),
                WeatherDetailTile(
                  icon: Icons.umbrella_outlined,
                  label: 'Peluang Hujan',
                  value: '${weather.todayPrecipProbability}%',
                ),
              ];

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: details
                    .map((tile) => SizedBox(width: itemWidth, child: tile))
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 20),

          // Bagian prakiraan cuaca 7 hari ke depan
          Text('Prakiraan 7 Hari', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          DailyForecastList(forecasts: weather.daily),
        ],
      ),
    );
  }
}
