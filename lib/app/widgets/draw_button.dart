import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// The one control that matters. Sized for a thumb on a phone being held up
/// in front of a room, not for a mouse.
class DrawButton extends StatefulWidget {
  const DrawButton({
    super.key,
    required this.onPressed,
    required this.enabled,
    required this.label,
    required this.sublabel,
  });

  final VoidCallback onPressed;
  final bool enabled;
  final String label;
  final String sublabel;

  @override
  State<DrawButton> createState() => _DrawButtonState();
}

class _DrawButtonState extends State<DrawButton> {
  bool _held = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = widget.enabled;

    return Semantics(
      button: true,
      enabled: enabled,
      label: '${widget.label}. ${widget.sublabel}',
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _held = true) : null,
        onTapUp: enabled ? (_) => setState(() => _held = false) : null,
        onTapCancel: enabled ? () => setState(() => _held = false) : null,
        onTap: enabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _held ? 0.96 : 1,
          duration: const Duration(milliseconds: 90),
          child: AnimatedContainer(
            duration: Motion.cell,
            // A minimum, not a fixed height. A narrow button on a small
            // sideways screen used to overflow the moment the label grew, and
            // a control that breaks on the last number of the game is the
            // worst possible moment for it.
            constraints: const BoxConstraints(minHeight: _height),
            decoration: BoxDecoration(
              color: enabled ? palette.accent : palette.surfaceHigh,
              borderRadius: BorderRadius.circular(Radii.button),
              boxShadow: enabled && !_held
                  ? [
                      BoxShadow(
                        color: palette.glow,
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ]
                  : null,
            ),
            alignment: Alignment.center,
            // Both labels stay on one line and scale down to fit rather than
            // wrapping. Wrapping is what pushed the column past the button.
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Space.md,
                vertical: Space.sm,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.label,
                      maxLines: 1,
                      style: TextStyle(
                        color: enabled ? palette.accentInk : palette.muted,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.sublabel,
                      maxLines: 1,
                      style: TextStyle(
                        color: (enabled ? palette.accentInk : palette.muted)
                            .withValues(alpha: 0.75),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static const _height = 76.0;
}

/// The quieter control beside it.
class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final enabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: palette.surfaceHigh,
        borderRadius: BorderRadius.circular(Radii.button),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(Radii.button),
          child: SizedBox(
            width: 72,
            height: 76,
            child: Icon(
              icon,
              size: 26,
              color: enabled
                  ? palette.text
                  : palette.muted.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
