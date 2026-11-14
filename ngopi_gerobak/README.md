# Ngopi Gerobak (Flutter)

Konversi aplikasi web single-file "Ngopi Gerobak" ke Flutter (Android & iOS).
Pesan kopi dari gerobak terdekat, ambil tanpa antre.

## Menjalankan

Folder ini hanya berisi `lib/`, `pubspec.yaml`, dan `analysis_options.yaml`.
Folder platform (`android/`, `ios/`) dibuat oleh Flutter:

```bash
flutter create --org id.ngopigerobak --project-name ngopi_gerobak .
flutter pub get
flutter run
```

Perintah `flutter create .` tidak menimpa `lib/` maupun `pubspec.yaml` yang sudah ada,
tetapi jika ia membuat `test/widget_test.dart` bawaan yang merujuk `MyApp`, hapus berkas itu.

Kebutuhan: Flutter >= 3.27 (memakai `Column(spacing:)` dan `Color.withValues`), Dart >= 3.6.

## Paket

| Paket | Kegunaan |
|---|---|
| `provider` | state management (`AuthProvider`, `OrderProvider`) |
| `google_fonts` | Bricolage Grotesque (judul) dan Plus Jakarta Sans (isi) |
| `qr_flutter` | QR pembayaran QRIS dan QR kode pickup |

`flutter_svg` tidak dipakai: gerobak, cangkir, dan camilan digambar dengan `CustomPainter`
(`core/widgets/illustrations.dart`), jadi tidak perlu aset.

Catatan `google_fonts`: font diunduh saat pertama kali dipakai. Untuk rilis offline,
unduh berkas font dan daftarkan di `pubspec.yaml`.

## Struktur

```
lib/
  main.dart                      MultiProvider, tema light/dark (ikut sistem)
  app/
    routes.dart                  nama rute + helper navigasi (push/replace/backTo/fromHome/resetTo)
    router.dart                  peta rute -> layar
  core/
    core.dart                    barrel export
    theme/app_theme.dart         AppPalette (ThemeExtension), tipografi, ThemeData
    utils/format.dart            rp(), fmtDist(), mmss(), greeting(), dll.
    widgets/
      common.dart                AppScaffold, AppButton, AppChip, Timeline, QrBox, CartEditor, ...
      illustrations.dart         CupArt, SnackArt, GerobakArt
      map_view.dart              peta simulasi + pin + titik lokasi berdenyut
  data/
    models/                      Product, Option, CoffeeCart, Area, CartItem, DraftItem
    mock_data.dart               menu, gerobak, area, opsi (dari data web asli)
  providers/
    auth_provider.dart           register / login / sapaan
    order_provider.dart          lokasi, keranjang, validasi, pembayaran, review
  features/
    auth/      WelcomeScreen, RegisterScreen, LoginScreen
    home/      HomeScreen
    explore/   ExploreScreen, ManualLocationScreen, CartListScreen, NoCartScreen
    menu/      MenuScreen, CustomizeScreen, CartScreen
    checkout/  CheckoutScreen, ValidateScreen, ChangesScreen, RequestScreen,
               WaitingScreen, RejectedScreen, AdjustOrderScreen
    payment/   ReserveScreen, BillScreen, ExpiredScreen, PaidScreen
    tracking/  MakingScreen, ReadyScreen, PickupCodeScreen, ArriveScreen,
               VerifyScreen, HandoverScreen, DoneScreen
    review/    ReviewScreen, EndScreen
```

## Alur dan navigasi

Mengikuti diagram pada versi web:

1. Welcome -> Login/Register -> Home -> Explore Coffee Cart
2. Izin lokasi (GPS simulasi) atau pilih area manual -> daftar gerobak, atau layar "tidak ada gerobak"
   (area demo **Cakung** sengaja kosong)
3. Menu -> kustomisasi -> keranjang -> "Tambah produk lagi?" -> checkout
4. Validasi gerobak/harga/stok (aktifkan "Simulasi validasi" di checkout untuk melihat layar perubahan)
5. Kirim permintaan -> menunggu konfirmasi (otomatis diterima dalam 7 detik, atau pakai tombol simulasi)
   - ditolak -> alasan acak, gerobak itu disembunyikan, ubah pesanan / cari gerobak lain
   - diterima -> reservasi stok -> tagihan (QRIS / dompet digital / virtual account, timer 120 detik)
     - kedaluwarsa -> stok dilepas -> kembali ke Explore
     - dibayar -> disiapkan -> siap -> notifikasi + kode pickup -> datang -> verifikasi -> serah terima
       -> selesai -> rating dan review -> terima kasih

Layar alur maju memakai `pushReplacement` dan `PopScope(canPop: false)` agar tombol kembali
tidak membuka pesanan yang sudah berjalan. Layar yang boleh kembali (menu, keranjang, checkout,
dll.) memakai `push` biasa.

## Perbedaan dari versi web

- Panel "Alur aplikasi" di samping layar (khusus layar lebar) tidak dibawa; di Flutter peran itu
  tidak diperlukan.
- Peta adalah simulasi `CustomPainter` (bukan Google Maps). Untuk peta sungguhan, ganti
  `MapView` dengan `google_maps_flutter` / `flutter_map` dan `geolocator` untuk GPS.
- Semua data, pembayaran, dan konfirmasi gerobak masih simulasi; tidak ada backend.
- Garis putus-putus pada kotak "Simulasi" diganti garis biasa.

## Menuju produksi

- Ganti `MockData` dengan repository (REST/Firebase) dan pecah `OrderProvider` per fitur
  (cart, payment, tracking) bila membesar.
- Ganti timer simulasi (`Timer` di layar) dengan stream/WebSocket/FCM dari server.
- Tambahkan `geolocator` + izin lokasi, penyimpanan sesi (`flutter_secure_storage`),
  dan integrasi payment gateway sungguhan.
