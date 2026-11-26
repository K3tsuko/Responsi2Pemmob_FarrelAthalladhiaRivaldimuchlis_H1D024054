import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../models/location.dart';

/// Service khusus untuk pencarian kota menggunakan Geocoding API Open-Meteo.
class GeocodingService {
  static const String _host = 'geocoding-api.open-meteo.com';
  static const String _path = '/v1/search';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  GeocodingService({http.Client? client}) : _client = client ?? http.Client();

  /// Melakukan HTTP GET pencarian lokasi berdasarkan nama kota.
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return const [];

    // Menggunakan Uri.https agar spasi dan karakter khusus ter-encode otomatis
    final uri = Uri.https(_host, _path, {
      'name': trimmedQuery,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final response = await _client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw HttpException(
        'Gagal mencari lokasi (Kode server: ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Format respons pencarian tidak valid.');
    }

    // Open-Meteo mengembalikan key "results" null/tidak ada jika kota tidak ditemukan
    final results = decoded['results'];
    if (results == null || results is! List) {
      return const [];
    }

    return results
        .whereType<Map<String, dynamic>>()
        .map(LocationModel.fromJson)
        .toList();
  }
}
