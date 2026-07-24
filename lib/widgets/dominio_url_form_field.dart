import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_input_decorations.dart';

class DominioUrlFormField extends StatefulWidget {
  final TextEditingController controller;
  final double? width;
  final String? Function(String?)? validator;
  final String hint;

  const DominioUrlFormField({
    super.key,
    required this.controller,
    this.width,
    this.validator,
    this.hint = 'exemplo.com.br',
  });

  @override
  State<DominioUrlFormField> createState() => _DominioUrlFormFieldState();
}

class _DominioUrlFormFieldState extends State<DominioUrlFormField> {
  @override
  Widget build(BuildContext context) {
    return CovertixHoverInput(
      builder: (context, isHovered) {
        return _dominioUrlField(
          controller: widget.controller,
          width: widget.width,
          isHovered: isHovered,
          validator: widget.validator,
          hint: widget.hint,
        );
      },
    );
  }
}

Widget dominioUrlFormField({
  required TextEditingController controller,
  double? width,
  String? Function(String?)? validator,
  String hint = 'exemplo.com.br',
}) {
  return DominioUrlFormField(
    controller: controller,
    width: width,
    validator: validator,
    hint: hint,
  );
}

Widget _dominioUrlField({
  required TextEditingController controller,
  required double? width,
  required bool isHovered,
  String? Function(String?)? validator,
  required String hint,
}) {
  return Padding(
    padding: const EdgeInsets.only(top: 10),
    child: SizedBox(
      width: width,
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.url,
        autocorrect: false,
        enableSuggestions: false,
        style: _dominioUrlFieldStyle(),
        decoration: _dominioUrlFieldDecoration(isHovered, hint),
        validator: validator,
      ),
    ),
  );
}

TextStyle _dominioUrlFieldStyle() {
  return TextStyle(
    fontFamily: 'lato',
    fontSize: AppFontSizes.verySmall,
    letterSpacing: 1,
  );
}

InputDecoration _dominioUrlFieldDecoration(bool isHovered, String hint) {
  return covertixInputDecoration(
    hint: hint,
    borderColor: ConvertixColors.border,
    isHovered: isHovered,
    contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
    prefixIcon: const Icon(Icons.public_outlined, color: ConvertixColors.primary),
    prefixText: httpsPrefix,
    prefixStyle: TextStyle(
      fontFamily: 'lato',
      fontSize: AppFontSizes.verySmall,
      letterSpacing: 1,
      color: ConvertixColors.textSecondary,
    ),
  );
}
