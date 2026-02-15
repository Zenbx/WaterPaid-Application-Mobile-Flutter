import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color primary;
  final Color accent;
  final Color surface;
  final Color background;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color danger;
  final Color border;

  AppColors({
    required this.primary,
    required this.accent,
    required this.surface,
    required this.background,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.danger,
    required this.border,
  });

  @override
  AppColors copyWith({
    Color? primary,
    Color? accent,
    Color? surface,
    Color? background,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? danger,
    Color? border,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      accent: accent ?? this.accent,
      surface: surface ?? this.surface,
      background: background ?? this.background,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      border: border ?? this.border,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      background: Color.lerp(background, other.background, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }

  static final light = AppColors(
    primary: const Color(0xFF0F172A),
    accent: const Color(0xFF2563EB),
    surface: Colors.white,
    background: const Color(0xFFF8FAFC),
    textPrimary: const Color(0xFF0F172A),
    textSecondary: const Color(0xFF64748B),
    success: const Color(0xFF10B981),
    danger: const Color(0xFFEF4444),
    border: const Color(0xFFE2E8F0),
  );

  static final dark = AppColors(
    primary: const Color(0xFFF8FAFC),
    accent: const Color(0xFF3B82F6),
    surface: const Color(0xFF0F172A),
    background: const Color(0xFF020617),
    textPrimary: const Color(0xFFF8FAFC),
    textSecondary: const Color(0xFF94A3B8),
    success: const Color(0xFF10B981),
    danger: const Color(0xFFEF4444),
    border: const Color(0xFF1E293B),
  );
}

class AppTheme {
  static ThemeData light() {
    final colors = AppColors.light;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        primary: colors.primary,
        surface: colors.surface,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ThemeData dark() {
    final colors = AppColors.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.accent,
        primary: colors.primary,
        surface: colors.surface,
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      extensions: [colors],
      scaffoldBackgroundColor: colors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
