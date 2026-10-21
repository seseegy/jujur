import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/status_mark.dart';
import '../../activities/presentation/activity_section.dart';
import '../../activities/presentation/quick_add_sheet.dart';
import '../../habits/presentation/habit_section.dart';
import '../../prayers/presentation/prayer_section.dart';
import '../../settings/domain/preferences.dart';
import '../../worship/presentation/worship_section.dart';
import 'day_overview.dart';
import 'day_providers.dart';

/// Everything recorded for one date, editable in place. Used by the Today
/// tab and by historical day pages.
class DayView extends ConsumerWidget {
  const DayView({super.key, required this.date, required this.header});

  final LocalDate date;
  final Widget header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs = ref.watch(prefsProvider);
    final today = ref.watch(todayProvider);

    Future<void> toggle(String section) => runGuarded(
      context,
      () => ref.read(settingsRepositoryProvider).setBool(SettingKeys.collapsed(section), !prefs.isCollapsed(section)),
    );

    SectionHeader header0(String id, String title, {String? summary, Widget? trailing}) => SectionHeader(
      title: title,
      summary: summary,
      collapsed: prefs.isCollapsed(id),
      onToggle: () => toggle(id),
      trailing: trailing,
    );

    final prayers = ref.watch(dayPrayersProvider(date)).value;
    final habits = ref.watch(dayHabitsProvider(date)).value ?? const [];
    final activities = ref.watch(dayActivitiesProvider(date)).value ?? const [];
    final reflection = ref.watch(dayReflectionExistsProvider(date)).value ?? false;

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        header,
        DayOverview(
          prayers: prayers,
          habits: habits,
          activities: activities,
          reflectionWritten: reflection,
          showPrayers: prefs.prayerEnabled,
          isFuture: date.isAfter(today),
        ),
        if (prefs.prayerEnabled) ...[
          header0(
            'prayers',
            'Salat',
            summary: prayers == null ? null : '${prayers.recordedCount} dari 5 dicatat',
            trailing: PrayerSectionLink(date: date),
          ),
          if (!prefs.isCollapsed('prayers')) PrayerRows(date: date),
        ],
        header0(
          'worship',
          'Ibadah lainnya',
          trailing: IconButton(
            tooltip: 'Atur ibadah yang ditampilkan',
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/settings/worship'),
          ),
        ),
        if (!prefs.isCollapsed('worship')) WorshipRows(date: date),
        header0(
          'habits',
          'Kebiasaan',
          trailing: IconButton(
            tooltip: 'Kelola kebiasaan',
            icon: const Icon(Icons.tune),
            onPressed: () => context.push('/habits'),
          ),
        ),
        if (!prefs.isCollapsed('habits')) HabitRows(date: date),
        header0(
          'activities',
          'Aktivitas',
          summary: activities.isEmpty ? null : '${activities.length} dicatat',
          trailing: IconButton(
            tooltip: 'Tambah aktivitas',
            icon: const Icon(Icons.add),
            onPressed: () => showQuickAdd(context, date),
          ),
        ),
        if (!prefs.isCollapsed('activities')) ActivityRows(date: date, onAdd: () => showQuickAdd(context, date)),
        const SectionHeader(title: 'Refleksi'),
        _ReflectionTile(date: date, written: reflection),
      ],
    );
  }
}

class _ReflectionTile extends StatelessWidget {
  const _ReflectionTile({required this.date, required this.written});

  final LocalDate date;
  final bool written;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: StatusMark(written ? Mark.done : Mark.unrecorded),
      title: Text(written ? 'Refleksi tersimpan' : 'Tulis refleksi'),
      subtitle: Text(
        written ? 'Buka untuk membaca atau mengubah.' : 'Opsional. Tulis bebas atau jawab pertanyaan yang Anda pilih.',
      ),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: const EdgeInsets.fromLTRB(Space.page, 0, Space.lg, 0),
      onTap: () => context.push('/reflection/${date.key}'),
    );
  }
}
