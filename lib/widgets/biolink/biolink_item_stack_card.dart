import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_model.dart';
import 'package:web_gestor_site_covertix/widgets/biolink/biolink_item_icone_widget.dart';

class BiolinkItemStackCard extends StatelessWidget {
  final BioLinkItemModel item;
  final int posicao;
  final int listIndex;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BiolinkItemStackCard({
    super.key,
    required this.item,
    required this.posicao,
    required this.listIndex,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final urlExibicao = dominioParaFormulario(item.url);
    final ativo = item.ativo ?? true;

    return Material(
      color: ConvertixColors.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      child: _biolinkCardDecoration(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              _biolinkDragHandle(listIndex),
              _biolinkPositionBadge(posicao),
              appSizedBox(width: AppSpacing.normal),
              if (item.icone != null) ...[
                BiolinkItemIconeWidget(icone: item.icone),
                appSizedBox(width: AppSpacing.small),
              ],
              Expanded(child: _biolinkItemInfo(item: item, urlExibicao: urlExibicao)),
              appSizedBox(width: AppSpacing.small),
              _biolinkStatusBadge(ativo),
              _biolinkActionsMenu(onEdit: onEdit, onDelete: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _biolinkCardDecoration({required Widget child}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(AppTheme.radiusCard),
      border: Border.all(color: ConvertixColors.border),
      boxShadow: [
        BoxShadow(
          color: ConvertixColors.textPrimary.withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: child,
  );
}

Widget _biolinkDragHandle(int listIndex) {
  return ReorderableDragStartListener(
    index: listIndex,
    child: MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: Icon(Icons.drag_indicator, color: ConvertixColors.textMuted, size: 22),
      ),
    ),
  );
}

Widget _biolinkPositionBadge(int posicao) {
  return Container(
    width: 28,
    height: 28,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: ConvertixColors.primaryLight,
      borderRadius: BorderRadius.circular(8),
    ),
    child: appText(
      posicao.toString(),
      color: ConvertixColors.primaryDark,
      bold: true,
      fontSize: AppFontSizes.verySmall,
    ),
  );
}

Widget _biolinkItemInfo({
  required BioLinkItemModel item,
  required String urlExibicao,
}) {
  final titulo = item.titulo?.trim().isNotEmpty == true ? item.titulo! : 'Sem título';

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      appText(
        titulo,
        color: ConvertixColors.textPrimary,
        bold: true,
        overflow: true,
      ),
      if (urlExibicao.isNotEmpty)
        appText(
          urlExibicao,
          color: ConvertixColors.textSecondary,
          fontSize: AppFontSizes.verySmall,
          overflow: true,
        ),
    ],
  );
}

Widget _biolinkStatusBadge(bool ativo) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: ativo ? ConvertixColors.primaryLight : ConvertixColors.background,
      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(
        color: ativo
            ? ConvertixColors.primary.withValues(alpha: 0.3)
            : ConvertixColors.border,
      ),
    ),
    child: appText(
      ativo ? 'Ativo' : 'Inativo',
      color: ativo ? ConvertixColors.primaryDark : ConvertixColors.textMuted,
      fontSize: AppFontSizes.verySmall,
      bold: true,
    ),
  );
}

Widget _biolinkActionsMenu({
  required VoidCallback? onEdit,
  required VoidCallback? onDelete,
}) {
  return PopupMenuButton<void>(
    icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
    iconSize: 20,
    color: AppColors.white,
    padding: EdgeInsets.zero,
    itemBuilder: (context) => [
      _biolinkEditMenuItem(onEdit),
      _biolinkDeleteMenuItem(onDelete),
    ],
  );
}

PopupMenuItem<void> _biolinkEditMenuItem(VoidCallback? onEdit) {
  return PopupMenuItem(
    onTap: onEdit,
    child: const Row(
      children: [
        Icon(Icons.edit_outlined, size: 18),
        SizedBox(width: 8),
        Text('Editar'),
      ],
    ),
  );
}

PopupMenuItem<void> _biolinkDeleteMenuItem(VoidCallback? onDelete) {
  return PopupMenuItem(
    onTap: onDelete,
    child: Row(
      children: [
        Icon(Icons.delete_outline, size: 18, color: AppColors.red),
        const SizedBox(width: 8),
        Text('Excluir', style: TextStyle(color: AppColors.red)),
      ],
    ),
  );
}
