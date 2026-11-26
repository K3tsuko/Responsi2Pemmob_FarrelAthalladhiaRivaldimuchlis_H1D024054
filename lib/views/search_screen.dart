import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/empty_view.dart';
import 'widgets/error_view.dart';
import 'widgets/loading_view.dart';
import 'widgets/location_list_tile.dart';

/// Layar pencarian kota: mendukung pencarian real-time ke Open-Meteo Geocoding API, favorit, dan riwayat.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dipanggil saat pengguna memilih salah satu kota dari hasil pencarian, favorit, atau riwayat.
  Future<void> _selectLocation(LocationModel location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    // Simpan ke riwayat pencarian di local storage
    await searchVm.addToHistory(location);

    // Muat cuaca untuk kota yang baru dipilih (berjalan async sementara navigasi kembali)
    weatherVm.selectLocation(location);

    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _toggleFavorite(LocationModel location) async {
    final added = await context.read<SearchViewModel>().toggleFavorite(location);
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? '${location.name} disimpan ke favorit'
                : '${location.name} dihapus dari favorit',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _clearInput() {
    _searchController.clear();
    context.read<SearchViewModel>().clearSearch();
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Kolom input pencarian kota
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: _searchController,
                textInputAction: TextInputAction.search,
                onChanged: searchVm.onQueryChanged,
                onSubmitted: (value) => searchVm.searchLocations(value),
                decoration: InputDecoration(
                  hintText: 'Cari nama kota (mis. Jakarta, Tokyo)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: searchVm.query.isNotEmpty
                      ? IconButton(
                          tooltip: 'Hapus teks',
                          onPressed: _clearInput,
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
              ),
            ),

            // Isi layar berubah berdasarkan status pencarian
            Expanded(
              child: _buildBodyByStatus(context, searchVm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyByStatus(BuildContext context, SearchViewModel searchVm) {
    switch (searchVm.status) {
      case SearchStatus.initial:
        return _buildFavoritesAndHistory(context, searchVm);
      case SearchStatus.loading:
        return const LoadingView(message: 'Mencari lokasi...');
      case SearchStatus.empty:
        return const EmptyView(
          icon: Icons.location_off_rounded,
          title: 'Kota tidak ditemukan',
          subtitle: 'Periksa ejaan nama kota lalu coba cari lagi.',
        );
      case SearchStatus.error:
        return ErrorView(
          message: searchVm.errorMessage ?? 'Gagal mencari lokasi.',
          onRetry: () => searchVm.searchLocations(),
        );
      case SearchStatus.success:
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: searchVm.results.length,
          itemBuilder: (context, index) {
            final location = searchVm.results[index];
            return LocationListTile(
              location: location,
              isFavorite: searchVm.isFavorite(location),
              onTap: () => _selectLocation(location),
              onToggleFavorite: () => _toggleFavorite(location),
            );
          },
        );
    }
  }

  /// Menampilkan bagian Favorit dan Riwayat Pencarian saat kotak pencarian kosong.
  Widget _buildFavoritesAndHistory(
    BuildContext context,
    SearchViewModel searchVm,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final hasFavorites = searchVm.favorites.isNotEmpty;
    final hasHistory = searchVm.history.isNotEmpty;

    if (!hasFavorites && !hasHistory) {
      return const EmptyView(
        icon: Icons.travel_explore_rounded,
        title: 'Mulai cari kota',
        subtitle:
            'Ketik nama kota di kolom pencarian untuk melihat cuaca atau menyimpannya ke favorit.',
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: [
        // Bagian Lokasi Favorit
        if (hasFavorites) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text('Lokasi Favorit', style: textTheme.titleMedium),
          ),
          ...searchVm.favorites.map(
            (location) => LocationListTile(
              location: location,
              isFavorite: true,
              leadingIcon: Icons.star_rounded,
              onTap: () => _selectLocation(location),
              onToggleFavorite: () => _toggleFavorite(location),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Bagian Riwayat Pencarian
        if (hasHistory) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Riwayat Pencarian', style: textTheme.titleMedium),
              TextButton(
                onPressed: () => searchVm.clearHistory(),
                child: const Text('Hapus Riwayat'),
              ),
            ],
          ),
          ...searchVm.history.map(
            (location) => LocationListTile(
              location: location,
              isFavorite: searchVm.isFavorite(location),
              leadingIcon: Icons.history_rounded,
              onTap: () => _selectLocation(location),
              onToggleFavorite: () => _toggleFavorite(location),
              onDelete: () => searchVm.removeHistoryItem(location),
            ),
          ),
        ],
      ],
    );
  }
}
