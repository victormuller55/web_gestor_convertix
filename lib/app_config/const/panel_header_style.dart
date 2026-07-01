import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

abstract final class PanelHeaderStyle {
  static Color get background => AppColors.black.withValues(alpha: 0.9);
  static Color get borderColor => ConvertixColors.primary.withValues(alpha: 0.15);
  static Color get dividerColor => ConvertixColors.primary.withValues(alpha: 0.15);
  static Color get titleColor => ConvertixColors.white;
}
