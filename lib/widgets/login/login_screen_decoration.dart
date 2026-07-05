import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

const String loginBackgroundAsset = 'assets/images/background.png';

class LoginScreenBackground extends StatelessWidget {
  final Widget child;

  const LoginScreenBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(loginBackgroundAsset),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.medium),
          child: child,
        ),
      ),
    );
  }
}

class LoginGlassCard extends StatelessWidget {
  final Widget child;

  const LoginGlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppTheme.radiusCard + 4);

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 440),
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.giant,
            vertical: AppSpacing.giant,
          ),
          decoration: BoxDecoration(
            color: ConvertixColors.white.withValues(alpha: 0.9),
            borderRadius: radius,
            border: Border.all(
              color: ConvertixColors.white.withValues(alpha: 0.8),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.grey900.withValues(alpha: 0.16),
                blurRadius: 48,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
