import 'package:flutter/material.dart';

import 'tokens.dart';

/// Builds the two themes from one [Palette] each, so a colour is only ever
/// decided in tokens.dart.
abstract final class AppTheme {
  static ThemeData dark() => _build(Palette.dark, Brightness.dark);

  static ThemeData light() => _build(Palette.light, Brightness.light);

  static ThemeData _build(Palette palette, Brightness brightness) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: palette.accent,
          brightness: brightness,
        ).copyWith(
          surface: palette.background,
          onSurface: palette.text,
          primary: palette.accent,
          onPrimary: palette.accentInk,
          outline: palette.border,
        );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    // Built once and handed to every component theme below. Re-declaring a
    // size or weight inline would put the type scale in two places, and a
    // component theme that spells out its own TextStyle also stops inheriting
    // the font family.
    final text = _textTheme(base.textTheme, palette);

    return base.copyWith(
      scaffoldBackgroundColor: palette.background,
      extensions: [palette],
      splashFactory: InkSparkle.splashFactory,
      textTheme: text,
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: palette.muted),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: palette.calledFill,
        elevation: 0,
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? palette.accent
                : palette.muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            color: states.contains(WidgetState.selected)
                ? palette.accent
                : palette.muted,
          ),
        ),
      ),
      // The landscape counterpart of the navigation bar above. Same colours,
      // so rotating the phone does not look like a different app.
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.calledFill,
        elevation: 0,
        selectedIconTheme: IconThemeData(color: palette.accent, size: 24),
        unselectedIconTheme: IconThemeData(color: palette.muted, size: 24),
        selectedLabelTextStyle: text.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: palette.accent,
        ),
        unselectedLabelTextStyle: text.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: palette.muted,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: palette.border,
        thickness: 1,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
        titleTextStyle: text.titleLarge?.copyWith(fontSize: 19),
        contentTextStyle: text.bodyMedium?.copyWith(color: palette.muted),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accentInk
              : palette.muted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accent
              : palette.surfaceHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.accent
              : palette.border,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.accent,
        inactiveTrackColor: palette.surfaceHigh,
        thumbColor: palette.accent,
        overlayColor: palette.glow,
        trackHeight: 4,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.surfaceHigh,
        contentTextStyle: text.bodySmall?.copyWith(
          color: palette.text,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.card),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: palette.muted,
        textColor: palette.text,
        titleTextStyle: text.titleMedium?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall?.copyWith(color: palette.muted),
      ),
    );
  }

  /// Tight, heavy type. The number sizes carry the whole screen, so they are
  /// set here rather than inline.
  static TextTheme _textTheme(TextTheme base, Palette palette) {
    return base
        .copyWith(
          displayLarge: const TextStyle(
            fontSize: 132,
            fontWeight: FontWeight.w800,
            letterSpacing: -6,
            height: 1,
          ),
          displayMedium: const TextStyle(
            fontSize: 92,
            fontWeight: FontWeight.w800,
            letterSpacing: -4,
            height: 1,
          ),
          titleLarge: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          titleMedium: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: const TextStyle(fontSize: 15, height: 1.45),
          bodySmall: const TextStyle(fontSize: 13, height: 1.4),
          labelLarge: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          labelSmall: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        )
        .apply(bodyColor: palette.text, displayColor: palette.text);
  }
}
