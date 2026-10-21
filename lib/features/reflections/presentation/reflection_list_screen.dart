import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../data/reflection_repository.dart';

/// Past reflections, newest first, loaded page by page.
class ReflectionListScreen extends ConsumerStatefulWidget {
  const ReflectionListScreen({super.key});

  @override
  ConsumerState<ReflectionListScreen> createState() => _ReflectionListScreenState();
}

class _ReflectionListScreenState extends ConsumerState<ReflectionListScreen> {
  static const _pageSize = 30;
  final _items = <ReflectionSummary>[];
  bool _loading = false;
  bool _done = false;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _more();
  }

  Future<void> _more() async {
    if (_loading || _done) return;
    setState(() => _loading = true);
    try {
      final page = await ref.read(reflectionRepositoryProvider).recent(limit: _pageSize, offset: _items.length);
      if (!mounted) return;
      setState(() {
        _items.addAll(page);
        _done = page.length < _pageSize;
        _loading = false;
        _error = null;
      });
    } on Object catch (e) {
      logError('reflection list', e);
      if (mounted) {
        setState(() {
          _error = e;
          _loading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items.clear();
      _done = false;
    });
    await _more();
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todayProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua refleksi'),
        actions: [
          IconButton(tooltip: 'Cari refleksi', icon: const Icon(Icons.search), onPressed: () => context.push('/search')),
        ],
      ),
      body: _error != null && _items.isEmpty
          ? ErrorView(error: _error!, onRetry: _refresh)
          : _items.isEmpty && _loading
          ? const LoadingView()
          : _items.isEmpty
          ? EmptyState(
              icon: Icons.edit_note,
              title: 'Belum ada refleksi',
              message: 'Refleksi yang Anda tulis akan tampil di sini, terbaru di atas.',
              actionLabel: 'Tulis refleksi hari ini',
              onAction: () => context.push('/reflection/${today.key}').then((_) => _refresh()),
            )
          : NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.extentAfter < 400) _more();
                return false;
              },
              child: ListView.separated(
                itemCount: _items.length + (_done ? 0 : 1),
                separatorBuilder: (_, _) => const RowDivider(),
                itemBuilder: (context, i) {
                  if (i == _items.length) return const LoadingView();
                  final r = _items[i];
                  return ListTile(
                    key: ValueKey(r.date),
                    title: Text(formatLongDate(r.date)),
                    subtitle: Text(r.preview.isEmpty ? '(kosong)' : r.preview, maxLines: 3, overflow: TextOverflow.ellipsis),
                    contentPadding: const EdgeInsets.symmetric(horizontal: Space.page, vertical: Space.xs),
                    onTap: () => context.push('/reflection/${r.date.key}').then((_) => _refresh()),
                  );
                },
              ),
            ),
    );
  }
}
