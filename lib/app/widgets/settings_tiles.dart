import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// A titled group of settings rows on one card.
class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.xs, 0, 0, Space.sm),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(color: palette.muted),
          ),
        ),
        // Material rather than a decorated box: a ListTile paints its ripple
        // on the nearest Material, so a coloured box above it would swallow
        // every tap highlight on this card.
        Material(
          color: palette.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.card),
            side: BorderSide(color: palette.border),
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: palette.border, indent: Space.lg),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// A row with a switch on the right.
class SwitchRow extends StatelessWidget {
  const SwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.xs,
      ),
      secondary: icon == null ? null : Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// A row of mutually exclusive options, laid out as a segmented control.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final String title;
  final String subtitle;

  /// Value to label, in the order they should appear.
  final Map<T, String> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Space.lg,
        Space.md,
        Space.lg,
        Space.lg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(color: palette.muted, fontSize: 13, height: 1.3),
          ),
          const SizedBox(height: Space.md),
          SegmentedButton<T>(
            segments: [
              for (final entry in options.entries)
                ButtonSegment(value: entry.key, label: Text(entry.value)),
            ],
            selected: {selected},
            showSelectedIcon: false,
            onSelectionChanged: (values) => onChanged(values.first),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? palette.accent
                    : palette.surfaceHigh,
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? palette.accentInk
                    : palette.muted,
              ),
              side: WidgetStatePropertyAll(BorderSide(color: palette.border)),
              textStyle: WidgetStatePropertyAll(
                Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 14),
              ),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(vertical: Space.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A tappable row that leads somewhere, with a chevron.
class LinkRow extends StatelessWidget {
  const LinkRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: Space.lg,
        vertical: Space.sm,
      ),
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
