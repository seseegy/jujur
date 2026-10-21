import 'package:drift/drift.dart';

import '../../features/worship/domain/worship_enums.dart';
import 'app_database.dart';

/// Default definitions created with a new database.
///
/// These are definitions (categories and optional worship items), never user
/// records. They use fixed identifiers so that backups from different devices
/// merge instead of producing duplicates.
abstract final class SeedData {
  static const categories = <(String id, String name, String icon)>[
    ('cat-belajar', 'Belajar', 'school'),
    ('cat-bekerja', 'Bekerja', 'work'),
    ('cat-membaca', 'Membaca', 'book'),
    ('cat-olahraga', 'Olahraga', 'fitness'),
    ('cat-keluarga', 'Keluarga', 'family'),
    ('cat-rumah', 'Rumah tangga', 'home'),
    ('cat-proyek', 'Proyek pribadi', 'build'),
    ('cat-istirahat', 'Istirahat', 'rest'),
    ('cat-lainnya', 'Lainnya', 'other'),
  ];

  static const worshipItems =
      <(String id, String name, WorshipTrackingType type, String? unit)>[
        (
          'wsp-tilawah',
          "Tilawah Al-Qur'an",
          WorshipTrackingType.count,
          'halaman',
        ),
        ('wsp-murajaah', 'Murajaah', WorshipTrackingType.duration, 'menit'),
        ('wsp-dzikir-pagi', 'Dzikir pagi', WorshipTrackingType.check, null),
        ('wsp-dzikir-petang', 'Dzikir petang', WorshipTrackingType.check, null),
        ('wsp-sedekah', 'Sedekah', WorshipTrackingType.check, null),
        ('wsp-puasa-sunnah', 'Puasa sunnah', WorshipTrackingType.check, null),
        (
          'wsp-shalat-sunnah',
          'Shalat sunnah',
          WorshipTrackingType.count,
          'rakaat',
        ),
        ('wsp-tahajud', 'Tahajud', WorshipTrackingType.check, null),
        ('wsp-dhuha', 'Dhuha', WorshipTrackingType.check, null),
      ];

  static Future<void> insertDefaults(AppDatabase db, int nowMillis) async {
    await db.batch((b) {
      for (final (i, (id, name, icon)) in categories.indexed) {
        b.insert(
          db.categories,
          CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: Value(icon),
            sortOrder: Value(i),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
      for (final (i, (id, name, type, unit)) in worshipItems.indexed) {
        b.insert(
          db.worshipItems,
          WorshipItemsCompanion.insert(
            id: id,
            name: name,
            trackingType: type,
            unit: Value(unit),
            sortOrder: Value(i),
            createdAt: nowMillis,
            updatedAt: nowMillis,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }
}
