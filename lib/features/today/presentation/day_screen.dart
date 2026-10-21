import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/date/local_date.dart';
import '../../activities/presentation/quick_add_sheet.dart';
import 'date_header.dart';
import 'day_view.dart';

/// A historical (or future) day opened from History or search. All records
/// can be edited here.
class DayScreen extends ConsumerStatefulWidget {
  const DayScreen({super.key, required this.date});
  final LocalDate date;

  @override
  ConsumerState<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends ConsumerState<DayScreen> {
  late LocalDate _date = widget.date;

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan harian'),
        actions: [
          IconButton(
            tooltip: 'Refleksi tanggal ini',
            icon: const Icon(Icons.edit_note),
            onPressed: () => context.push('/reflection/${_date.key}'),
          ),
        ],
      ),
      body: DayView(
        key: ValueKey(_date),
        date: _date,
        header: DateHeader(date: _date, today: today, onChanged: (d) => setState(() => _date = d)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'day-quick-add',
        onPressed: () => showQuickAdd(context, _date),
        icon: const Icon(Icons.add),
        label: const Text('Catat'),
        tooltip: 'Catat aktivitas',
      ),
    );
  }
}
