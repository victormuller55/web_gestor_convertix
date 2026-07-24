import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/auth_gate.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  ThemeData get _themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: ConvertixColors.primary,
        brightness: Brightness.light,
        primary: ConvertixColors.primary,
        onPrimary: ConvertixColors.white,
        surface: ConvertixColors.surface,
        onSurface: ConvertixColors.textPrimary,
      ),
      scaffoldBackgroundColor: ConvertixColors.background,
      canvasColor: ConvertixColors.surface,
      cardColor: ConvertixColors.surface,
      dividerColor: ConvertixColors.border,
      dialogTheme: const DialogThemeData(backgroundColor: ConvertixColors.surface),
      popupMenuTheme: const PopupMenuThemeData(
        color: ConvertixColors.surface,
        textStyle: TextStyle(color: ConvertixColors.textPrimary),
      ),
      fontFamily: 'Segoe UI',
      textTheme: AppTheme.textTheme.apply(
        bodyColor: ConvertixColors.textPrimary,
        displayColor: ConvertixColors.textPrimary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ConvertixColors.inputFill,
        hintStyle: const TextStyle(color: ConvertixColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: ConvertixColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: ConvertixColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          borderSide: const BorderSide(color: ConvertixColors.primary, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ConvertixColors.buttonPrimary,
          foregroundColor: ConvertixColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusInput),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertix - Gestor Web',
      navigatorKey: AppContext.navigatorKey,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.light,
      theme: _themeData,
      home: const AuthGate(),
    );
  }
}
