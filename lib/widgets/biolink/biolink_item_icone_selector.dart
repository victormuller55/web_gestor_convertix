import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_icone.dart';
import 'package:web_gestor_site_covertix/widgets/biolink/biolink_item_icone_widget.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';

class BiolinkItemIconeSelector extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const BiolinkItemIconeSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        appText(
          'Ícone / plataforma',
          color: ConvertixColors.textSecondary,
          fontSize: AppFontSizes.verySmall,
        ),
        appSizedBox(height: AppSpacing.small),
        CovertixDropdownFormField<String?>(
          value: value,
          hint: 'Sem ícone',
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('Sem ícone'),
            ),
            ...BioLinkItemIcone.valores.map((icone) {
              return DropdownMenuItem<String?>(
                value: icone,
                child: Row(
                  children: [
                    BiolinkItemIconeWidget(icone: icone, size: 22),
                    appSizedBox(width: AppSpacing.small),
                    Expanded(
                      child: Text(
                        BioLinkItemIcone.label(icone),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
