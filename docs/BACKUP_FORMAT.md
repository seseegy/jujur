# Format cadangan Jujur (versi format 1)

Cadangan adalah arsip ZIP bernama `jujur-cadangan-YYYYMMDD-HHMMSS.zip` berisi dua berkas.

```
manifest.json        metadata, selalu tidak terenkripsi
data.json            isi data (cadangan biasa)
  atau
data.json.enc        isi data terenkripsi (cadangan berkata sandi)
```

## manifest.json

```json
{
  "format": "jujur-backup",
  "formatVersion": 1,
  "schemaVersion": 2,
  "appVersion": "1.0.0",
  "createdAt": "2026-10-21T02:30:00.000Z",
  "encrypted": false,
  "payload": { "file": "data.json", "sha256": "<hex>", "bytes": 12345 },
  "counts": { "categories": 9, "activities": 120, "...": 0, "settings": 8 },
  "encryption": null
}
```

- `sha256` dihitung atas byte berkas payload sebagaimana tersimpan di ZIP (untuk cadangan
  terenkripsi: atas ciphertext).
- `counts` = jumlah baris per tabel di payload; dicocokkan saat pemulihan.

## data.json

```json
{
  "schemaVersion": 2,
  "tables": {
    "categories": [ { "id": "cat-belajar", "name": "Belajar", "...": "..." } ],
    "activities": [ ... ],
    "habits": [ ... ],
    "habit_schedules": [ ... ],
    "habit_records": [ ... ],
    "prayer_records": [ ... ],
    "worship_items": [ ... ],
    "worship_records": [ ... ],
    "reflections": [ ... ],
    "reflection_answers": [ ... ]
  },
  "settings": { "week_start": "1", "...": "..." }
}
```

Setiap baris memakai nama kolom SQL (`snake_case`) dari skema versi `schemaVersion`
(lihat `docs/DATA_MODEL.md` dan `lib/core/backup/backup_schema.dart`). Tipe JSON: teks →
string, bilangan bulat → integer, desimal → number, boolean → `true`/`false`, kosong → `null`.
Tanggal adalah `YYYY-MM-DD`, cap waktu audit adalah milidetik UTC.

Tidak termasuk: pengaturan khusus perangkat (kunci `local.*`, misalnya status lipat bagian
dan waktu cadangan terakhir), cache, dan data sistem operasi.

## Enkripsi (opsional)

```json
"encryption": {
  "algorithm": "AES-256-GCM",
  "kdf": "PBKDF2-HMAC-SHA256",
  "iterations": 600000,
  "salt": "<base64, 16 byte acak>",
  "nonce": "<base64, 12 byte acak>"
}
```

`data.json.enc` = ciphertext AES-256-GCM dari `data.json` diikuti tag autentikasi 16 byte.
Kunci diturunkan dari kata sandi dengan PBKDF2-HMAC-SHA256. Salt dan nonce baru dibuat untuk
setiap cadangan. Kata sandi tidak disimpan; tanpa kata sandi cadangan tidak dapat dipulihkan.
Implementasi memakai paket `cryptography` (tidak ada algoritme buatan sendiri).

## Pembuatan

1. Semua tabel dibaca dalam satu transaksi (snapshot konsisten).
2. Payload dan manifes dibuat, lalu ZIP disusun di memori.
3. **ZIP dibaca ulang dan divalidasi penuh** (termasuk dekripsi). Jika gagal, tidak ada berkas
   yang diserahkan.
4. Berkas diserahkan ke pemilih berkas Android (SAF) atau lembar bagikan. Untuk berbagi,
   berkas ditulis ke direktori sementara privat dengan pola tulis-lalu-ganti-nama.
5. "Berhasil" hanya ditampilkan setelah pemilih berkas mengembalikan lokasi tersimpan.

## Validasi saat pemulihan (sebelum database diubah)

Struktur ZIP → keberadaan manifes → `format` → `formatVersion` didukung → `schemaVersion`
tidak lebih baru dari aplikasi → keberadaan payload → ukuran dan SHA-256 → dekripsi
(jika terenkripsi) → JSON valid → tabel dikenal dan lengkap → kolom dikenal, wajib ada, tipe
benar, nilai enum dikenal, tanggal valid → ID unik per tabel → kunci alami unik (mis. salat +
tanggal) → setiap relasi menunjuk ke baris yang ada di cadangan → jumlah baris sesuai manifes.

Cadangan dari skema lebih lama boleh tidak memuat kolom yang ditambahkan kemudian (kolom itu
memakai nilai bawaan).

## Mode pemulihan

- **Ganti semua**: dalam satu transaksi, semua tabel dan pengaturan (kecuali `local.*`)
  dikosongkan lalu diisi dari cadangan. Memerlukan konfirmasi eksplisit.
- **Gabungkan**: dalam satu transaksi, hanya menambahkan data yang belum ada.
  - ID sama dan isi sama (mengabaikan cap waktu audit) → dilewati sebagai *identik*.
  - ID sama tetapi isi berbeda → *konflik*: data di perangkat dipertahankan.
  - ID berbeda tetapi kunci alami sama (mis. kebiasaan + tanggal yang sama) → *konflik*:
    data di perangkat dipertahankan.
  - Baris anak dari data yang konflik dilewati.
  - Pengaturan hanya ditambahkan jika kuncinya belum ada.
  Data lokal tidak pernah ditimpa oleh penggabungan. Pratinjau penggabungan dihitung dengan
  menjalankan proses yang sama lalu membatalkan transaksinya.

Jika terjadi kegagalan apa pun selama pemulihan, transaksi dibatalkan dan data di perangkat
tetap seperti sebelumnya. Setelah pemulihan, `PRAGMA foreign_key_check` dijalankan.

Test: `test/backup/backup_test.dart`.

## Ekspor (bukan cadangan)

Ekspor CSV/JSON (`lib/core/export/export_service.dart`) ditujukan untuk aplikasi lain dan tidak
dapat dipulihkan. JSON ekspor memakai `"format": "jujur-export"`, `formatVersion: 1`, ID stabil,
dan rentang tanggal. CSV ditulis UTF-8 dengan BOM, baris CRLF, escaping RFC 4180, dan nilai teks
pengguna yang diawali `=`, `+`, `-`, `@`, tab, atau CR diberi awalan `'` di berkas ekspor saja.
