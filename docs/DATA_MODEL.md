# Model data dan migrasi

Database: SQLite melalui [Drift](https://drift.simonbinder.eu/). Berkas: `jujur.sqlite` di
direktori dukungan aplikasi (penyimpanan internal, tidak ikut Android Auto Backup).
Definisi tabel: `lib/core/database/tables.dart`. Versi skema saat ini: **2**.

## Konvensi

| Hal | Keputusan | Alasan |
| --- | --- | --- |
| ID | UUID v4 teks (`newId()`), kecuali definisi bawaan (`cat-*`, `wsp-*`) | Stabil lintas perangkat, aman untuk penggabungan cadangan |
| Tanggal catatan | `date_key` teks `YYYY-MM-DD` dari jam lokal saat dicatat | Catatan tidak pindah hari karena konversi UTC atau perubahan zona waktu |
| Jam di dalam hari | `*_minute` = menit sejak tengah malam lokal (0–1439) | Disimpan persis seperti yang dimasukkan pengguna |
| Metadata audit | `created_at`, `updated_at` = milidetik UTC | Urutan waktu yang tidak ambigu |
| "Belum dicatat" | **Tidak ada baris** | Ketiadaan data tidak pernah dianggap gagal atau selesai |
| Pengaturan | Tabel `app_settings` (kunci/nilai) | Ikut transaksi dan cadangan; kunci `local.*` khusus perangkat dan tidak dicadangkan |

Foreign key diaktifkan pada setiap koneksi (`PRAGMA foreign_keys = ON`). Mode WAL dipakai.

## Tabel

| Tabel | Isi | Kunci unik | Hapus |
| --- | --- | --- | --- |
| `app_settings` | Pengaturan | `key` | — |
| `categories` | Kategori aktivitas | `id` | Hanya jika tidak dipakai (FK `RESTRICT`); selain itu diarsipkan |
| `activities` | Aktivitas harian (judul, kategori, tanggal, jam mulai/selesai, `ends_next_day`, durasi, status, catatan, tag) | `id` | Hapus langsung, ada "Urungkan" |
| `habits` | Definisi kebiasaan (nama, jenis pencatatan, satuan, tanggal mulai/akhir, arsip, urutan, pengingat) | `id` | Arsip (disarankan) atau hapus permanen beserta catatannya, dengan konfirmasi |
| `habit_schedules` | **Versi** jadwal & target kebiasaan, berlaku mulai `effective_from` | `(habit_id, effective_from)` | Ikut kebiasaan (`CASCADE`) |
| `habit_records` | Catatan kebiasaan per tanggal: status, nilai, `target_snapshot`, catatan | `(habit_id, date_key)` | Ikut kebiasaan |
| `prayer_records` | Catatan salat: salat, tanggal, status, jam pelaksanaan, jamaah, catatan | `(prayer, date_key)` | Hapus = kembali "Belum dicatat" |
| `worship_items` | Definisi ibadah tambahan (jenis: centang/jumlah/durasi/catatan, tampil di Hari ini, arsip) | `id` | Arsip atau hapus permanen dengan konfirmasi |
| `worship_records` | Catatan ibadah per tanggal | `(item_id, date_key)` | Ikut definisi |
| `reflections` | Satu dokumen refleksi per tanggal (teks bebas) | `date_key` | Hapus dengan konfirmasi |
| `reflection_answers` | Jawaban pertanyaan panduan; teks pertanyaan disimpan bersama jawaban | `(reflection_id, prompt)` | Ikut refleksi |

Indeks tambahan: `date_key` pada `activities`, `habit_records`, `prayer_records`, `worship_records`;
`category_id` pada `activities`.

### Status

| Domain | Nilai tersimpan | Label |
| --- | --- | --- |
| Aktivitas | `done`, `partial`, `planned`, `notDone` | Selesai, Sebagian, Direncanakan, Tidak dilakukan |
| Kebiasaan | `done`, `partial`, `skipped`, `notDone` | Selesai, Sebagian, Dilewati, Tidak dilakukan |
| Salat | `done`, `qadha`, `missed`, `excused` | Dilaksanakan, Diqada, Terlewat, Tidak berlaku |
| Ibadah | `done`, `notDone` | Dilakukan, Tidak dilakukan |

Nama enum dipakai di database dan cadangan; jangan diubah tanpa migrasi.

## Keputusan penting

- **Jadwal kebiasaan berversi.** Mengubah pengulangan atau target membuat versi baru yang
  berlaku mulai hari ini. Tanggal sebelumnya tetap dievaluasi dengan aturan lama, sehingga
  ringkasan masa lalu tidak berubah diam-diam. Setiap catatan juga menyimpan `target_snapshot`.
- **Jenis pencatatan kebiasaan dikunci** setelah ada catatan (centang ↔ jumlah tidak bisa
  dikonversi dengan jujur).
- **Aktivitas melewati tengah malam** harus ditandai eksplisit (`ends_next_day`). Jam selesai yang
  lebih awal dari jam mulai tanpa tanda itu ditolak, bukan dibungkus otomatis. Durasi dihitung
  sebagai menit jam dinding; pada malam pergantian DST durasi bisa berbeda satu jam dari waktu
  sebenarnya (Indonesia tidak memakai DST).
- **Refleksi**: satu dokumen per tanggal. Jawaban dicocokkan dengan teks pertanyaan, sehingga
  mengubah daftar pertanyaan tidak menimpa jawaban lama. Refleksi yang dikosongkan seluruhnya
  dianggap tidak ada (barisnya dihapus) agar tidak terhitung sebagai "hari dengan refleksi".
- **Tidak ada baris yang dibuat untuk setiap tanggal.** Riwayat dan statistik menghitung hari
  terjadwal dari aturan jadwal, bukan dari baris kosong.

## Migrasi

- Versi skema dinaikkan di `AppDatabase.currentSchemaVersion` dan snapshot skema disimpan di
  `drift_schemas/` (`dart run drift_dev make-migrations`).
- Langkah migrasi ditulis di `onUpgrade` memakai helper `stepByStep` hasil generate, dijalankan
  dalam transaksi. Jika satu langkah gagal, transaksi dibatalkan dan database tetap di versi lama.
- Sebelum membuka database yang perlu di-upgrade, berkasnya disalin ke
  `jujur.sqlite.v<versi>.bak` (`database_opener.dart`).
- Database **tidak pernah dihapus atau di-reset** untuk mengatasi kegagalan migrasi. Jika
  pembukaan gagal, aplikasi menampilkan layar galat tanpa menyentuh data.
- Riwayat: v1 → v2 menambah kolom `activities.tags` (nullable).

Test: `test/database/generated/jujur/migration_test.dart` (skema dan integritas data v1→v2),
`test/database/migration_file_test.dart` (salinan pra-upgrade, kegagalan migrasi tidak
mereset berkas).
