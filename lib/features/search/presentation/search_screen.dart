import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/pickers.dart';
import '../../../core/widgets/section.dart';
import '../../../core/widgets/states.dart';
import '../../activities/domain/activity_status.dart';
import '../../today/presentation/day_providers.dart';
import '../data/search_repository.dart';

/// Local search across records. Works fully offline.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initial});

  /// Prefilled filters, e.g. when opened from Insights.
  final SearchQuery? initial;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  late SearchQuery _query = widget.initial ?? const SearchQuery();
  List<SearchHit>? _results;
  Object? _error;
  bool _searching = false;
  Timer? _debounce;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    if (!_query.isEmpty) WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _update(SearchQuery query, {bool immediate = false}) {
    setState(() => _query = query);
    _debounce?.cancel();
    _debounce = Timer(immediate ? Duration.zero : const Duration(milliseconds: 300), _run);
  }

  Future<void> _run() async {
    final generation = ++_generation;
    if (_query.isEmpty) {
      setState(() {
        _results = null;
        _error = null;
      });
      return;
    }
    setState(() => _searching = true);
    try {
      final hits = await ref.read(searchRepositoryProvider).search(_query);
      if (!mounted || generation != _generation) return;
      setState(() {
        _results = hits;
        _error = null;
        _searching = false;
      });
    } on Object catch (e) {
      logError('search', e);
      if (!mounted || generation != _generation) return;
      setState(() {
        _error = e;
        _searching = false;
      });
    }
  }

  void _open(SearchHit hit) {
    final date = hit.date;
    switch (hit.kind) {
      case SearchHitKind.activity:
        context.push('/activity/${hit.id}');
      case SearchHitKind.habit:
        context.push('/habits/${hit.id}');
      case SearchHitKind.reflection:
        context.push('/reflection/${date!.key}');
      case SearchHitKind.habitNote || SearchHitKind.prayerNote || SearchHitKind.worshipNote:
        context.push('/day/${date!.key}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final activityFilters = _query.scope == SearchScope.all || _query.scope == SearchScope.activities;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          autofocus: widget.initial == null,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari aktivitas, kebiasaan, catatan, refleksi',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Hapus pencarian',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _controller.clear();
                      _update(_query.copyWith(text: ''), immediate: true);
                    },
                  ),
          ),
          onChanged: (v) => _update(_query.copyWith(text: v)),
          onSubmitted: (_) => _update(_query, immediate: true),
        ),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: Space.pageInsets,
              children: [
                for (final s in SearchScope.values)
                  Padding(
                    padding: const EdgeInsets.only(right: Space.sm),
                    child: ChoiceChip(
                      label: Text(s.label),
                      selected: _query.scope == s,
                      onSelected: (_) => _update(_query.copyWith(scope: s), immediate: true),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: Space.pageInsets,
            child: Wrap(
              spacing: Space.sm,
              children: [
                InputChip(
                  avatar: const Icon(Icons.date_range, size: 18),
                  label: Text(_query.range == null ? 'Semua tanggal' : formatRange(_query.range!)),
                  onPressed: () async {
                    final picked = await pickRange(context, initial: _query.range);
                    if (picked != null) _update(_query.copyWith(range: () => picked), immediate: true);
                  },
                  onDeleted: _query.range == null ? null : () => _update(_query.copyWith(range: () => null), immediate: true),
                  deleteButtonTooltipMessage: 'Hapus filter tanggal',
                ),
                if (activityFilters) ...[
                  PopupMenuButton<String?>(
                    tooltip: 'Filter kategori',
                    onSelected: (v) => _update(_query.copyWith(categoryId: () => v), immediate: true),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: null, child: Text('Semua kategori')),
                      for (final c in categories) PopupMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.label_outline, size: 18),
                      label: Text(
                        _query.categoryId == null
                            ? 'Semua kategori'
                            : categories.where((c) => c.id == _query.categoryId).firstOrNull?.name ?? 'Kategori',
                      ),
                    ),
                  ),
                  PopupMenuButton<ActivityStatus?>(
                    tooltip: 'Filter status',
                    onSelected: (v) => _update(_query.copyWith(activityStatus: () => v), immediate: true),
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: null, child: Text('Semua status')),
                      for (final s in ActivityStatus.values) PopupMenuItem(value: s, child: Text(s.label)),
                    ],
                    child: Chip(
                      avatar: const Icon(Icons.flag_outlined, size: 18),
                      label: Text(_query.activityStatus?.label ?? 'Semua status'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (_query.categoryId != null || _query.activityStatus != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.page, 0),
              child: Text('Filter kategori dan status hanya berlaku untuk aktivitas.', style: theme.textTheme.bodySmall),
            ),
          const SizedBox(height: Space.sm),
          if (_error != null)
            ErrorView(error: _error!, onRetry: _run)
          else if (_results == null)
            const EmptyState(
              icon: Icons.search,
              title: 'Cari di catatan Anda',
              message: 'Pencarian dilakukan di perangkat ini saja, tanpa internet.',
            )
          else if (_searching && _results!.isEmpty)
            const LoadingView()
          else if (_results!.isEmpty)
            const EmptyState(
              icon: Icons.search_off,
              title: 'Tidak ada hasil',
              message: 'Coba kata lain, ubah cakupan, atau hapus filter tanggal.',
            )
          else ...[
            SectionHeader(title: 'Hasil', summary: _results!.length >= 50 ? '50 teratas' : '${_results!.length}'),
            for (final hit in _results!)
              ListTile(
                key: ValueKey('${hit.kind.name}-${hit.id}'),
                title: Text(hit.title),
                subtitle: Text(
                  [
                    if (hit.date != null) formatDate(hit.date!),
                    ?hit.subtitle,
                    if (hit.snippet != null && hit.snippet!.trim().isNotEmpty) '\n${hit.snippet!.trim()}',
                  ].join(' · ').replaceAll(' · \n', '\n'),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                isThreeLine: hit.snippet != null,
                onTap: () => _open(hit),
              ),
          ],
        ],
      ),
    );
  }
}
