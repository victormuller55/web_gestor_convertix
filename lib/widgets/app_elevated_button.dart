import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart' as local;

Widget appElevatedButtonCovertix({
  required String title,
  double? padding,
  double? height,
  double? width,
  double? radius,
  double? fontSize,
  Color? color,
  bool primary = true,
  bool invertedStyle = false,
  required void Function() onTap,
}) {
  var hover = false;
  final borderRadius = radius ?? AppTheme.radiusInput;
  final buttonHeight = height ?? 48;
  final label = title.toUpperCase();
  final textSize = fontSize ?? AppFontSizes.verySmall;

  return StatefulBuilder(
    builder: (context, setState) {
      final buttonWidth = width ?? MediaQuery.of(context).size.width;

      return MouseRegion(
        onEnter: (_) => setState(() => hover = true),
        onExit: (_) => setState(() => hover = false),
        child: Padding(
          padding: EdgeInsets.only(top: padding ?? 0),
          child: _elevatedButtonContent(
            hover: hover,
            primary: primary,
            invertedStyle: invertedStyle,
            label: label,
            onTap: onTap,
            buttonHeight: buttonHeight,
            buttonWidth: buttonWidth,
            borderRadius: borderRadius,
            textSize: textSize,
          ),
        ),
      );
    },
  );
}

Widget appElevatedButtonCovertixTransparent({
  required String title,
  double? width,
  double? height,
  double? radius,
  Color? color,
  required void Function() onTap,
}) {
  return appElevatedButtonCovertix(
    title: title,
    width: width,
    height: height,
    radius: radius,
    color: color,
    primary: false,
    onTap: onTap,
  );
}

Widget _elevatedButtonContent({
  required bool hover,
  required bool primary,
  required bool invertedStyle,
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  final outline = _elevatedOutlineButton(
    label: label,
    onTap: onTap,
    buttonHeight: buttonHeight,
    buttonWidth: buttonWidth,
    borderRadius: borderRadius,
    textSize: textSize,
  );
  final filled = primary
      ? _elevatedPrimaryButton(
          label: label,
          onTap: onTap,
          buttonHeight: buttonHeight,
          buttonWidth: buttonWidth,
          borderRadius: borderRadius,
          textSize: textSize,
        )
      : _elevatedSecondaryButton(
          label: label,
          onTap: onTap,
          buttonHeight: buttonHeight,
          buttonWidth: buttonWidth,
          borderRadius: borderRadius,
          textSize: textSize,
        );

  if (invertedStyle) return hover ? filled : outline;
  return hover ? outline : filled;
}

Widget _elevatedOutlineButton({
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  return Material(
    color: AppColors.white,
    borderRadius: BorderRadius.circular(borderRadius),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: buttonHeight,
        width: buttonWidth,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: local.ConvertixColors.buttonPrimary,
            width: AppTheme.buttonBorderWidthHover,
          ),
        ),
        child: appText(
          label,
          color: local.ConvertixColors.buttonPrimary,
          bold: true,
          fontSize: textSize,
          letterSpacing: 1,
        ),
      ),
    ),
  );
}

Widget _elevatedPrimaryButton({
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  return appElevatedButtonText(
    label,
    function: onTap,
    fontSize: textSize,
    height: buttonHeight,
    width: buttonWidth,
    color: local.ConvertixColors.buttonPrimary,
    textColor: AppColors.white,
    borderColor: local.ConvertixColors.buttonPrimary,
    borderRadius: borderRadius,
    borderWidth: 0,
  );
}

Widget _elevatedSecondaryButton({
  required String label,
  required void Function() onTap,
  required double buttonHeight,
  required double buttonWidth,
  required double borderRadius,
  required double textSize,
}) {
  return appElevatedButtonText(
    label,
    function: onTap,
    fontSize: textSize,
    height: buttonHeight,
    width: buttonWidth,
    color: AppColors.white,
    textColor: local.ConvertixColors.textPrimary,
    borderColor: local.ConvertixColors.border,
    borderRadius: borderRadius,
  );
}
