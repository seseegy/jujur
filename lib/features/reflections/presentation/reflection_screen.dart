import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../app/theme/app_spacing.dart';
import '../../../core/date/local_date.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/formatters/formatters.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/states.dart';
import '../data/reflection_repository.dart';

enum SaveState { idle, pending, saving, saved, failed }

/// Daily reflection editor.
///
/// Persistence strategy: edits are saved 800 ms after the user stops typing,
/// and immediately when the screen closes, the date changes, or the app goes
/// to the background. Saves are serialized so an older save can never
/// overwrite a newer one.
class ReflectionScreen extends ConsumerStatefulWidget {
  const ReflectionScreen({super.key, required this.date});
  final LocalDate date;

  @override
  ConsumerState<ReflectionScreen> createState() => _ReflectionScreenState();
}

class _ReflectionScreenState extends ConsumerState<ReflectionScreen> with WidgetsBindingObserver {
  static const _debounce = Duration(milliseconds: 800);

  late LocalDate _date = widget.date;
  late final ReflectionRepository _repo = ref.read(reflectionRepositoryProvider);
  final _body = TextEditingController();
  final Map<String, TextEditingController> _answers = {};
  List<String> _prompts = const [];
  bool _showPrompts = false;
  bool _loading = true;
  bool _exists = false;
  Timer? _timer;
  bool _dirty = false;
  Future<void>? _inFlight;
  SaveState _state = SaveState.idle;
  DateTime? _savedAt;
  Object? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // Final flush; the repository outlives this widget.
    if (_dirty) unawaited(_persist(_date, _snapshotBody(), _snapshotAnswers()));
    _body.dispose();
    for (final c in _answers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive || state == AppLifecycleState.detached) {
      _flush();
    }
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final content = await _repo.load(_date);
      final configured = ref.read(prefsProvider).reflectionPrompts;
      // Show configured prompts plus any prompt answered earlier, so past
      // answers stay visible even after the prompt list changes.
      final prompts = [...configured, ...content.answers.keys.where((p) => !configured.contains(p))];
      for (final c in _answers.values) {
        c.dispose();
      }
      _answers
        ..clear()
        ..addAll({
          for (final p in prompts) p: TextEditingController(text: content.answers[p] ?? '')..addListener(_onChanged),
        });
      _body
        ..removeListener(_onChanged)
        ..text = content.body
        ..addListener(_onChanged);
      if (!mounted) return;
      setState(() {
        _prompts = prompts;
        _exists = content.id != null;
        _showPrompts = content.answers.isNotEmpty;
        _savedAt = content.updatedAt;
        _state = SaveState.idle;
        _dirty = false;
        _loading = false;
      });
    } on Object catch (e) {
      logError('load reflection', e);
      if (mounted) {
        setState(() {
          _loadError = e;
          _loading = false;
        });
      }
    }
  }

  void _onChanged() {
    _dirty = true;
    if (_state != SaveState.pending) setState(() => _state = SaveState.pending);
    _timer?.cancel();
    _timer = Timer(_debounce, _flush);
  }

  String _snapshotBody() => _body.text;
  Map<String, String> _snapshotAnswers() => {for (final e in _answers.entries) e.key: e.value.text};

  /// Saves pending edits now. Waits for any save already running first.
  Future<void> _flush() async {
    _timer?.cancel();
    if (!_dirty) return _inFlight ?? Future.value();
    _dirty = false;
    final date = _date;
    final body = _snapshotBody();
    final answers = _snapshotAnswers();
    if (mounted) setState(() => _state = SaveState.saving);
    try {
      await _persist(date, body, answers);
      if (mounted && date == _date) {
        setState(() {
          _state = _dirty ? SaveState.pending : SaveState.saved;
          _savedAt = DateTime.now();
          _exists = !(body.trim().isEmpty && answers.values.every((a) => a.trim().isEmpty));
        });
      }
    } on Object catch (e) {
      logError('save reflection', e);
      _dirty = true;
      if (mounted) {
        setState(() => _state = SaveState.failed);
        showError(context, e);
      }
    }
  }

  Future<void> _persist(LocalDate date, String body, Map<String, String> answers) {
    final previous = _inFlight ?? Future<void>.value();
    final next = previous.catchError((_) {}).then((_) => _repo.save(date, body: body, answers: answers));
    _inFlight = next;
    return next;
  }

  Future<void> _changeDate(LocalDate date) async {
    await _flush();
    if (!mounted) return;
    setState(() => _date = date);
    await _load();
  }

  Future<void> _delete() async {
    final confirmed = await confirmAction(
      context,
      title: 'Hapus refleksi?',
      message: 'Refleksi tanggal ${formatDate(_date)} akan dihapus permanen dari perangkat ini. '
          'Tindakan ini tidak dapat dibatalkan, kecuali Anda memiliki cadangan.',
      confirmLabel: 'Hapus',
      destructive: true,
    );
    if (!confirmed || !mounted) return;
    _timer?.cancel();
    _dirty = false;
    await _inFlight?.catchError((_) {});
    if (!mounted) return;
    final ok = await runGuarded(context, () => _repo.delete(_date), success: 'Refleksi dihapus.');
    if (ok) await _load();
  }

  String get _statusText => switch (_state) {
    SaveState.pending => 'Belum tersimpan…',
    SaveState.saving => 'Menyimpan…',
    SaveState.failed => 'Gagal menyimpan. Perubahan masih ada di layar.',
    SaveState.saved || SaveState.idle =>
      _savedAt == null ? 'Tersimpan otomatis saat Anda menulis.' : 'Tersimpan ${formatClock(_savedAt!)}',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) _flush();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Refleksi'),
          actions: [
            IconButton(
              tooltip: 'Hari sebelumnya',
              icon: const Icon(Icons.chevron_left),
              onPressed: () => _changeDate(_date.addDays(-1)),
            ),
            IconButton(
              tooltip: 'Hari berikutnya',
              icon: const Icon(Icons.chevron_right),
              onPressed: () => _changeDate(_date.addDays(1)),
            ),
            PopupMenuButton<String>(
              tooltip: 'Pilihan lain',
              onSelected: (v) async {
                if (v == 'delete') await _delete();
                if (v == 'list' && context.mounted) {
                  await _flush();
                  if (context.mounted) context.push('/reflections');
                }
                if (v == 'prompts' && context.mounted) context.push('/settings/prompts');
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'list', child: Text('Semua refleksi')),
                const PopupMenuItem(value: 'prompts', child: Text('Atur pertanyaan')),
                if (_exists) const PopupMenuItem(value: 'delete', child: Text('Hapus refleksi')),
              ],
            ),
          ],
        ),
        body: _loading
            ? const LoadingView()
            : _loadError != null
            ? ErrorView(error: _loadError!, onRetry: _load)
            : ListView(
                padding: const EdgeInsets.fromLTRB(Space.page, 0, Space.page, Space.xxxl),
                children: [
                  Text(formatLongDate(_date), style: theme.textTheme.titleMedium),
                  const SizedBox(height: Space.xs),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _statusText,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _state == SaveState.failed ? theme.colorScheme.error : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  TextField(
                    controller: _body,
                    minLines: 8,
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    style: theme.textTheme.bodyLarge,
                    decoration: const InputDecoration(
                      hintText: 'Tulis dengan bebas tentang hari ini…',
                      labelText: 'Catatan bebas',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: Space.lg),
                  if (_prompts.isNotEmpty)
                    Semantics(
                      button: true,
                      expanded: _showPrompts,
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Pertanyaan panduan'),
                        subtitle: const Text('Opsional. Jawab yang Anda perlukan saja.'),
                        trailing: Icon(_showPrompts ? Icons.expand_less : Icons.expand_more),
                        onTap: () => setState(() => _showPrompts = !_showPrompts),
                      ),
                    ),
                  if (_showPrompts)
                    for (final p in _prompts)
                      Padding(
                        padding: const EdgeInsets.only(top: Space.md),
                        child: TextField(
                          controller: _answers[p],
                          minLines: 2,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: InputDecoration(labelText: p, alignLabelWithHint: true),
                        ),
                      ),
                  const SizedBox(height: Space.xl),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: _state == SaveState.saving ? null : () async {
                        _dirty = true;
                        await _flush();
                        if (context.mounted && _state == SaveState.saved) showMessage(context, 'Catatan tersimpan.');
                      },
                      child: const Text('Simpan sekarang'),
                    ),
                  ),
                  const SizedBox(height: Space.md),
                  Text(
                    'Refleksi hanya disimpan di perangkat ini dan tidak pernah muncul di notifikasi.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
      ),
    );
  }
}
