import 'package:basketly/core/theme/bk_colors.dart';
import 'package:basketly/core/theme/bk_text.dart';
import 'package:flutter/material.dart';

abstract final class BkTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BkColors.plum,
      primary: BkColors.plum,
      secondary: BkColors.saffron,
      surface: BkColors.surface,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: BkText.family,
      scaffoldBackgroundColor: BkColors.background,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: BkColors.ink,
      ),
    );
  }
}
