import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../today/presentation/day_providers.dart';
import '../domain/activity_draft.dart';
import '../domain/activity_status.dart';

Future<void> showQuickAdd(BuildContext context, LocalDate date) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => QuickAddSheet(date: date),
);

/// The fastest way to log an activity: a title and, optionally, a category.
class QuickAddSheet extends ConsumerStatefulWidget {
  const QuickAddSheet({super.key, required this.date});
  final LocalDate date;

  @override
  ConsumerState<QuickAddSheet> createState() => _QuickAddSheetState();
}

class _QuickAddSheetState extends ConsumerState<QuickAddSheet> {
  final _title = TextEditingController();
  String? _categoryId;
  ActivityStatus _status = ActivityStatus.done;
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(activityRepositoryProvider).create(
        ActivityDraft(title: _title.text, date: widget.date, categoryId: _categoryId, status: _status),
      );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      showMessageWith(messenger, 'Aktivitas tersimpan.');
    } on ValidationFailure catch (e) {
      setState(() => _error = e.message);
    } on Object catch (e) {
      logError('quick add', e);
      if (mounted) setState(() => _error = describeError(e));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = (ref.watch(categoriesProvider).value ?? const []).where((c) => !c.archived).toList();
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: Space.pageInsets,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Catat aktivitas', style: theme.textTheme.titleLarge),
                  Text(formatLongDate(widget.date), style: theme.textTheme.bodySmall),
                  const SizedBox(height: Space.lg),
                  TextField(
                    controller: _title,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    maxLength: ActivityDraft.maxTitleLength,
                    decoration: InputDecoration(labelText: 'Apa yang Anda lakukan?', errorText: _error, counterText: ''),
                    onSubmitted: (_) => _save(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            SizedBox(
              height: 48,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: Space.pageInsets,
                children: [
                  for (final c in categories)
                    Padding(
                      padding: const EdgeInsets.only(right: Space.sm),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: _categoryId == c.id,
                        onSelected: (s) => setState(() => _categoryId = s ? c.id : null),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Space.sm),
            Padding(
              padding: Space.pageInsets,
              child: SegmentedButton<ActivityStatus>(
                segments: const [
                  ButtonSegment(value: ActivityStatus.done, label: Text('Selesai')),
                  ButtonSegment(value: ActivityStatus.planned, label: Text('Rencana')),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
            ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: Space.pageInsets,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      final router = GoRouter.of(context);
                      Navigator.of(context).pop();
                      router.push(
                        Uri(path: '/activity/new', queryParameters: {
                          'date': widget.date.key,
                          if (_title.text.trim().isNotEmpty) 'title': _title.text.trim(),
                          'category': ?_categoryId,
                        }).toString(),
                      );
                    },
                    child: const Text('Isi detail'),
                  ),
                  const Spacer(),
                  FilledButton(onPressed: _saving ? null : _save, child: const Text('Simpan')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
