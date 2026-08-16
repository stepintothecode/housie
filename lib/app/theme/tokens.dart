import 'package:flutter/material.dart';

/// Every colour the app paints, named for what it means rather than what it
/// looks like, so the light and dark palettes stay in step.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.background,
    required this.surface,
    required this.surfaceHigh,
    required this.border,
    required this.text,
    required this.muted,
    required this.accent,
    required this.accentInk,
    required this.calledFill,
    required this.calledInk,
    required this.glow,
  });

  /// Behind everything.
  final Color background;

  /// Cards and the bottom bar.
  final Color surface;

  /// A board cell nobody has called yet.
  final Color surfaceHigh;

  final Color border;
  final Color text;

  /// Secondary labels and counts.
  final Color muted;

  /// The live number and the draw button.
  final Color accent;

  /// Sits on top of [accent].
  final Color accentInk;

  /// A board cell that has been called.
  final Color calledFill;
  final Color calledInk;

  /// Cast under the live number. Deliberately subtle in light mode, where a
  /// glow reads as a smudge.
  final Color glow;

  static const dark = Palette(
    background: Color(0xFF0E1117),
    surface: Color(0xFF161B22),
    surfaceHigh: Color(0xFF1F262F),
    border: Color(0xFF2A323D),
    text: Color(0xFFE6EDF3),
    muted: Color(0xFF8B949E),
    accent: Color(0xFFFFB347),
    accentInk: Color(0xFF1A1206),
    calledFill: Color(0xFF3A2E1B),
    calledInk: Color(0xFFFFCE8A),
    glow: Color(0x33FFB347),
  );

  static const light = Palette(
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFF6F8FA),
    surfaceHigh: Color(0xFFECF0F4),
    border: Color(0xFFD6DCE4),
    text: Color(0xFF1F2328),
    muted: Color(0xFF5B6672),
    accent: Color(0xFFB45309),
    accentInk: Color(0xFFFFFFFF),
    calledFill: Color(0xFFFDECD2),
    calledInk: Color(0xFF8A3D06),
    glow: Color(0x14B45309),
  );

  @override
  Palette copyWith({
    Color? background,
    Color? surface,
    Color? surfaceHigh,
    Color? border,
    Color? text,
    Color? muted,
    Color? accent,
    Color? accentInk,
    Color? calledFill,
    Color? calledInk,
    Color? glow,
  }) {
    return Palette(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceHigh: surfaceHigh ?? this.surfaceHigh,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      accent: accent ?? this.accent,
      accentInk: accentInk ?? this.accentInk,
      calledFill: calledFill ?? this.calledFill,
      calledInk: calledInk ?? this.calledInk,
      glow: glow ?? this.glow,
    );
  }

  @override
  Palette lerp(covariant Palette? other, double t) {
    if (other == null) return this;
    return Palette(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceHigh: Color.lerp(surfaceHigh, other.surfaceHigh, t)!,
      border: Color.lerp(border, other.border, t)!,
      text: Color.lerp(text, other.text, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentInk: Color.lerp(accentInk, other.accentInk, t)!,
      calledFill: Color.lerp(calledFill, other.calledFill, t)!,
      calledInk: Color.lerp(calledInk, other.calledInk, t)!,
      glow: Color.lerp(glow, other.glow, t)!,
    );
  }
}

/// Reads the palette without the ceremony of the extension lookup.
extension PaletteOf on BuildContext {
  Palette get palette => Theme.of(this).extension<Palette>()!;
}

/// One spacing scale, so nothing is nudged by an arbitrary number of pixels.
abstract final class Space {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;
}

abstract final class Radii {
  static const cell = 8.0;
  static const card = 16.0;
  static const button = 20.0;
  static const pill = 999.0;
}

/// How long the drawn number takes to land.
abstract final class Motion {
  static const draw = Duration(milliseconds: 340);
  static const cell = Duration(milliseconds: 260);
  static const theme = Duration(milliseconds: 200);
}
