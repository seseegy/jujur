import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/pickers.dart';

/// Date heading with previous/next navigation and a date picker.
class DateHeader extends StatelessWidget {
  const DateHeader({
    super.key,
    required this.date,
    required this.today,
    required this.onChanged,
    this.trailing,
  });

  final LocalDate date;
  final LocalDate today;
  final ValueChanged<LocalDate> onChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final relative = relativeDayLabel(date, today);
    final weekday = formatWeekday(date);
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.lg, Space.sm, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  relative == null ? weekday : '$relative · $weekday',
                  style: theme.textTheme.labelMedium,
                ),
              ),
              IconButton(
                tooltip: 'Hari sebelumnya',
                icon: const Icon(Icons.chevron_left),
                onPressed: () => onChanged(date.addDays(-1)),
              ),
              IconButton(
                tooltip: 'Pilih tanggal',
                icon: const Icon(Icons.event_outlined),
                onPressed: () async {
                  final picked = await pickDate(context, initial: date, helpText: 'Buka tanggal');
                  if (picked != null) onChanged(picked);
                },
              ),
              IconButton(
                tooltip: 'Hari berikutnya',
                icon: const Icon(Icons.chevron_right),
                onPressed: () => onChanged(date.addDays(1)),
              ),
              ?trailing,
            ],
          ),
          Semantics(
            header: true,
            child: Text(
              '${date.day} ${formatMonthYear(date)}',
              style: theme.textTheme.headlineSmall,
            ),
          ),
          if (date != today)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => onChanged(today),
                icon: const Icon(Icons.undo, size: 18),
                label: const Text('Kembali ke hari ini'),
              ),
            ),
        ],
      ),
    );
  }
}
