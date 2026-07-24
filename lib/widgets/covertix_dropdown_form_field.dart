import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_input_decorations.dart';

class CovertixDropdownFormField<T> extends StatefulWidget {
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final bool withTopInset;

  const CovertixDropdownFormField({
    super.key,
    required this.value,
    required this.hint,
    required this.items,
    this.onChanged,
    this.validator,
    this.withTopInset = false,
  });

  @override
  State<CovertixDropdownFormField<T>> createState() =>
      _CovertixDropdownFormFieldState<T>();
}

class _CovertixDropdownFormFieldState<T> extends State<CovertixDropdownFormField<T>> {
  /// Mesma altura visual do AppFormField dense com ícone de busca.
  static const double _filterBarHeight = 48;

  @override
  Widget build(BuildContext context) {
    final field = _covertixDropdownField<T>(
      value: widget.value,
      hint: widget.hint,
      items: widget.items,
      onChanged: widget.onChanged,
      validator: widget.validator,
    );

    if (!widget.withTopInset) return field;

    return _covertixDropdownWithInset(field, _filterBarHeight);
  }
}

Widget covertixDropdownFormField<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  ValueChanged<T?>? onChanged,
  String? Function(T?)? validator,
  bool withTopInset = false,
}) {
  return CovertixDropdownFormField<T>(
    value: value,
    hint: hint,
    items: items,
    onChanged: onChanged,
    validator: validator,
    withTopInset: withTopInset,
  );
}

Widget _covertixDropdownWithInset(Widget field, double height) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(height: height, child: field),
  );
}

Widget _covertixDropdownField<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  ValueChanged<T?>? onChanged,
  String? Function(T?)? validator,
}) {
  return CovertixHoverInput(
    builder: (context, isHovered) {
      return DropdownButtonFormField<T>(
        key: ValueKey(value),
        initialValue: value,
        isExpanded: true,
        isDense: true,
        iconSize: 20,
        style: TextStyle(
          fontFamily: 'lato',
          fontSize: AppFontSizes.verySmall,
          color: ConvertixColors.textPrimary,
          letterSpacing: 1,
          height: 1.2,
        ),
        decoration: covertixDropdownDecoration(hint: hint, isHovered: isHovered),
        items: items,
        onChanged: onChanged,
        validator: validator,
      );
    },
  );
}

InputDecoration covertixDropdownDecoration({
  required String hint,
  bool isHovered = false,
}) {
  return covertixInputDecoration(
    hint: hint,
    borderColor: ConvertixColors.border,
    isHovered: isHovered,
    fillColor: ConvertixColors.inputFill,
    isDense: true,
    // Preenche a altura 48 do slot da barra de filtros (igual ao AppFormField com ícone).
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}

/// Slot padrão da barra de filtros: mesma altura do campo de busca e do botão.
Widget covertixFilterBarItem({
  required double width,
  required Widget child,
  double height = 48,
  double topInset = 10,
}) {
  return Padding(
    padding: EdgeInsets.only(top: topInset),
    child: SizedBox(width: width, height: height, child: child),
  );
}
