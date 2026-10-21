# Arsitektur

## Ringkasan kebutuhan

Aplikasi Android luring dan privat untuk mencatat aktivitas harian, kebiasaan, salat lima
waktu, ibadah tambahan, dan refleksi. Prinsip yang menentukan desain:

1. Database lokal adalah satu-satunya sumber kebenaran; tidak ada server, akun, atau internet.
2. "Belum dicatat" berbeda dari "tidak dilakukan" dan "tidak berlaku" — dan tidak pernah
   disimpulkan dari jam atau dari hari yang berlalu.
3. Cadangan yang dapat divalidasi dan dipulihkan adalah fitur inti.
4. UI tenang: tipografi, jarak, dan garis pemisah; tanpa skor, gamifikasi, atau emoji.

## Teknologi

| Kebutuhan | Paket | Catatan |
| --- | --- | --- |
| State & DI | `flutter_riverpod` 3 | Provider untuk repositori, `StreamProvider` untuk query |
| Database | `drift` + `sqlite3` | FK, transaksi, indeks, migrasi bertahap dengan snapshot skema |
| Navigasi | `go_router` | `StatefulShellRoute` menjaga state tiap tab |
| Tanggal/format | `intl`, `flutter_localizations` | Locale `id_ID` |
| Zona waktu | `timezone`, `flutter_timezone` | Hanya untuk penjadwalan pengingat & waktu salat |
| Waktu salat | `adhan` | Perhitungan astronomis lokal, metode dipilih pengguna |
| Pengingat | `flutter_local_notifications` | Inexact, dijadwalkan ulang saat aplikasi dibuka |
| Cadangan | `archive`, `crypto`, `cryptography` | ZIP, SHA-256, AES-256-GCM + PBKDF2 |
| Berkas | `file_picker`, `share_plus`, `path_provider` | SAF; tanpa izin penyimpanan |
| ID | `uuid` | UUID v4 |

Tidak ada SharedPreferences: pengaturan disimpan di tabel `app_settings` agar ikut transaksi
dan cadangan.

## Struktur kode

```
lib/
  main.dart, app/            bootstrap, app, router, shell, providers, tema
  core/
    database/                tabel, AppDatabase, migrasi, pembuka berkas, data bawaan
    date/                    LocalDate, DateRange, menit-dalam-hari
    backup/                  format, penulis, pembaca/validator, pemulihan, kripto
    export/                  CSV writer, layanan ekspor
    notifications/           layanan notifikasi, perencana & sinkronisasi pengingat
    files/                   SAF / share / pick
    errors/, formatters/, util/, widgets/   komponen bersama
  features/<fitur>/{data,domain,presentation}
    today, activities, categories, habits, prayers, worship, reflections,
    history, insights, search, settings, backup, export, onboarding
```

Aturan: widget tidak menyentuh database; query ada di repositori (`data/`), aturan bisnis yang
murni (jadwal, rangkaian, validasi, statistik) ada di `domain/` dan diuji tanpa Flutter.

## Peta navigasi

```
Bottom nav: Hari ini | Riwayat | Ringkasan | Pengaturan
Hari ini ─ salat (/prayers/:date) ─ ibadah (/settings/worship)
         ─ kebiasaan (/habits, /habits/new, /habits/:id, /habits/:id/edit)
         ─ aktivitas (sheet cepat, /activity/new, /activity/:id)
         ─ refleksi (/reflection/:date, /reflections)
Riwayat  ─ kalender → /day/:date (tampilan hari yang dapat diedit), /search
Ringkasan ─ metrik → /search?…, /habits/:id, /reflection/:date
Pengaturan ─ /settings/prayer, /settings/worship, /settings/categories, /settings/prompts,
             /settings/backup, /settings/export, /settings/privacy, /settings/about
/onboarding (sekali, dapat dilewati)
```

## Sistem desain

- Warna (`app_colors.dart`): latar off-white hangat `#F7F6F2`, permukaan putih, hijau hutan
  `#285747` sebagai aksen, teks arang; tema gelap dengan latar `#151715`. Kontras teks ≥ 4,5:1
  (diperiksa dengan `textContrastGuideline` di widget test).
- Tipografi: font sistem (Roboto) dengan skala tetap; angka tabular untuk waktu dan jumlah.
- Spasi 4/8/12/16/20/24/32; dua radius saja (8 dan 12).
- Bagian dipisahkan oleh label kecil berhuruf kapital dan ruang kosong, bukan kartu.
- Status selalu memakai bentuk ikon berbeda **dan** teks (bukan warna saja).
- Interaksi: target sentuh ≥ 48dp, "Urungkan" untuk perubahan yang dapat dibalik, konfirmasi
  hanya untuk tindakan destruktif, tombol dinonaktifkan selama operasi penting berjalan.

## Register risiko

| Risiko | Mitigasi |
| --- | --- |
| Kehilangan data karena migrasi | Transaksi per migrasi, salinan `.bak` sebelum upgrade, tidak pernah reset; test migrasi |
| Cadangan rusak/terpotong | Checksum, validasi penuh sebelum menulis, verifikasi setelah membuat, pemulihan transaksional |
| Tanggal salah karena UTC/zona waktu | Kunci tanggal lokal, aritmetika kalender, `todayProvider` diperbarui saat resume & tengah malam |
| Refleksi hilang saat aplikasi ditutup | Autosave 800 ms, simpan saat keluar/berpindah tanggal/latar belakang, penyimpanan berurutan |
| Pengingat tidak tepat waktu | Disampaikan sebagai "dapat bergeser", tidak ada fitur yang bergantung padanya |
| Rate limit Maven saat build di sandbox | Mirror Maven Central di init script Gradle lingkungan (bukan bagian proyek) |
