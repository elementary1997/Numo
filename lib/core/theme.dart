import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Фирменные цвета Numo.
abstract final class NumoColors {
  static const violet = Color(0xFF7C5CFF);
  static const violetDeep = Color(0xFF4A2FE0);
  static const mint = Color(0xFF3DDC97);
  static const coral = Color(0xFFFF6B6B);
  static const amber = Color(0xFFFFB84C);
  static const sky = Color(0xFF4CC9F0);
  static const pink = Color(0xFFF072B6);
  // Нейтральные тона в духе macOS: серые без цветового подмеса.
  static const inkDark = Color(0xFF1A1A1C);
  static const surfaceDark = Color(0xFF242426);
  static const surfaceDark2 = Color(0xFF2E2E31);
  static const inkLight = Color(0xFFF2F2F4);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C5CFF), Color(0xFF4A2FE0), Color(0xFF2A1B8F)],
  );

  /// Палитра акцентов для персонализации.
  static const accentChoices = [
    violet,
    Color(0xFF2F6FED), // синий
    Color(0xFF0FA47A), // изумруд
    Color(0xFFE0564B), // коралл
    Color(0xFFE08A00), // янтарь
    Color(0xFFD84E8E), // розовый
    Color(0xFF12A5B8), // бирюза
    Color(0xFF6E56CF), // индиго
    Color(0xFF5B7C0A), // олива
    Color(0xFF3E4A5C), // графит
  ];
}

/// Затемнение цвета для градиентов.
Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}

/// Фирменный градиент героя-карточки от акцентного цвета.
LinearGradient numoHeroGradient(Color accent) => LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [accent, _darken(accent, 0.14), _darken(accent, 0.26)],
    );

abstract final class NumoTheme {
  static ThemeData dark([Color accent = NumoColors.violet]) => _build(
        accent: accent,
        brightness: Brightness.dark,
        background: NumoColors.inkDark,
        surface: NumoColors.surfaceDark,
        surfaceVariant: NumoColors.surfaceDark2,
        onSurface: const Color(0xFFF2F2F3),
        muted: const Color(0xFF98989E),
      );

  static ThemeData light([Color accent = NumoColors.violet]) => _build(
        accent: accent,
        brightness: Brightness.light,
        background: NumoColors.inkLight,
        surface: NumoColors.surfaceLight,
        surfaceVariant: const Color(0xFFE9E9EC),
        onSurface: const Color(0xFF1C1C1E),
        muted: const Color(0xFF6E6E76),
      );

  static ThemeData _build({
    required Color accent,
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color onSurface,
    required Color muted,
  }) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: accent,
      onPrimary: Colors.white,
      secondary: NumoColors.mint,
      onSecondary: const Color(0xFF06281A),
      error: NumoColors.coral,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: muted,
      outline: muted.withValues(alpha: 0.4),
    );

    // Inter — ближайший к системному SF шрифт с кириллицей.
    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: brightness).textTheme,
    ).apply(bodyColor: onSurface, displayColor: onSurface);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          fontSize: 20,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: onSurface.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: DividerThemeData(
        color: onSurface.withValues(alpha: 0.08),
        thickness: 0.5,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: accent.withValues(alpha: 0.16),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: states.contains(WidgetState.selected) ? accent : muted,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: Colors.white,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
