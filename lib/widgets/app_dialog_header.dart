import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/app_config/const/panel_header_style.dart';

Widget appDialogHeader({
  required String title,
  required IconData icon,
  String? subtitle,
  VoidCallback? onClose,
}) {
  return appContainer(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    backgroundColor: PanelHeaderStyle.background,
    radius: const BorderRadius.vertical(top: Radius.circular(AppTheme.radiusCard)),
    border: Border(bottom: BorderSide(color: PanelHeaderStyle.borderColor)),
    child: Row(
      children: [
        _dialogHeaderIcon(icon),
        appSizedBox(width: AppSpacing.small),
        Expanded(child: _dialogHeaderTitles(title.toUpperCase(), subtitle)),
        if (onClose != null) _dialogHeaderCloseButton(onClose),
      ],
    ),
  );
}

Widget _dialogHeaderIcon(IconData icon) {
  return appContainer(
    width: 32,
    height: 32,
    backgroundColor: AppColors.grey900,
    radius: BorderRadius.circular(6),
    border: Border.all(color: ConvertixColors.primary.withValues(alpha: 0.22)),
    child: Center(child: Icon(icon, color: AppColors.white, size: 18)),
  );
}

Widget _dialogHeaderTitles(String title, String? subtitle) {
  if (subtitle == null) {
    return _dialogHeaderTitleText(title);
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [_dialogHeaderTitleText(title), _dialogHeaderSubtitleText(subtitle)],
  );
}

Widget _dialogHeaderTitleText(String title) {
  return appText(
    title,
    color: PanelHeaderStyle.titleColor,
    bold: true,
    fontSize: AppFontSizes.verySmall,
  );
}

Widget _dialogHeaderSubtitleText(String subtitle) {
  return appText(subtitle, color: ConvertixColors.white, fontSize: AppFontSizes.verySmall);
}

Widget _dialogHeaderCloseButton(VoidCallback onClose) {
  return IconButton(
    onPressed: onClose,
    icon: Icon(Icons.close, color: Colors.white, size: AppTheme.dialogCloseIconSize),
    padding: EdgeInsets.zero,
    constraints: AppTheme.dialogCloseButtonConstraints,
    visualDensity: VisualDensity.compact,
  );
}
