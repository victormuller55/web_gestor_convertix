import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_model.dart';
import 'package:web_gestor_site_covertix/widgets/biolink/biolink_item_stack_card.dart';

class BiolinkItemsReorderList extends StatelessWidget {
  static const int maxItens = 8;

  final List<BioLinkItemModel> itens;
  final void Function(int oldIndex, int newIndex) onReorder;
  final void Function(BioLinkItemModel item) onEdit;
  final void Function(BioLinkItemModel item) onDelete;

  const BiolinkItemsReorderList({
    super.key,
    required this.itens,
    required this.onReorder,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (itens.isEmpty) return _biolinkEmptyState(maxItens);

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      itemCount: itens.length,
      onReorder: onReorder,
      proxyDecorator: _biolinkReorderProxyDecorator,
      itemBuilder: (context, index) => _biolinkReorderItem(
        item: itens[index],
        index: index,
        total: itens.length,
        onEdit: onEdit,
        onDelete: onDelete,
      ),
    );
  }
}

Widget _biolinkEmptyState(int maxItens) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.link_off_outlined, size: 48, color: ConvertixColors.textMuted),
          appSizedBox(height: AppSpacing.normal),
          appText(
            'Nenhum item cadastrado.',
            color: ConvertixColors.textPrimary,
            bold: true,
          ),
          appSizedBox(height: AppSpacing.small),
          appText(
            'Adicione até $maxItens links para exibir no BioLink.',
            color: ConvertixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
        ],
      ),
    ),
  );
}

Widget _biolinkReorderProxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (context, _) {
      final elevation = lerpDouble(0, 6, animation.value) ?? 0;
      return Material(
        elevation: elevation,
        borderRadius: BorderRadius.circular(12),
        child: child,
      );
    },
  );
}

Widget _biolinkReorderItem({
  required BioLinkItemModel item,
  required int index,
  required int total,
  required void Function(BioLinkItemModel item) onEdit,
  required void Function(BioLinkItemModel item) onDelete,
}) {
  return Padding(
    key: ValueKey(item.id ?? 'item_$index'),
    padding: EdgeInsets.only(bottom: index < total - 1 ? 10 : 0),
    child: BiolinkItemStackCard(
      item: item,
      posicao: index + 1,
      listIndex: index,
      onEdit: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onEdit(item);
        });
      },
      onDelete: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          onDelete(item);
        });
      },
    ),
  );
}
