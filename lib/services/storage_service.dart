import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location.dart';

/// Service penyimpanan lokal menggunakan SharedPreferences (format JSON).
class StorageService {
  static const String _favoritesKey = 'favorite_locations';
  static const String _historyKey = 'search_history';
  static const String _lastLocationKey = 'last_location';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Membaca daftar lokasi favorit yang tersimpan.
  Future<List<LocationModel>> getFavorites() async {
    final prefs = await _instance;
    final rawList = prefs.getStringList(_favoritesKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  /// Menyimpan daftar lokasi favorit sebagai list string JSON.
  Future<void> saveFavorites(List<LocationModel> favorites) async {
    final prefs = await _instance;
    final encoded =
        favorites.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_favoritesKey, encoded);
  }

  /// Membaca daftar riwayat pencarian lokasi.
  Future<List<LocationModel>> getHistory() async {
    final prefs = await _instance;
    final rawList = prefs.getStringList(_historyKey) ?? const [];
    return _decodeLocationList(rawList);
  }

  /// Menyimpan daftar riwayat pencarian lokasi.
  Future<void> saveHistory(List<LocationModel> history) async {
    final prefs = await _instance;
    final encoded =
        history.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_historyKey, encoded);
  }

  /// Membaca lokasi terakhir yang dipilih pengguna (null jika belum pernah memilih).
  Future<LocationModel?> getLastLocation() async {
    final prefs = await _instance;
    final rawJson = prefs.getString(_lastLocationKey);
    if (rawJson == null || rawJson.isEmpty) return null;

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) {
        return LocationModel.fromJson(decoded);
      }
    } catch (_) {
      // Abaikan jika data lama rusak agar aplikasi tidak crash
    }
    return null;
  }

  /// Menyimpan lokasi terakhir yang dibuka pengguna.
  Future<void> saveLastLocation(LocationModel location) async {
    final prefs = await _instance;
    await prefs.setString(_lastLocationKey, jsonEncode(location.toJson()));
  }

  /// Helper decoding list string JSON menjadi `List<LocationModel>` secara aman.
  List<LocationModel> _decodeLocationList(List<String> rawList) {
    final List<LocationModel> locations = [];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          locations.add(LocationModel.fromJson(decoded));
        }
      } catch (_) {
        // Lewati item JSON yang tidak valid
      }
    }
    return locations;
  }
}
