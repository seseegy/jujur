import 'package:flutter/material.dart';

import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/formatters/formatters.dart';
import '../../habits/domain/recurrence.dart';

/// Month grid with one restrained dot for dates that have records.
class MonthCalendar extends StatelessWidget {
  const MonthCalendar({
    super.key,
    required this.month,
    required this.weekStart,
    required this.today,
    required this.selected,
    required this.hasMarker,
    required this.onSelect,
  });

  final LocalDate month;
  final int weekStart;
  final LocalDate today;
  final LocalDate selected;
  final bool Function(LocalDate) hasMarker;
  final ValueChanged<LocalDate> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final first = month.firstOfMonth.startOfWeek(weekStart);
    final weeks = ((first.daysUntil(month.lastOfMonth) + 1) / 7).ceil();
    final weekdayOrder = [for (var i = 0; i < 7; i++) (weekStart - 1 + i) % 7];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Space.md),
      child: Column(
        children: [
          Row(
            children: [
              for (final w in weekdayOrder)
                Expanded(
                  child: ExcludeSemantics(
                    child: Center(child: Text(shortWeekdayNames[w], style: theme.textTheme.labelSmall)),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Space.xs),
          for (var w = 0; w < weeks; w++)
            Row(
              children: [
                for (var d = 0; d < 7; d++)
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        final date = first.addDays(w * 7 + d);
                        final inMonth = date.month == month.month && date.year == month.year;
                        final isSelected = date == selected;
                        final isToday = date == today;
                        final marked = hasMarker(date);
                        return Semantics(
                          button: true,
                          selected: isSelected,
                          label: '${formatLongDate(date)}${isToday ? ', hari ini' : ''}${marked ? ', ada catatan' : ''}',
                          excludeSemantics: true,
                          child: InkWell(
                            borderRadius: Radii.smallAll,
                            onTap: () => onSelect(date),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: isSelected ? scheme.primaryContainer : null,
                                borderRadius: Radii.smallAll,
                                border: isToday && !isSelected ? Border.all(color: scheme.outline) : null,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${date.day}',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: !inMonth
                                          ? scheme.onSurfaceVariant.withValues(alpha: 0.5)
                                          : isSelected
                                          ? scheme.onPrimaryContainer
                                          : scheme.onSurface,
                                      fontWeight: isToday ? FontWeight.w600 : null,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Container(
                                    width: 5,
                                    height: 5,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: marked
                                          ? (isSelected ? scheme.onPrimaryContainer : scheme.primary)
                                          : Colors.transparent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
