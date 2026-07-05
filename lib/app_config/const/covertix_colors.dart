import 'package:flutter/material.dart';

class ConvertixColors {

  static const Color white = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF002AFF);
  static const Color primaryDark = Color(0xFF001DB8);
  static const Color primaryDarker = Color(0xFF000E4B);
  static const Color buttonPrimary = primary;
  static const Color sidebarBackground = Color(0xFF000E4B);
  static const Color primaryLight = Color(0xFFE6EAFF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);

  static const Color background = Color(0xFFF9FAFB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E7EB);

  static const Color error = Color(0xFFDC2626);
  static const Color errorBackground = Color(0xFFFEE2E2);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient loginPanelGradient = LinearGradient(
    begin: Alignment(-0.8, -1),
    end: Alignment(1.2, 1),
    colors: [
      Color(0xFF000510),
      primaryDarker,
      primaryDark,
      primary,
    ],
    stops: [0, 0.35, 0.65, 1],
  );

  static const LinearGradient brandPanelGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      surface,
      Color(0xFFF0F4FF),
      Color(0xFFE6EAFF),
    ],
    stops: [0, 0.55, 1],
  );

  static const LinearGradient primaryGradientHover = LinearGradient(
    colors: [primaryDark, primaryDark],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Compatibilidade com telas que usam secondary/tertiary
  static const Color secondary = textSecondary;
  static const Color tertiary = primary;
  static const Color backgroundSecondary = background;
}
