import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';

OutlineInputBorder covertixInputBorder(Color color, {double width = 1}) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
    borderSide: BorderSide(color: color, width: width),
  );
}

InputDecoration covertixInputDecoration({
  required String hint,
  required Color borderColor,
  bool isHovered = false,
  bool isDense = true,
  Color? fillColor,
  Widget? prefixIcon,
  String? prefixText,
  TextStyle? prefixStyle,
  EdgeInsetsGeometry? contentPadding,
}) {
  final border = _covertixInputBorderState(borderColor: borderColor, isHovered: isHovered);

  return InputDecoration(
    hintText: hint,
    isDense: isDense,
    filled: true,
    prefixIcon: prefixIcon,
    prefixText: prefixText,
    prefixStyle: prefixStyle,
    border: border,
    enabledBorder: border,
    disabledBorder: border,
    focusedBorder: _covertixInputBorderState(borderColor: ConvertixColors.primary, isHovered: true),
    fillColor: fillColor ?? Colors.grey.shade100,
    contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    hintStyle: _covertixInputHintStyle(),
  );
}

OutlineInputBorder _covertixInputBorderState({
  required Color borderColor,
  required bool isHovered,
}) {
  final effectiveColor = isHovered ? ConvertixColors.primary : borderColor;
  final width = isHovered ? AppTheme.inputBorderWidthActive : AppTheme.inputBorderWidth;

  return covertixInputBorder(effectiveColor, width: width);
}

TextStyle _covertixInputHintStyle() {
  return TextStyle(
    fontFamily: 'lato',
    fontSize: AppFontSizes.verySmall,
    color: Colors.grey,
    letterSpacing: 1,
  );
}

class CovertixHoverInput extends StatefulWidget {
  final Widget Function(BuildContext context, bool isHovered) builder;

  const CovertixHoverInput({super.key, required this.builder});

  @override
  State<CovertixHoverInput> createState() => _CovertixHoverInputState();
}

class _CovertixHoverInputState extends State<CovertixHoverInput> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return _hoverInputRegion(
      onEnter: () => setState(() => _hover = true),
      onExit: () => setState(() => _hover = false),
      child: widget.builder(context, _hover),
    );
  }
}

Widget _hoverInputRegion({
  required VoidCallback onEnter,
  required VoidCallback onExit,
  required Widget child,
}) {
  return MouseRegion(
    onEnter: (_) => onEnter(),
    onExit: (_) => onExit(),
    child: child,
  );
}
