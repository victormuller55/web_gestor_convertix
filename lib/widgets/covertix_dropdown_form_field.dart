import 'package:flutter/material.dart';
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
  static const double _filterBarHeight = 40;

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
    fillColor: Colors.grey.shade100,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
  );
}
