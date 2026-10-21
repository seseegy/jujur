import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'status_mark.dart';

/// A tappable row for a tracked item (prayer, habit, worship item).
///
/// Status is shown with an icon shape and a text label, never color alone.
class TrackRow extends StatelessWidget {
  const TrackRow({
    super.key,
    required this.mark,
    required this.title,
    required this.statusLabel,
    required this.onTap,
    this.subtitle,
    this.trailing,
    this.semanticHint,
  });

  final Mark mark;
  final String title;
  final String statusLabel;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final String? semanticHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = mark == Mark.unrecorded;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: '$title, $statusLabel${subtitle == null ? '' : ', $subtitle'}',
            hint: semanticHint ?? 'Ketuk untuk mencatat atau mengubah',
            excludeSemantics: true,
            child: InkWell(
              onTap: onTap,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(Space.page, Space.sm, Space.sm, Space.sm),
                  child: Row(
                    children: [
                      StatusMark(mark),
                      const SizedBox(width: Space.md),
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(title, style: theme.textTheme.bodyLarge),
                            if (subtitle != null)
                              Text(subtitle!, style: theme.textTheme.bodySmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      const SizedBox(width: Space.sm),
                      Flexible(
                        flex: 2,
                        child: Text(
                          statusLabel,
                          textAlign: TextAlign.end,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: muted ? theme.colorScheme.onSurfaceVariant : mark.color(context),
                            fontWeight: muted ? FontWeight.w400 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: minTouchTarget + Space.sm, child: trailing),
      ],
    );
  }
}

/// Quick toggle used at the end of a [TrackRow].
class QuickCheckButton extends StatelessWidget {
  const QuickCheckButton({super.key, required this.checked, required this.label, required this.onPressed});

  final bool checked;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return IconButton(
      tooltip: label,
      onPressed: onPressed,
      icon: Icon(
        checked ? Icons.check_box : Icons.check_box_outline_blank,
        color: checked ? scheme.primary : scheme.onSurfaceVariant,
      ),
    );
  }
}
