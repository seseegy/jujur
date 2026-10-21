import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_spacing.dart';
import '../errors/app_failure.dart';

/// Explains an empty situation and offers the relevant next action.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Space.page,
        vertical: compact ? Space.md : Space.xxxl,
      ),
      // Full width so the centered layout is centered on the screen, not
      // within the width of its longest line.
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: compact
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!compact) ...[
              ExcludeSemantics(
                child: Icon(
                  icon,
                  size: 32,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Space.md),
            ],
            Text(
              title,
              style: theme.textTheme.titleSmall,
              textAlign: compact ? TextAlign.start : TextAlign.center,
            ),
            const SizedBox(height: Space.xs),
            Text(
              message,
              style: theme.textTheme.bodySmall,
              textAlign: compact ? TextAlign.start : TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: Space.md),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(Space.page),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: theme.colorScheme.error),
            const SizedBox(height: Space.sm),
            Text(
              describeError(error),
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: Space.md),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Coba lagi'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.label = 'Memuat…'});
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(Space.xxl),
    child: Center(
      child: Semantics(
        label: label,
        child: const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    ),
  );
}

/// Renders loading, error and data states of an [AsyncValue] consistently.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => switch (value) {
    AsyncData(:final value) => data(value),
    AsyncError(:final error) => ErrorView(error: error, onRetry: onRetry),
    _ => const LoadingView(),
  };
}
