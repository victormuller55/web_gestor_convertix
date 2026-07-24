import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';

Widget financeiroStatusChip(String? status, {bool assinatura = false}) {
  final color = assinatura ? corStatusAssinatura(status) : corStatusPagamento(status);
  final label = assinatura ? labelStatusAssinatura(status) : labelStatusPagamento(status);

  return appContainer(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    backgroundColor: color.withValues(alpha: 0.12),
    radius: BorderRadius.circular(AppTheme.radiusInput),
    border: Border.all(color: color.withValues(alpha: 0.35)),
    child: appText(
      label,
      color: color,
      fontSize: AppFontSizes.verySmall,
      bold: true,
    ),
  );
}
