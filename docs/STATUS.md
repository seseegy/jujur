# Status, hasil verifikasi, dan batasan

Dicatat pada 21 Oktober 2026 dengan Flutter 3.47.7 (Dart 3.13.5), Android SDK 36,
di lingkungan Linux tanpa perangkat atau emulator Android.

## Perintah yang dijalankan dan hasilnya

| Perintah | Hasil |
| --- | --- |
| `flutter analyze` | Tidak ada masalah |
| `flutter test` | **116 test lulus**, 0 gagal |
| `flutter build apk --debug` | Berhasil: `build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter build apk --release` | Berhasil (R8 + resource shrinking), APK **tidak ditandatangani** karena tidak ada `key.properties` |
| `flutter build apk --release --split-per-abi` | Berhasil: arm64-v8a 24,5 MB, armeabi-v7a 22,4 MB, x86_64 25,9 MB |
| `apkanalyzer manifest permissions` (rilis) | `POST_NOTIFICATIONS`, `RECEIVE_BOOT_COMPLETED`, `VIBRATE` (dari plugin notifikasi), izin internal plugin. **Tanpa `INTERNET`** |
| `aapt2 dump resources` (rilis) | `drawable/ic_notification` ada (sebelumnya terhapus oleh resource shrinking; diperbaiki dengan `res/raw/keep.xml`) |

`flutter test integration_test/app_test.dart` **tidak dijalankan**: lingkungan ini tidak
memiliki perangkat Android maupun KVM untuk emulator. Isi test tersebut sama dengan test alur
lengkap dan widget test yang lulus di host.

## Cakupan test

| Berkas | Test | Isi |
| --- | --- | --- |
| `test/backup/backup_test.dart` | 28 | Manifes & checksum; pemulihan ke database kosong; ganti atas data yang ada; cadangan kosong; gabung tanpa menimpa (ID sama, kunci alami sama); pratinjau tidak mengubah data; pemulihan terputus dan kegagalan tulis → rollback; cadangan skema v1; penolakan: bukan ZIP, tanpa manifes, tanpa data, versi format/skema tidak didukung, format lain, checksum salah, JSON rusak, ID ganda, kunci alami ganda, relasi rusak, tipe/enum/tanggal salah, jumlah tidak cocok, database tetap utuh; enkripsi (kata sandi salah/kosong, salt & nonce unik, teks tidak terbaca) |
| `test/database/database_test.dart` | 10 | Data bertahan setelah database ditutup & dibuka; FK; unique; tidak ada baris ganda saat update; rollback transaksi; arsip menjaga riwayat; perubahan jadwal tidak menulis ulang riwayat; jenis pencatatan terkunci; kategori terpakai tidak terhapus; skema cadangan = kolom database |
| `test/database/generated/jujur/migration_test.dart` | 2 | Skema v1→v2 tervalidasi; data v1 utuh setelah migrasi |
| `test/database/migration_file_test.dart` | 2 | Salinan `.v1.bak` dibuat; migrasi gagal tidak mereset/menghapus berkas |
| `test/domain/*` | 57 | Tanggal (kabisat, batas bulan/tahun, DST, awal minggu), jadwal & rangkaian, validasi aktivitas & kebiasaan, CSV (escape, BOM, formula injection), ekspor CSV/JSON & filter, statistik dari dataset yang diketahui (termasuk "belum dicatat" ≠ terlewat), waktu salat & perencana pengingat, pencarian & refleksi |
| `test/widget/*` | 16 | Onboarding dapat dilewati; navigasi 4 tab; empty state; catat & urungkan salat; status Terlewat eksplisit; centang kebiasaan; tambah cepat + validasi; ubah aktivitas; konfirmasi buang perubahan; autosave refleksi & simpan saat keluar; tema gelap tersimpan; label aksesibilitas + pedoman target sentuh/label/kontras; navigasi tanggal; empty state riwayat & ringkasan; layar kecil + teks 160% tanpa overflow; empty state benar-benar di tengah layar |
| `test/workflow/full_workflow_test.dart` | 1 | Alur lengkap §22.4 lewat UI pada berkas database nyata dengan semua koneksi jaringan diblokir: buka aplikasi → buat kebiasaan → centang → tutup & buka ulang → verifikasi → ubah salat kemarin → tulis refleksi → cadangan → hapus data → pulihkan → verifikasi → ekspor CSV → periksa isi. Tidak ada percobaan koneksi jaringan |

Pemilih berkas sistem (SAF) tidak dapat dijalankan di test host, sehingga langkah cadangan dan
ekspor pada test alur memakai layanan yang sama yang dipanggil layar Cadangan/Ekspor.

## Definition of Done

- [x] Aplikasi Flutter berhasil dibangun (debug dan rilis) di lingkungan ini.
- [x] Navigasi utama berfungsi (widget test).
- [x] Aktivitas dapat dibuat, diubah, diduplikat, dihapus (dengan urungkan).
- [x] Kebiasaan dapat dibuat, dicatat, diubah, diarsipkan; riwayat tetap utuh saat definisi berubah.
- [x] Lima salat dicatat terpisah; catatan yang tidak ada tidak dianggap terlewat.
- [x] Ibadah tambahan opsional berfungsi.
- [x] Refleksi tersimpan dengan benar (autosave, simpan saat keluar/latar belakang).
- [x] Riwayat dapat dijelajahi dan diedit.
- [x] Statistik berasal dari catatan nyata (diuji dengan dataset yang diketahui).
- [x] Pencarian dan filter bekerja luring.
- [x] Pengaturan tersimpan (di database) dan bertahan setelah aplikasi dibuka ulang.
- [x] Data bertahan setelah aplikasi ditutup dan dibuka ulang (test database & alur lengkap).
- [x] Migrasi menjaga data (test v1→v2, salinan pra-upgrade, kegagalan tidak mereset).
- [x] Ekspor JSON dan CSV berfungsi.
- [x] Cadangan penuh, validasi, dan pemulihan berfungsi; kegagalan validasi tidak mengubah data.
- [x] Pemulihan destruktif memerlukan konfirmasi eksplisit.
- [x] Cadangan dan pemulihan memiliki test otomatis.
- [x] Tema terang dan gelap berfungsi.
- [x] Empty, loading, dan error state diimplementasikan.
- [x] Aksesibilitas ditinjau (label semantik, target sentuh ≥ 48dp, kontras, status tidak hanya warna, teks besar).
- [x] Tidak ada fitur inti yang bergantung pada internet (tanpa izin INTERNET di rilis; test alur dengan jaringan diblokir).
- [x] Tidak ada tombol utama yang hanya tampilan.
- [x] `flutter analyze` dijalankan, tanpa masalah.
- [x] Test dijalankan dan hasilnya dicatat di atas.
- [x] Hasil build Android diverifikasi (APK ada, izin dan resource diperiksa). Belum diuji di perangkat fisik.

## Audit UI (ringkas)

Ditinjau dari render layar nyata (terang dan gelap) dengan font Roboto:

- Bagian dibedakan dengan label kecil dan ruang kosong, tanpa kartu bertumpuk; satu warna aksen.
- Diperbaiki: kolom status terlalu lebar sehingga nama kebiasaan terlipat; header tabel salat
  di Ringkasan terpotong (tabel diputar: status sebagai baris); dropdown meluap di layar sempit;
  sheet bawah kini menutupi navigasi bawah; subjudul ganda di Pengaturan; teks komponen kini
  memakai keluarga font yang sama.
- Perlu tinjauan manusia: ikon aplikasi (huruf "j" sederhana) dan nada teks Indonesia di
  perangkat nyata.

## Batasan yang diketahui

- **Belum diuji di perangkat fisik/emulator.** Perilaku pemilih berkas (SAF), lembar bagikan,
  izin notifikasi Android 13+, dan pengiriman pengingat hanya diverifikasi lewat kode dan
  konfigurasi, bukan dijalankan.
- **Pengingat** dijadwalkan tidak tepat waktu (inexact) untuk 7 hari ke depan dan diperbarui
  setiap aplikasi dibuka. Jika aplikasi tidak dibuka lebih dari 7 hari, pengingat berhenti.
- **Bahasa**: hanya Bahasa Indonesia. Pengaturan bahasa menyatakannya dengan jelas.
- **Ikon kebiasaan**: kolom `icon` ada di skema tetapi belum ada pemilih ikon; penanda visual
  memakai warna opsional dari palet terbatas.
- **Durasi aktivitas** dihitung sebagai menit jam dinding; pada malam pergantian DST bisa
  berbeda satu jam (tidak berlaku di Indonesia).
- **Enkripsi cadangan** memakai PBKDF2 600.000 iterasi dalam Dart murni (±3 detik di mesin
  uji; di ponsel bisa lebih lama). Proses berjalan di isolate terpisah sehingga UI tidak beku.
- **Ukuran APK**: build rilis "fat" berisi tiga ABI (71 MB); gunakan `--split-per-abi` atau
  App Bundle untuk distribusi (±25 MB per ABI).
- Saat build di sandbox ini, Maven Central sempat membalas HTTP 429; build memakai init script
  Gradle lingkungan (di luar repositori) yang mengarahkan Maven Central ke mirror Google.

## Saran pengembangan berikutnya

1. Jalankan `integration_test/app_test.dart` di perangkat nyata dan uji manual alur SAF,
   lembar bagikan, dan notifikasi.
2. Pemilih ikon kebiasaan dan bahasa Inggris (string sudah terpusat per layar).
3. Pengingat yang lebih tahan lama (WorkManager untuk menjadwalkan ulang tanpa membuka aplikasi).
4. Cadangan otomatis berkala ke folder pilihan pengguna (SAF persistable URI).
5. Widget layar beranda untuk mencatat salat dengan cepat.
