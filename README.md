# Aplikasi Cuaca Flutter (Open-Meteo)

- **Nama:** Farrel Athalladhia Rivaldimuchlis
- **NIM:** H1D024054
- **Mata Kuliah:** Pemrograman Mobile — Responsi Flutter
- **Video Penjelasan Kode:** [Tonton di YouTube](https://youtu.be/m-g-aTRbd3I)

Aplikasi pemantau cuaca berbasis **Flutter (Dart)** yang dikembangkan untuk tugas **Responsi Flutter**. Aplikasi ini mengambil data cuaca terkini dan prakiraan 7 hari secara *real-time* dari **Open-Meteo API**, menerapkan arsitektur **MVVM** dengan `Provider`, serta menyimpan lokasi favorit, riwayat pencarian, dan kota terakhir secara lokal menggunakan `SharedPreferences`.

## Video Penjelasan & Demo Aplikasi

Penjelasan struktur proyek, alur arsitektur MVVM, integrasi REST API Open-Meteo, penyimpanan lokal (`SharedPreferences`), dan demo aplikasi dapat dilihat melalui tautan berikut:

▶️ **YouTube:** [https://youtu.be/m-g-aTRbd3I](https://youtu.be/m-g-aTRbd3I)

## Fitur Utama

- **Cuaca Terkini:** Menampilkan nama kota, wilayah/negara, kondisi cuaca (kode WMO diterjemahkan ke Bahasa Indonesia beserta ikon), suhu saat ini, dan suhu yang dirasakan (*feels like*).
- **Detail Cuaca Tambahan:** Menampilkan kelembapan udara (%), kecepatan angin (km/j), curah hujan (mm), dan peluang hujan hari ini (%).
- **Prakiraan 7 Hari:** Menampilkan daftar prakiraan cuaca harian meliputi hari/tanggal, ikon kondisi cuaca, peluang hujan maksimum, serta suhu minimum dan maksimum.
- **Pencarian Kota Real-Time:** Terhubung langsung ke Open-Meteo Geocoding API dilengkapi *debounce* 500 ms dan pencegahan *race condition*.
- **Local Storage:** Menyimpan lokasi favorit (bisa diakses cepat melalui *chip* horizontal di Home Screen), riwayat pencarian (maksimal 10 kota terbaru tanpa duplikat), dan lokasi terakhir yang dibuka.
- **State & Error Handling Lengkap:** Menangani kondisi *loading*, data kosong (*empty state*), offline/timeout (*error state* dengan tombol **Coba Lagi**), serta *pull-to-refresh*.
- **Material Design 3:** Mendukung *Light Mode* dan *Dark Mode* otomatis mengikuti pengaturan sistem dengan tata letak responsif.

## Teknologi & Arsitektur

- **Framework & Bahasa:** Flutter & Dart (Null-Safety)
- **Arsitektur:** Model-View-ViewModel (MVVM)
- **State Management:** `provider` (`ChangeNotifier`)
- **Networking:** `http` (HTTP GET + parsing JSON manual)
- **Local Storage:** `shared_preferences`
- **API:** [Open-Meteo Weather Forecast API](https://open-meteo.com/en/docs) & [Open-Meteo Geocoding API](https://open-meteo.com/en/docs/geocoding-api)

> Penjelasan detail mengenai struktur folder, endpoint & parameter API, serta alur penerapan MVVM tersedia di [`DOCUMENTATION.md`](DOCUMENTATION.md).

## Struktur Folder

```text
lib/
├── main.dart
├── core/
│   ├── theme/app_theme.dart
│   └── utils/
│       ├── date_formatter.dart
│       └── weather_code.dart
├── models/
│   ├── current_weather.dart
│   ├── daily_forecast.dart
│   ├── location.dart
│   └── weather_data.dart
├── services/
│   ├── geocoding_service.dart
│   ├── storage_service.dart
│   └── weather_service.dart
├── viewmodels/
│   ├── search_viewmodel.dart
│   └── weather_viewmodel.dart
└── views/
    ├── home_screen.dart
    ├── search_screen.dart
    └── widgets/
        ├── current_weather_card.dart
        ├── daily_forecast_list.dart
        ├── empty_view.dart
        ├── error_view.dart
        ├── loading_view.dart
        ├── location_list_tile.dart
        └── weather_detail_tile.dart
```

## Cara Menjalankan Proyek

1. Pastikan Flutter SDK sudah terpasang (`flutter doctor`).
2. Clone repositori ini:
```bash
git clone https://github.com/K3tsuko/Responsi2Pemmob_FarrelAthalladhiaRivaldimuchlis_H1D024054.git
cd responsi2farrelathalladhia
```

3. Unduh semua dependency:
```bash
flutter pub get
```

4. Jalankan aplikasi di emulator atau perangkat Android:
```bash
flutter run
```

5. (Opsional) Jalankan unit test parsing model:
```bash
flutter test
```

## Screenshot Aplikasi

| Home / Weather Screen | Hasil Pencarian Kota (API) | Favorit & Riwayat Pencarian |
| --- | --- | --- |
| ![Home Screen](screenshots/01_home_screen.png) | ![Search Results](screenshots/02_search_results.png) | ![Favorites & History](screenshots/03_favorites_history.png) |

| Kondisi Data Kosong (Empty State) | Kondisi Error / Offline (Retry) |
| --- | --- |
| ![Empty State](screenshots/04_empty_state.png) | ![Error State](screenshots/05_error_state.png) |

## Ringkasan Implementasi API & MVVM

* **API Open-Meteo:** Permintaan data dilakukan di `WeatherService` (endpoint `/v1/forecast` dengan parameter `latitude`, `longitude`, `current`, `daily`, `timezone=auto`, `forecast_days=7`) dan `GeocodingService` (endpoint `/v1/search`). Semua respons JSON di-parsing manual menjadi objek Dart di folder `models/`.
* **MVVM:** View (`HomeScreen`, `SearchScreen`) hanya menampilkan UI berdasarkan status enum pada ViewModel (`initial`, `loading`, `success`, `empty`, `error`) menggunakan `context.watch` dan memanggil aksi melalui `context.read`. Seluruh logika bisnis, *debounce*, dan koordinasi data berada di `WeatherViewModel` serta `SearchViewModel`.
