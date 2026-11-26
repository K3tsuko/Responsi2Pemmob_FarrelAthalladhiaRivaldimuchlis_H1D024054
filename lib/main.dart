import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'services/geocoding_service.dart';
import 'services/storage_service.dart';
import 'services/weather_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WeatherApp());
}

/// Root widget aplikasi cuaca dengan injeksi dependensi MVVM melalui MultiProvider.
class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi service yang akan dipakai bersama oleh ViewModel
    final storageService = StorageService();
    final weatherService = WeatherService();
    final geocodingService = GeocodingService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<WeatherViewModel>(
          create: (_) => WeatherViewModel(
            weatherService: weatherService,
            storageService: storageService,
          )..init(),
        ),
        ChangeNotifierProvider<SearchViewModel>(
          create: (_) => SearchViewModel(
            geocodingService: geocodingService,
            storageService: storageService,
          )..init(),
        ),
      ],
      child: MaterialApp(
        title: 'Aplikasi Cuaca Open-Meteo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
