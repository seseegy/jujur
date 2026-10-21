import 'package:flutter/material.dart';

import '../errors/app_failure.dart';

/// Shows a short message. Replaces any message currently visible.
void showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

void showMessageWith(ScaffoldMessengerState messenger, String message) => messenger
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

/// Shows a message with an "Urungkan" action.
void showUndo(BuildContext context, String message, Future<void> Function() onUndo) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  if (messenger == null) return;
  showUndoWith(messenger, message, onUndo);
}

/// Like [showUndo], for callers that close their route first.
void showUndoWith(ScaffoldMessengerState messenger, String message, Future<void> Function() onUndo) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Urungkan',
          onPressed: () async {
            try {
              await onUndo();
            } on Object catch (e) {
              logError('undo', e);
              messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
            }
          },
        ),
      ),
    );
}

void showError(BuildContext context, Object error) => showMessage(context, describeError(error));

/// Runs [action] and reports failures to the user. Returns true on success.
Future<bool> runGuarded(BuildContext context, Future<void> Function() action, {String? success}) async {
  try {
    await action();
    if (success != null && context.mounted) showMessage(context, success);
    return true;
  } on Object catch (e) {
    logError('action', e);
    if (context.mounted) showError(context, e);
    return false;
  }
}

/// Confirmation dialog for destructive or significant operations.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  bool destructive = false,
}) async {
  final scheme = Theme.of(context).colorScheme;
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Batal')),
        FilledButton(
          style: destructive ? FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError) : null,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
