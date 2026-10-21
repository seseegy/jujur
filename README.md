# Jujur

Catatan harian yang jujur, privat, dan luring untuk Android: aktivitas, kebiasaan, salat lima
waktu, ibadah tambahan, dan refleksi — tanpa akun, tanpa internet, tanpa skor.

> "Membantu melihat hari-hari apa adanya, tanpa rasa malu, tekanan, manipulasi, atau
> ketergantungan pada internet."

Spesifikasi produk lengkap ada di [`masterpromt.md`](masterpromt.md) dan
[`fullinfo.md`](fullinfo.md).

## Fitur

- **Hari ini**: tanggal dengan navigasi hari sebelumnya/berikutnya dan pemilih tanggal,
  ringkasan faktual (bukan skor), salat, ibadah pilihan, kebiasaan terjadwal, aktivitas, dan
  pintasan refleksi. Bagian dapat diciutkan (tersimpan). Tombol **Catat** untuk mencatat
  aktivitas dalam beberapa detik.
- **Salat lima waktu** (Subuh, Zuhur, Asar, Magrib, Isya): status Dilaksanakan, Diqada,
  Terlewat, Tidak berlaku, atau *Belum dicatat* (tidak pernah disimpulkan dari jam). Jam
  pelaksanaan, berjamaah, catatan, tabel 7 hari, koreksi dengan "Urungkan".
- **Waktu salat opsional**: diatur manual, atau dihitung di perangkat (12 metode termasuk
  Kemenag RI, koordinat diisi manual tanpa izin lokasi, mazhab Asar, penyesuaian menit, zona
  waktu). Pengingat salat opsional.
- **Ibadah lainnya**: Tilawah, Murajaah, Dzikir pagi/petang, Sedekah, Puasa sunnah, Shalat
  sunnah, Tahajud, Dhuha, dan ibadah buatan sendiri; jenis centang/jumlah/durasi/catatan.
  Semuanya opsional dan dipilih sendiri untuk tampil.
- **Kebiasaan**: setiap hari, hari tertentu, setiap N hari, atau sekali; target dan satuan;
  status Selesai/Sebagian/Dilewati/Tidak dilakukan; pengingat; urutan; arsip. Perubahan jadwal
  berlaku ke depan saja (jadwal berversi). Rangkaian (streak) opsional dengan penjelasan.
- **Aktivitas**: judul, kategori, tanggal, jam mulai/selesai (termasuk melewati tengah malam
  secara eksplisit), durasi, status, catatan, tag; buat, ubah, duplikat, hapus dengan urungkan.
- **Refleksi**: tulisan bebas dan pertanyaan panduan yang dapat diatur; autosave dengan
  indikator "Tersimpan", disimpan saat keluar/berpindah tanggal/latar belakang.
- **Riwayat**: kalender bulanan dengan titik penanda (bukan penilaian), filter jenis catatan,
  ringkasan hari/minggu/bulan, buka dan edit tanggal mana pun.
- **Ringkasan**: rentang 7/30 hari, bulan ini/lalu, atau pilihan sendiri; ringkasan teks,
  perbandingan periode sebelumnya, distribusi kategori, tabel salat, kebiasaan per jadwal,
  ibadah, hari refleksi, definisi setiap angka, tautan ke catatan terkait.
- **Pencarian** lokal: aktivitas, kebiasaan, catatan, refleksi; filter tanggal, kategori, status.
- **Cadangan & pemulihan**: ZIP bermanifes dengan checksum, enkripsi AES-256-GCM opsional,
  validasi penuh sebelum mengubah data, mode *Ganti semua* (dengan konfirmasi) atau *Gabungkan*
  (tidak pernah menimpa data lokal). Lihat [`docs/BACKUP_FORMAT.md`](docs/BACKUP_FORMAT.md).
- **Ekspor** CSV (UTF-8, aman dari formula injection) dan JSON, dengan rentang tanggal, jenis,
  kategori, dan opsi catatan.
- **Pengaturan**: tema sistem/terang/gelap, bahasa, awal minggu, salat, ibadah, kategori,
  pertanyaan refleksi, pengingat, data, privasi, tentang.

## Privasi

Tidak ada izin internet di build rilis, tidak ada analitik, iklan, akun, sinkronisasi awan,
atau AI. Notifikasi tidak memuat isi refleksi dan tidak menandai apa pun sebagai selesai.

## Dokumentasi

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — struktur, teknologi, navigasi, desain, risiko
- [`docs/DATA_MODEL.md`](docs/DATA_MODEL.md) — skema, keputusan model data, migrasi
- [`docs/BACKUP_FORMAT.md`](docs/BACKUP_FORMAT.md) — format cadangan dan aturan pemulihan
- [`docs/BUILD.md`](docs/BUILD.md) — menjalankan, test, APK, rilis bertanda tangan
- [`docs/STATUS.md`](docs/STATUS.md) — hasil test dan build yang benar-benar dijalankan, batasan

## Mulai cepat

```sh
flutter pub get
flutter test
flutter run
flutter build apk --debug
```
