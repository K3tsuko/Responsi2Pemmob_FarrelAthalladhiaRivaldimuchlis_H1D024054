/// Model data lokasi/kota hasil dari Geocoding API Open-Meteo sekaligus untuk local storage.
class LocationModel {
  final int id;
  final String name;
  final String country;
  final String admin1; // Provinsi / negara bagian
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.id,
    required this.name,
    required this.country,
    required this.admin1,
    required this.latitude,
    required this.longitude,
  });

  /// Lokasi default awal jika belum ada riwayat di SharedPreferences (Semarang).
  static const LocationModel defaultSemarang = LocationModel(
    id: 1627896,
    name: 'Semarang',
    admin1: 'Jawa Tengah',
    country: 'Indonesia',
    latitude: -6.9667,
    longitude: 110.4167,
  );

  /// Subtitle lokasi untuk ditampilkan di UI (contoh: "Jawa Tengah, Indonesia").
  String get subtitle {
    final parts = <String>[
      if (admin1.trim().isNotEmpty) admin1.trim(),
      if (country.trim().isNotEmpty) country.trim(),
    ];
    return parts.join(', ');
  }

  /// Parsing JSON dari Geocoding API atau dari SharedPreferences.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? 'Tidak diketahui',
      country: (json['country'] as String?) ?? '',
      admin1: (json['admin1'] as String?) ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Konversi ke Map untuk disimpan sebagai JSON string di SharedPreferences.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Override == dan hashCode agar pengecekan favorit/duplikat berdasarkan ID lokasi akurat
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
