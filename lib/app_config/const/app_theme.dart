import 'package:flutter/material.dart';

class AppTheme {
  static const double radiusPill = 10;
  static const double radiusCard = 16;
  static const double radiusInput = 12;
  static const double shadowBlur = 24;
  static const double shadowOpacity = 0.06;

  static const double inputBorderWidth = 1;
  static const double inputBorderWidthActive = 1.7;
  static const double buttonBorderWidthHover = 2;

  static const double fontSize = 13;
  static const EdgeInsets dialogHeaderPadding = EdgeInsets.symmetric(horizontal: 14, vertical: 8);
  static const BoxConstraints dialogCloseButtonConstraints = BoxConstraints(minWidth: 28, minHeight: 28);
  static const double dialogCloseIconSize = 18;

  static TextTheme get textTheme {
    const style = TextStyle(fontFamily: 'Segoe UI', fontSize: fontSize, color: Color(0xFF111827));

    return const TextTheme(
      displayLarge: style,
      displayMedium: style,
      displaySmall: style,
      headlineLarge: style,
      headlineMedium: style,
      headlineSmall: style,
      titleLarge: style,
      titleMedium: style,
      titleSmall: style,
      bodyLarge: style,
      bodyMedium: style,
      bodySmall: style,
      labelLarge: style,
      labelMedium: style,
      labelSmall: style,
    );
  }
}
