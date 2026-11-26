// ignore_for_file: prefer_initializing_formals

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/location.dart';
import '../services/geocoding_service.dart';
import '../services/storage_service.dart';

/// Status state untuk fitur pencarian kota (Search Screen).
enum SearchStatus { initial, loading, success, empty, error }

/// ViewModel pengelola pencarian kota, daftar favorit, dan riwayat pencarian.
class SearchViewModel extends ChangeNotifier {
  static const int _maxHistory = 10;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  final GeocodingService _geocodingService;
  final StorageService _storageService;

  SearchViewModel({
    required GeocodingService geocodingService,
    required StorageService storageService,
  })  : _geocodingService = geocodingService,
        _storageService = storageService;

  SearchStatus _status = SearchStatus.initial;
  List<LocationModel> _results = const [];
  List<LocationModel> _favorites = [];
  List<LocationModel> _history = [];
  String _query = '';
  String? _errorMessage;

  Timer? _debounceTimer;
  // Counter untuk mencegah race condition jika respons query lama datang belakangan
  int _requestCounter = 0;

  SearchStatus get status => _status;
  List<LocationModel> get results => List.unmodifiable(_results);
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get history => List.unmodifiable(_history);
  String get query => _query;
  String? get errorMessage => _errorMessage;

  /// Memuat ulang data favorit dan riwayat pencarian dari SharedPreferences saat aplikasi dibuka.
  Future<void> init() async {
    _favorites = await _storageService.getFavorites();
    _history = await _storageService.getHistory();
    notifyListeners();
  }

  /// Dipanggil setiap teks pada TextField berubah (dengan debounce 500 ms).
  void onQueryChanged(String value) {
    _query = value;
    _debounceTimer?.cancel();

    if (value.trim().isEmpty) {
      // Batalkan respons pencarian sebelumnya jika input dikosongkan
      _requestCounter++;
      _results = const [];
      _errorMessage = null;
      _status = SearchStatus.initial;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () {
      searchLocations(value);
    });
  }

  /// Menjalankan pencarian langsung ke Geocoding API (bisa dipanggil via debounce atau tombol cari/retry).
  Future<void> searchLocations([String? customQuery]) async {
    _debounceTimer?.cancel();
    final targetQuery = (customQuery ?? _query).trim();

    if (targetQuery.isEmpty) {
      _requestCounter++;
      _results = const [];
      _errorMessage = null;
      _status = SearchStatus.initial;
      notifyListeners();
      return;
    }

    final requestId = ++_requestCounter;
    _status = SearchStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final locations = await _geocodingService.searchLocations(targetQuery);

      // Abaikan hasil lama jika pengguna sudah mengetik query baru
      if (requestId != _requestCounter) return;

      _results = locations;
      _status = locations.isEmpty ? SearchStatus.empty : SearchStatus.success;
    } on SocketException {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage =
          'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.';
    } on http.ClientException {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage = 'Gagal terhubung ke server pencarian lokasi.';
    } on TimeoutException {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage = 'Pencarian melebihi batas waktu. Silakan coba lagi.';
    } on HttpException catch (e) {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage = e.message;
    } on FormatException catch (e) {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage = e.message;
    } catch (_) {
      if (requestId != _requestCounter) return;
      _status = SearchStatus.error;
      _errorMessage = 'Terjadi kesalahan saat mencari kota.';
    }

    notifyListeners();
  }

  /// Mengosongkan input dan mengembalikan tampilan ke bagian Favorit & Riwayat.
  void clearSearch() {
    _debounceTimer?.cancel();
    _requestCounter++;
    _query = '';
    _results = const [];
    _errorMessage = null;
    _status = SearchStatus.initial;
    notifyListeners();
  }

  /// Mengecek apakah suatu lokasi sudah masuk daftar favorit.
  bool isFavorite(LocationModel location) {
    return _favorites.any((item) => item.id == location.id);
  }

  /// Menambah atau menghapus lokasi dari daftar favorit.
  /// Mengembalikan `true` jika ditambahkan, `false` jika dihapus.
  Future<bool> toggleFavorite(LocationModel location) async {
    final exists = isFavorite(location);
    if (exists) {
      _favorites = _favorites.where((item) => item.id != location.id).toList();
    } else {
      _favorites = [location, ..._favorites];
    }
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
    return !exists;
  }

  /// Menghapus satu lokasi dari daftar favorit.
  Future<void> removeFavorite(LocationModel location) async {
    _favorites = _favorites.where((item) => item.id != location.id).toList();
    await _storageService.saveFavorites(_favorites);
    notifyListeners();
  }

  /// Menambahkan lokasi ke riwayat pencarian (maks 10, tanpa duplikat, terbaru di atas).
  Future<void> addToHistory(LocationModel location) async {
    final updated = _history.where((item) => item.id != location.id).toList();
    updated.insert(0, location);

    if (updated.length > _maxHistory) {
      _history = updated.sublist(0, _maxHistory);
    } else {
      _history = updated;
    }

    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  /// Menghapus satu item dari riwayat pencarian.
  Future<void> removeHistoryItem(LocationModel location) async {
    _history = _history.where((item) => item.id != location.id).toList();
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearHistory() async {
    _history = [];
    await _storageService.saveHistory(_history);
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
