import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/app_config/auth_gate.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Convertix - Gestor Web',
      navigatorKey: AppContext.navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: ConvertixColors.primary,
          primary: ConvertixColors.primary,
          onPrimary: ConvertixColors.white,
          surface: ConvertixColors.surface,
          onSurface: ConvertixColors.textPrimary,
        ),
        scaffoldBackgroundColor: ConvertixColors.background,
        fontFamily: 'Segoe UI',
        textTheme: AppTheme.textTheme,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ConvertixColors.surface,
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
      ),
      home: const AuthGate(),
    );
  }
}
