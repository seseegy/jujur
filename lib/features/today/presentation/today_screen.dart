import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../activities/presentation/quick_add_sheet.dart';
import 'date_header.dart';
import 'day_providers.dart';
import 'day_view.dart';

class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final date = ref.watch(todayTabDateProvider) ?? today;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: DayView(
          key: ValueKey(date),
          date: date,
          header: DateHeader(
            date: date,
            today: today,
            onChanged: ref.read(todayTabDateProvider.notifier).show,
            trailing: IconButton(
              tooltip: 'Refleksi hari ini',
              icon: const Icon(Icons.edit_note),
              onPressed: () => context.push('/reflection/${date.key}'),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'quick-add',
        onPressed: () => showQuickAdd(context, date),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
        tooltip: 'Catat aktivitas',
      ),
    );
  }
}
