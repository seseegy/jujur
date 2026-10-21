import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// A labeled section with an optional trailing action and optional
/// collapse behavior. Sections are separated by whitespace and a label,
/// not by cards.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.summary,
    this.trailing,
    this.collapsed,
    this.onToggle,
  });

  final String title;

  /// Short status text next to the title, e.g. "3 dari 5 dicatat".
  final String? summary;
  final Widget? trailing;

  /// Non-null when the section can be collapsed.
  final bool? collapsed;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collapsible = collapsed != null && onToggle != null;
    final label = Row(
      children: [
        Flexible(
          child: Text(
            title.toUpperCase(),
            style: theme.textTheme.labelMedium,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (summary != null) ...[
          const SizedBox(width: Space.sm),
          Flexible(
            child: Text(
              summary!,
              style: theme.textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
        if (collapsible) ...[
          const SizedBox(width: Space.xs),
          Icon(
            collapsed! ? Icons.expand_more : Icons.expand_less,
            size: 20,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.page, Space.xxl, Space.sm, Space.xs),
      child: Row(
        children: [
          Expanded(
            child: collapsible
                ? Semantics(
                    button: true,
                    expanded: !collapsed!,
                    label: '$title, ${collapsed! ? 'diciutkan' : 'dibuka'}',
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: Radii.smallAll,
                      onTap: onToggle,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: minTouchTarget),
                        child: Align(alignment: Alignment.centerLeft, child: label),
                      ),
                    ),
                  )
                : ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: minTouchTarget),
                    child: Align(alignment: Alignment.centerLeft, child: Semantics(header: true, child: label)),
                  ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A full-width hairline between list rows, indented to the content.
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.indent = Space.page});
  final double indent;

  @override
  Widget build(BuildContext context) => Divider(indent: indent, endIndent: 0);
}
