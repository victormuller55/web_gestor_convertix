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
          child: _animatedElevatedButton(
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

Widget _animatedElevatedButton({
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
  final isOutline = invertedStyle ? hover : !hover;
  final colors = _resolveElevatedButtonColors(primary: primary, isOutline: isOutline);

  return AnimatedContainer(
    duration: AppTheme.buttonHoverDuration,
    curve: Curves.easeInOut,
    height: buttonHeight,
    width: buttonWidth,
    decoration: BoxDecoration(
      color: colors.backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: colors.borderColor,
        width: colors.borderWidth,
      ),
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppTheme.buttonHoverDuration,
            curve: Curves.easeInOut,
            style: TextStyle(
              color: colors.textColor,
              fontWeight: FontWeight.bold,
              fontSize: textSize,
              letterSpacing: 1,
              fontFamily: 'lato',
            ),
            child: Text(label),
          ),
        ),
      ),
    ),
  );
}

({Color backgroundColor, Color textColor, Color borderColor, double borderWidth})
    _resolveElevatedButtonColors({
  required bool primary,
  required bool isOutline,
}) {
  if (primary) {
    if (isOutline) {
      return (
        backgroundColor: AppColors.white,
        textColor: local.ConvertixColors.buttonPrimary,
        borderColor: local.ConvertixColors.buttonPrimary,
        borderWidth: AppTheme.buttonBorderWidthHover,
      );
    }

    return (
      backgroundColor: local.ConvertixColors.buttonPrimary,
      textColor: AppColors.white,
      borderColor: local.ConvertixColors.buttonPrimary,
      borderWidth: 0,
    );
  }

  if (isOutline) {
    return (
      backgroundColor: AppColors.white,
      textColor: local.ConvertixColors.buttonPrimary,
      borderColor: local.ConvertixColors.buttonPrimary,
      borderWidth: AppTheme.buttonBorderWidthHover,
    );
  }

  return (
    backgroundColor: AppColors.white,
    textColor: local.ConvertixColors.textPrimary,
    borderColor: local.ConvertixColors.border,
    borderWidth: AppTheme.inputBorderWidth,
  );
}
