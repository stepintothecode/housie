import 'package:flutter/material.dart';

/// Wraps something that does not look like a button and counts taps on it.
///
/// Deliberately gives nothing away: no ripple, no cursor, no semantics. The
/// only way to find it is to be told, or to fidget.
class SecretTap extends StatefulWidget {
  const SecretTap({
    super.key,
    required this.child,
    required this.onUnlocked,
    this.taps = 7,
    this.window = const Duration(seconds: 3),
  });

  final Widget child;
  final VoidCallback onUnlocked;

  /// How many taps in a row it takes.
  final int taps;

  /// How long a gap is allowed between taps before the count starts over, so
  /// idle taps spread over an afternoon never add up to anything.
  final Duration window;

  @override
  State<SecretTap> createState() => _SecretTapState();
}

class _SecretTapState extends State<SecretTap> {
  int _count = 0;
  DateTime? _last;

  void _tap() {
    final now = DateTime.now();
    final last = _last;
    // Compared against the clock rather than run off a timer, so nothing is
    // left pending when this widget goes away.
    _count = (last == null || now.difference(last) > widget.window)
        ? 1
        : _count + 1;
    _last = now;

    if (_count >= widget.taps) {
      _count = 0;
      _last = null;
      widget.onUnlocked();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      // Left out of the accessibility tree on purpose. A GestureDetector
      // otherwise advertises a tap action, so a screen reader would announce
      // the app icon as something to press and give the whole thing away.
      excludeFromSemantics: true,
      onTap: _tap,
      child: widget.child,
    );
  }
}
