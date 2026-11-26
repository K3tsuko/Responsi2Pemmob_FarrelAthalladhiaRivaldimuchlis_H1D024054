// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../models/weather_data.dart';
import '../services/storage_service.dart';
import '../services/weather_service.dart';

/// Status state untuk layar utama cuaca (Home Screen).
enum WeatherStatus { initial, loading, success, empty, error }

/// ViewModel pengelola state cuaca kota yang sedang aktif.
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  final StorageService _storageService;

  WeatherViewModel({
    required WeatherService weatherService,
    required StorageService storageService,
  })  : _weatherService = weatherService,
        _storageService = storageService;

  WeatherStatus _status = WeatherStatus.initial;
  LocationModel _selectedLocation = LocationModel.defaultSemarang;
  WeatherData? _weatherData;
  String? _errorMessage;

  // Counter untuk mencegah race condition saat user berpindah kota dengan cepat
  int _requestCounter = 0;

  WeatherStatus get status => _status;
  LocationModel get selectedLocation => _selectedLocation;
  WeatherData? get weatherData => _weatherData;
  String? get errorMessage => _errorMessage;

  /// Dipanggil saat aplikasi pertama dibuka: muat lokasi terakhir lalu ambil data cuaca dari API.
  Future<void> init() async {
    final lastLocation = await _storageService.getLastLocation();
    _selectedLocation = lastLocation ?? LocationModel.defaultSemarang;
    await fetchWeather();
  }

  /// Mengganti kota aktif, menyimpannya ke local storage, lalu memuat cuaca kota tersebut.
  Future<void> selectLocation(LocationModel location) async {
    _selectedLocation = location;
    await _storageService.saveLastLocation(location);
    await fetchWeather();
  }

  /// Mengambil data cuaca terkini dan prakiraan 7 hari dari WeatherService.
  Future<void> fetchWeather({bool isRefresh = false}) async {
    final requestId = ++_requestCounter;

    // Jika bukan pull-to-refresh atau belum ada data, tampilkan indikator loading penuh
    if (!isRefresh || _weatherData == null) {
      _status = WeatherStatus.loading;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final result = await _weatherService.fetchWeather(
        latitude: _selectedLocation.latitude,
        longitude: _selectedLocation.longitude,
      );

      // Abaikan respons jika sudah ada request baru yang lebih mutakhir
      if (requestId != _requestCounter) return;

      _weatherData = result;
      _errorMessage = null;
      _status = WeatherStatus.success;
    } on SocketException {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage =
          'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.';
    } on http.ClientException {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage =
          'Koneksi ke server cuaca terganggu. Silakan coba beberapa saat lagi.';
    } on TimeoutException {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage =
          'Permintaan melebihi batas waktu. Periksa koneksi internet Anda.';
    } on HttpException catch (e) {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage = e.message;
    } on FormatException catch (e) {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      if (requestId != _requestCounter) return;
      _status = WeatherStatus.error;
      _errorMessage = 'Terjadi kesalahan tak terduga saat memuat data cuaca.';
    }

    notifyListeners();
  }
}
