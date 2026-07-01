import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_input_decorations.dart';

class DominioUrlFormField extends StatefulWidget {
  final TextEditingController controller;
  final double? width;

  const DominioUrlFormField({
    super.key,
    required this.controller,
    this.width,
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
        );
      },
    );
  }
}

Widget dominioUrlFormField({
  required TextEditingController controller,
  double? width,
}) {
  return DominioUrlFormField(controller: controller, width: width);
}

Widget _dominioUrlField({
  required TextEditingController controller,
  required double? width,
  required bool isHovered,
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
        decoration: _dominioUrlFieldDecoration(isHovered),
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

InputDecoration _dominioUrlFieldDecoration(bool isHovered) {
  return covertixInputDecoration(
    hint: 'exemplo.com.br',
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
