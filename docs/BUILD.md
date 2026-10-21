# Menjalankan dan membangun

## Prasyarat

- Flutter 3.47 (Dart 3.13) atau lebih baru di kanal stable — proyek dibuat dan diuji dengan
  Flutter 3.47.7.
- Android SDK dengan platform 36 dan build-tools 36, JDK 17 atau 21.

## Menjalankan

```sh
flutter pub get
flutter run            # perangkat/emulator Android tersambung
```

Kode Drift sudah di-generate dan ikut di repositori. Setelah mengubah tabel:

```sh
dart run build_runner build
dart run drift_dev make-migrations   # setelah menaikkan schemaVersion
```

## Test

```sh
flutter analyze
flutter test                                   # unit, database, backup, widget, alur lengkap
flutter test integration_test/app_test.dart    # di perangkat/emulator
```

## APK debug

```sh
flutter build apk --debug
# hasil: build/app/outputs/flutter-apk/app-debug.apk
```

## Rilis bertanda tangan

1. Buat keystore (sekali saja, simpan di luar repositori dan cadangkan dengan aman):

   ```sh
   keytool -genkey -v -keystore ~/jujur-release.jks -keyalg RSA -keysize 2048 \
     -validity 10000 -alias jujur
   ```

2. Buat `android/key.properties` (sudah ada di `.gitignore`, jangan di-commit):

   ```properties
   storeFile=/home/anda/jujur-release.jks
   storePassword=...
   keyAlias=jujur
   keyPassword=...
   ```

3. Bangun:

   ```sh
   flutter build apk --release          # atau: flutter build appbundle --release
   ```

Tanpa `key.properties`, build rilis tetap dibuat tetapi **tidak ditandatangani** dan tidak dapat
dipasang sampai ditandatangani (`apksigner`).

ID aplikasi bawaan `id.jujur.app` dapat diganti tanpa mengubah berkas:

```sh
flutter build apk --release -Pjujur.applicationId=com.contoh.jujur
```

Versi diatur di `pubspec.yaml` (`version: 1.0.0+1`). Teks versi di layar Tentang dapat
disetel dengan `--dart-define=JUJUR_VERSION=1.0.0`.

## Izin Android

Hanya `POST_NOTIFICATIONS` (diminta saat pengguna mengaktifkan pengingat) dan
`RECEIVE_BOOT_COMPLETED` (menjadwalkan ulang pengingat setelah perangkat dinyalakan ulang).
Build rilis tidak memiliki izin `INTERNET`; izin itu hanya ada di build debug untuk alat
pengembangan Flutter. Izin alarm tepat waktu sengaja dihapus: pengingat dijadwalkan tidak
tepat (inexact) dan dapat bergeser beberapa menit.

Android Auto Backup dimatikan (`allowBackup=false`, `data_extraction_rules.xml`) agar catatan
pribadi tidak disalin ke awan tanpa tindakan pengguna; gunakan menu Cadangan di aplikasi.
