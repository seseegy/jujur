import 'package:flutter/material.dart';

import '../date/local_date.dart';
import '../date/time_of_day_minutes.dart';

Future<LocalDate?> pickDate(
  BuildContext context, {
  required LocalDate initial,
  LocalDate? first,
  LocalDate? last,
  String? helpText,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: initial.toLocalDateTime(),
    firstDate: (first ?? LocalDate(2000, 1, 1)).toLocalDateTime(),
    lastDate: (last ?? LocalDate(2100, 12, 31)).toLocalDateTime(),
    helpText: helpText,
    cancelText: 'Batal',
    confirmText: 'Pilih',
  );
  return picked == null ? null : LocalDate.fromDateTime(picked);
}

Future<int?> pickTime(BuildContext context, {int? initial, String? helpText}) async {
  final now = TimeOfDay.now();
  final picked = await showTimePicker(
    context: context,
    initialTime: initial == null ? now : TimeOfDay(hour: initial ~/ 60, minute: initial % 60),
    helpText: helpText,
    cancelText: 'Batal',
    confirmText: 'Pilih',
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: child!,
    ),
  );
  return picked == null ? null : picked.hour * 60 + picked.minute;
}

Future<DateRange?> pickRange(BuildContext context, {DateRange? initial, LocalDate? last}) async {
  final picked = await showDateRangePicker(
    context: context,
    firstDate: DateTime(2000),
    lastDate: (last ?? LocalDate(2100, 12, 31)).toLocalDateTime(),
    initialDateRange: initial == null
        ? null
        : DateTimeRange(start: initial.start.toLocalDateTime(), end: initial.end.toLocalDateTime()),
    cancelText: 'Batal',
    confirmText: 'Pilih',
    saveText: 'Simpan',
    helpText: 'Pilih rentang tanggal',
  );
  if (picked == null) return null;
  return DateRange(LocalDate.fromDateTime(picked.start), LocalDate.fromDateTime(picked.end));
}

/// A form row showing an optional time with "set" and "clear" actions.
class TimeField extends StatelessWidget {
  const TimeField({super.key, required this.label, required this.value, required this.onChanged});

  final String label;
  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: value == null
            ? null
            : IconButton(
                tooltip: 'Hapus $label',
                icon: const Icon(Icons.close),
                onPressed: () => onChanged(null),
              ),
      ),
      child: Semantics(
        button: true,
        label: '$label: ${value == null ? 'belum diisi' : MinuteOfDay.format(value!)}',
        excludeSemantics: true,
        child: InkWell(
          onTap: () async {
            final picked = await pickTime(context, initial: value, helpText: label);
            if (picked != null) onChanged(picked);
          },
          child: Text(
            value == null ? 'Pilih' : MinuteOfDay.format(value!),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: value == null ? theme.colorScheme.onSurfaceVariant : null,
            ),
          ),
        ),
      ),
    );
  }
}
