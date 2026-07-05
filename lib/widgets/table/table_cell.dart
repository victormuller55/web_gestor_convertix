import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/documento_formatter.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_breakpoint_scope.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_layout.dart';

Widget buttonAction({
  required IconData icon,
  required void Function() onTap,
  Color? color,
  String? tootip,
  double? height,
  double? width,
  double? iconSize,
}) {
  var hover = false;

  return InkWell(
    onTap: onTap,
    child: StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => hover = true),
          onExit: (_) => setState(() => hover = false),
          child: Tooltip(
            message: tootip ?? '',
            child: _buttonActionContainer(
              hover: hover,
              icon: icon,
              color: color,
              height: height,
              width: width,
              iconSize: iconSize,
            ),
          ),
        );
      },
    ),
  );
}

Widget _buttonActionContainer({
  required bool hover,
  required IconData icon,
  Color? color,
  double? height,
  double? width,
  double? iconSize,
}) {
  final baseColor = color ?? ConvertixColors.buttonPrimary;

  return AnimatedContainer(
    duration: AppTheme.buttonHoverDuration,
    curve: Curves.easeInOut,
    height: height ?? 40,
    width: width ?? 40,
    decoration: BoxDecoration(
      color: hover ? AppColors.white : baseColor,
      borderRadius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(
        color: hover ? ConvertixColors.buttonPrimary : baseColor,
        width: hover ? AppTheme.buttonBorderWidthHover : 0,
      ),
    ),
    child: Icon(
      icon,
      size: iconSize ?? 17,
      color: hover ? ConvertixColors.buttonPrimary : AppColors.white,
    ),
  );
}

String formatTableDateTime(DateTime? value) {
  if (value == null) return '—';
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');
  return '$day/$month/${value.year} $hour:$minute';
}

Widget cellDateTime(DateTime? value, double flex, {bool showDivider = true}) {
  return cellText(formatTableDateTime(value), flex, showDivider: showDivider);
}

Widget cellDate(DateTime? value, double flex, {bool showDivider = true}) {
  return cellText(formatDateTable(value), flex, showDivider: showDivider);
}

Widget cellMoney(double? value, double flex, {bool showDivider = true}) {
  final text = value == null ? '—' : formataDinheiro(value);
  return cellText(text, flex, showDivider: showDivider);
}

Widget cellDuracaoDominio(int? dias, double flex, {bool showDivider = true}) {
  if (dias == null) {
    return cellText('—', flex, showDivider: showDivider);
  }

  final badge = _duracaoDominioBadge(dias);

  return cell(
    flex: flex,
    showDivider: showDivider,
    child: _tableStatusChip(
      label: badge.label,
      backgroundColor: badge.backgroundColor,
      textColor: badge.textColor,
      borderColor: badge.borderColor,
      horizontalPadding: 8,
    ),
  );
}

Widget cell({
  required Widget child,
  required double flex,
  Alignment alignment = Alignment.centerLeft,
  bool showDivider = true,
}) {
  return Builder(
    builder: (context) {
      final useFixed = TableBreakpointScope.isScrollableMode(context);
      if (useFixed) {
        return _tableCellShell(
          child: child,
          fixed: true,
          context: context,
          alignment: alignment,
          showDivider: showDivider,
        );
      }
      return Expanded(
        flex: (flex * 100).toInt(),
        child: _tableCellShell(
          child: child,
          fixed: false,
          context: context,
          alignment: alignment,
          showDivider: showDivider,
        ),
      );
    },
  );
}

Widget cellName(String value, {double flex = 0.7, bool showDivider = true}) {
  return cell(
    child: _tableSelectableText(
      value,
      color: ConvertixColors.textPrimary,
      bold: true,
    ),
    flex: flex,
    showDivider: showDivider,
  );
}

Widget cellText(String value, double flex, {bool showDivider = true}) {
  return cell(
    child: _tableSelectableText(value),
    flex: flex,
    showDivider: showDivider,
  );
}

Widget cellLink(String? value, double flex, {bool showDivider = true}) {
  final display = value == null || value.trim().isEmpty ? '—' : value.trim();

  return cell(
    child: _cellLinkContent(display),
    flex: flex,
    showDivider: showDivider,
  );
}

Widget cellFoto(String? path, double flex, {bool showDivider = true}) {
  if (path == null || path.trim().isEmpty) {
    return cellText('—', flex, showDivider: showDivider);
  }

  return cell(
    flex: flex,
    showDivider: showDivider,
    child: _cellFotoImage(path),
  );
}

Widget cellDocumento(String value) {
  return cell(
    flex: 0.4,
    child: _tableSelectableText(formataDocumento(value)),
  );
}

Widget cellAction(Widget widget) {
  return cell(flex: 0.3, child: widget, alignment: Alignment.center);
}

Widget cellEditar({required void Function() onEdit}) {
  return cell(
    flex: 0.2,
    child: buttonAction(icon: Icons.edit, tootip: 'Editar item', onTap: onEdit),
    alignment: Alignment.center,
  );
}

Widget cellExcluir({required void Function() onDelete}) {
  return cell(
    flex: 0.2,
    child: buttonAction(
      icon: Icons.delete,
      tootip: 'Excluir item',
      onTap: onDelete,
      color: AppColors.red,
    ),
    alignment: Alignment.center,
  );
}

Widget cellAtivo(bool ativo, {bool showDivider = true}) {
  return cell(
    flex: 0.3,
    showDivider: showDivider,
    child: _tableStatusChip(
      label: ativo ? 'Ativo' : 'Inativo',
      backgroundColor: ativo ? ConvertixColors.primaryLight : ConvertixColors.background,
      textColor: ativo ? ConvertixColors.primaryDark : ConvertixColors.textMuted,
      borderColor: ativo
          ? ConvertixColors.primary.withValues(alpha: 0.25)
          : ConvertixColors.border,
    ),
  );
}

Widget cellSiteStatus(String? status, double flex, {bool showDivider = true}) {
  final badge = _siteStatusBadge(status);

  return cell(
    flex: flex,
    showDivider: showDivider,
    child: _tableStatusChip(
      label: SiteModel.labelStatus(status),
      backgroundColor: badge.backgroundColor,
      textColor: badge.textColor,
      borderColor: badge.borderColor,
    ),
  );
}

TextStyle _tableCellStyle({
  Color? color,
  bool bold = false,
  TextDecoration? decoration,
}) {
  return TextStyle(
    fontFamily: 'lato',
    fontSize: AppFontSizes.verySmall,
    letterSpacing: 1,
    color: color ?? ConvertixColors.textSecondary,
    fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    decoration: decoration,
  );
}

Widget _tableSelectableText(
  String value, {
  Color? color,
  bool bold = false,
  TextDecoration? decoration,
}) {
  return SelectableText(
    value,
    style: _tableCellStyle(color: color, bold: bold, decoration: decoration),
    maxLines: 1,
  );
}

Widget _tableCellShell({
  required Widget child,
  required bool fixed,
  required BuildContext context,
  Alignment alignment = Alignment.centerLeft,
  bool showDivider = true,
}) {
  final useFixed = fixed || TableBreakpointScope.isScrollableMode(context);

  return Container(
    height: tableRowHeight,
    width: useFixed ? fixedCellWidth : null,
    decoration: BoxDecoration(
      border: showDivider
          ? const Border(
              right: BorderSide(color: ConvertixColors.border, width: 1),
            )
          : null,
    ),
    padding: const EdgeInsets.symmetric(horizontal: tableCellPadding),
    alignment: alignment,
    child: child,
  );
}

Widget _tableStatusChip({
  required String label,
  required Color backgroundColor,
  required Color textColor,
  required Color borderColor,
  double horizontalPadding = 10,
}) {
  return appContainer(
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 4),
    backgroundColor: backgroundColor,
    radius: BorderRadius.circular(AppTheme.radiusInput),
    border: Border.all(color: borderColor),
    child: _tableSelectableText(label, color: textColor, bold: true),
  );
}

Widget _cellLinkContent(String display) {
  if (display == '—') {
    return _tableSelectableText(display, color: ConvertixColors.textMuted);
  }

  final uri = Uri.tryParse(normalizeUrl(display));
  if (uri != null && uri.host.isNotEmpty) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () => openExternalLink(display),
        child: _tableSelectableText(
          display,
          color: ConvertixColors.primary,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  return _tableSelectableText(display);
}

Widget _cellFotoImage(String path) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(AppTheme.radiusInput),
    child: Image.network(
      fotoUrl(path),
      width: 32,
      height: 32,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.broken_image_outlined,
        size: 20,
        color: ConvertixColors.textMuted,
      ),
    ),
  );
}

({String label, Color backgroundColor, Color textColor, Color borderColor}) _duracaoDominioBadge(int dias) {
  if (dias < 0) {
    return (
      label: 'Vencido (${dias.abs()}d)',
      backgroundColor: ConvertixColors.errorBackground,
      textColor: ConvertixColors.error,
      borderColor: ConvertixColors.error.withValues(alpha: 0.25),
    );
  }

  if (dias <= 30) {
    return (
      label: '${dias}d',
      backgroundColor: const Color(0xFFFEF9C3),
      textColor: const Color(0xFF854D0E),
      borderColor: const Color(0xFFFDE047),
    );
  }

  return (
    label: '${dias}d',
    backgroundColor: ConvertixColors.primaryLight,
    textColor: ConvertixColors.primaryDark,
    borderColor: ConvertixColors.primary.withValues(alpha: 0.25),
  );
}

({Color backgroundColor, Color textColor, Color borderColor}) _siteStatusBadge(String? status) {
  switch (status) {
    case StatusSite.ativo:
      return (
        backgroundColor: ConvertixColors.primaryLight,
        textColor: ConvertixColors.primaryDark,
        borderColor: ConvertixColors.primary.withValues(alpha: 0.25),
      );
    case StatusSite.emDesenvolvimento:
      return (
        backgroundColor: const Color(0xFFFEF9C3),
        textColor: const Color(0xFF854D0E),
        borderColor: const Color(0xFFFDE047),
      );
    default:
      return (
        backgroundColor: ConvertixColors.background,
        textColor: ConvertixColors.textMuted,
        borderColor: ConvertixColors.border,
      );
  }
}
