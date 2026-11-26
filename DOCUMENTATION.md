# Dokumentasi Teknis Aplikasi Cuaca (Open-Meteo)

Dokumen ini menjelaskan struktur aplikasi, implementasi REST API Open-Meteo, serta penerapan arsitektur Model-View-ViewModel (MVVM) pada proyek Flutter ini.

---

## 1. Struktur Aplikasi

Proyek disusun secara modular berdasarkan tanggung jawab tiap lapisan arsitektur MVVM:

```text
lib/
├── main.dart                          # Entry point, inisialisasi Service & MultiProvider
├── core/
│   ├── theme/
│   │   └── app_theme.dart             # Konfigurasi Material 3 (Light & Dark Theme, Typography)
│   └── utils/
│       ├── weather_code.dart          # Mapping kode cuaca WMO -> teks Indonesia & IconData
│       └── date_formatter.dart        # Pemformat hari, tanggal, dan jam dalam Bahasa Indonesia
├── models/
│   ├── location.dart                  # Model lokasi/kota (fromJson & toJson)
│   ├── current_weather.dart           # Model cuaca terkini (objek `current`)
│   ├── daily_forecast.dart            # Model prakiraan harian (array paralel `daily`)
│   └── weather_data.dart              # Gabungan CurrentWeather + List<DailyForecast> + timezone
├── services/
│   ├── geocoding_service.dart         # HTTP GET ke Open-Meteo Geocoding API
│   ├── weather_service.dart           # HTTP GET ke Open-Meteo Forecast API
│   └── storage_service.dart           # Wrapper SharedPreferences (favorit, riwayat, last location)
├── viewmodels/
│   ├── weather_viewmodel.dart         # State cuaca kota terpilih & koordinasi WeatherService
│   └── search_viewmodel.dart          # State pencarian, debounce, favorit, dan riwayat
└── views/
    ├── home_screen.dart               # Layar utama cuaca + akses cepat chip favorit
    ├── search_screen.dart             # Layar pencarian kota, daftar favorit, & riwayat
    └── widgets/
        ├── current_weather_card.dart  # Kartu utama suhu, kondisi cuaca, dan feels like
        ├── weather_detail_tile.dart   # Kartu kelembapan, angin, curah hujan, peluang hujan
        ├── daily_forecast_list.dart   # Daftar prakiraan cuaca 7 hari ke depan
        ├── location_list_tile.dart    # Baris lokasi (hasil pencarian, favorit, riwayat)
        ├── loading_view.dart          # Tampilan indikator loading
        ├── error_view.dart            # Tampilan pesan error + tombol "Coba Lagi"
        └── empty_view.dart            # Tampilan saat data/pencarian kosong
```

---

## 2. Implementasi API Open-Meteo

Aplikasi menggunakan package `http` dengan metode **HTTP GET** dan **parsing JSON manual** ke model Dart (tanpa API key dan tanpa data hardcoded). Setiap request dilengkapi `Uri.https()` untuk encoding parameter otomatis serta timeout **10 detik**.

### A. Geocoding API (Pencarian Kota)

* **Endpoint:** `https://geocoding-api.open-meteo.com/v1/search`
* **File implementasi:** `lib/services/geocoding_service.dart`
* **Parameter:**
  * `name`: Nama kota yang diketik pengguna
  * `count`: `10` (maksimal 10 hasil)
  * `language`: `id`
  * `format`: `json`
* **Penanganan respons:** Jika kota tidak ditemukan, Open-Meteo mengembalikan key `results` bernilai `null` atau tidak ada. Service menangani kondisi ini dengan mengembalikan list kosong (`const []`) sehingga ViewModel memicu state `SearchStatus.empty`.

### B. Weather Forecast API (Cuaca Terkini & Prakiraan 7 Hari)

* **Endpoint:** `https://api.open-meteo.com/v1/forecast`
* **File implementasi:** `lib/services/weather_service.dart`
* **Parameter:**
  * `latitude` & `longitude`: Koordinat kota yang dipilih
  * `current`: `temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m`
  * `daily`: `weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max`
  * `timezone`: `auto`
  * `forecast_days`: `7`

### C. Alur Request -> Parse -> Tampil

1. **Trigger dari UI:** Pengguna membuka aplikasi (memuat lokasi terakhir atau default Semarang) atau memilih kota di `SearchScreen`.
2. **Pemanggilan di ViewModel:** `WeatherViewModel.fetchWeather()` mengubah status menjadi `WeatherStatus.loading` dan memanggil `notifyListeners()`.
3. **HTTP Request di Service:** `WeatherService.fetchWeather()` mengirim HTTP GET ke Open-Meteo dan memverifikasi `response.statusCode == 200`.
4. **Parsing JSON ke Model:** String JSON di-decode dengan `jsonDecode()` lalu dipetakan oleh `WeatherData.fromJson()`, `CurrentWeather.fromJson()`, dan `DailyForecast.listFromDailyJson()`.
5. **Pembaruan UI:** ViewModel menyimpan hasil ke `_weatherData`, mengubah status menjadi `WeatherStatus.success`, dan memanggil `notifyListeners()`. `HomeScreen` yang memantau melalui `context.watch<WeatherViewModel>()` otomatis merender ulang widget.
6. **Penanganan Error:** Jika terjadi `SocketException` (offline), `TimeoutException`, `HttpException` (status non-200), atau `FormatException` (JSON tidak valid), ViewModel menangkap error, mengubah status menjadi `WeatherStatus.error`, dan menampilkan `ErrorView` dengan tombol **Coba Lagi**.

---

## 3. Penerapan Arsitektur MVVM

Pemisahan tanggung jawab (*separation of concerns*) dijaga secara ketat di seluruh proyek:

| Lapisan | Tanggung Jawab | Contoh di Kode |
| --- | --- | --- |
| **Model** | Merepresentasikan struktur data dan logika parsing JSON (`fromJson`/`toJson`). Tidak tahu apa pun soal UI atau HTTP. | `LocationModel`, `CurrentWeather`, `DailyForecast`, `WeatherData` |
| **Service** | Menangani sumber data eksternal (HTTP request ke Open-Meteo dan penyimpanan lokal `SharedPreferences`). | `WeatherService`, `GeocodingService`, `StorageService` |
| **ViewModel** | Menyimpan state aplikasi (`status`, `weatherData`, `favorites`, `history`, `errorMessage`), menjalankan logika bisnis (debounce, anti race condition, limit riwayat maks 10), dan memberitahu View lewat `ChangeNotifier`. | `WeatherViewModel`, `SearchViewModel` |
| **View** | Hanya membangun tampilan Material 3 dari state ViewModel (`context.watch`) dan meneruskan aksi pengguna ke method ViewModel (`context.read`). Tidak ada panggilan HTTP atau penyimpanan langsung di widget. | `HomeScreen`, `SearchScreen`, dan seluruh widget di `views/widgets/` |

### Penyimpanan Lokal (`SharedPreferences`)

`StorageService` menyimpan tiga data dalam format JSON string:

* `favorite_locations`: Daftar kota favorit (`List<LocationModel>`)
* `search_history`: Riwayat pencarian kota (maksimal 10 item, tanpa duplikat, terbaru di atas)
* `last_location`: Lokasi terakhir yang dipilih pengguna agar langsung dimuat saat aplikasi dibuka kembali.
