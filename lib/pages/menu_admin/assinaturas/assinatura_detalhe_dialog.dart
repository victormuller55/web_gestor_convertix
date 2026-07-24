import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';

class AssinaturaDetalheDialog extends StatefulWidget {
  final int assinaturaId;

  const AssinaturaDetalheDialog({super.key, required this.assinaturaId});

  @override
  State<AssinaturaDetalheDialog> createState() =>
      _AssinaturaDetalheDialogState();
}

class _AssinaturaDetalheDialogState extends State<AssinaturaDetalheDialog> {
  final AssinaturasBloc bloc = AssinaturasBloc();
  AssinaturaModel? _assinatura;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _carregarPermissao();
    bloc.add(AssinaturasDetalheEvent(assinaturaId: widget.assinaturaId));
  }

  Future<void> _carregarPermissao() async {
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    setState(() => _isAdmin = isAdmin);
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(AssinaturasState state) {
    if (state is AssinaturasDetalheSuccessState) {
      setState(() => _assinatura = state.assinatura);
    }
    if (state is AssinaturasActionSuccessState) {
      showToastSuccess(message: state.message);
      Navigator.of(context).pop(true);
    }
    if (state is AssinaturasErrorState) {
      showToastError(message: state.errorModel.mensagem);
    }
  }

  Future<void> _cancelar() async {
    if (!_isAdmin) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Cancelar assinatura',
      message: 'Deseja cancelar esta assinatura?',
      icon: Icons.cancel_outlined,
      confirmLabel: 'Cancelar assinatura',
      destructive: true,
    );
    if (ok == true) {
      bloc.add(AssinaturasCancelarEvent(assinaturaId: widget.assinaturaId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssinaturasBloc, AssinaturasState>(
      bloc: bloc,
      listenWhen: (prev, curr) =>
          curr is AssinaturasDetalheSuccessState ||
          curr is AssinaturasActionSuccessState ||
          curr is AssinaturasErrorState,
      buildWhen: (prev, curr) =>
          curr is AssinaturasLoadingState ||
          curr is AssinaturasDetalheSuccessState ||
          curr is AssinaturasErrorState ||
          (prev is AssinaturasLoadingState && curr is! AssinaturasLoadingState),
      listener: (_, state) => _onState(state),
      builder: (context, state) {
        final loading = state is AssinaturasLoadingState && _assinatura == null;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
          child: Material(
            color: ConvertixColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                appDialogHeader(
                  title: 'Detalhe da assinatura',
                  icon: Icons.autorenew_outlined,
                  subtitle: _assinatura?.descricao,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Flexible(
                  child: loading
                      ? SizedBox(height: 180, child: appLoadingCovertix())
                      : _assinatura == null
                          ? Padding(
                              padding: EdgeInsets.all(AppSpacing.medium),
                              child: Center(
                                child: appText(
                                  'Assinatura não encontrada',
                                  color: ConvertixColors.textMuted,
                                ),
                              ),
                            )
                          : _content(_assinatura!),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _content(AssinaturaModel a) {
    final podeCancelar = _isAdmin && a.status == StatusAssinatura.active;

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _resumoCard(a),
          appSizedBox(height: AppSpacing.medium),
          _detalhesCard(a),
          appSizedBox(height: AppSpacing.medium),
          _cobrancasSection(a),
          if (podeCancelar) ...[
            appSizedBox(height: AppSpacing.medium),
            appText(
              'Ações',
              bold: true,
              color: ConvertixColors.textPrimary,
            ),
            appSizedBox(height: AppSpacing.normal),
            appElevatedButtonCovertix(
              title: 'Cancelar assinatura',
              height: 44,
              color: ConvertixColors.error,
              invertedStyle: true,
              onTap: _cancelar,
            ),
          ],
        ],
      ),
    );
  }

  Widget _resumoCard(AssinaturaModel a) {
    return appContainer(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpacing.medium),
      backgroundColor: ConvertixColors.background,
      radius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              financeiroStatusChip(a.status, assinatura: true),
              const Spacer(),
              Icon(
                Icons.autorenew_outlined,
                size: 18,
                color: ConvertixColors.textMuted,
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.normal),
          appText(
            'Valor',
            color: ConvertixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
          appSizedBox(height: 4),
          appText(
            a.valor == null ? '—' : formataDinheiro(a.valor!),
            bold: true,
            fontSize: AppFontSizes.medium,
            color: ConvertixColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _detalhesCard(AssinaturaModel a) {
    final siteNome = (a.siteNome == null || a.siteNome!.trim().isEmpty)
        ? '—'
        : a.siteNome!.trim();

    return appContainer(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.medium,
        vertical: AppSpacing.normal,
      ),
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        children: [
          _infoRow(
            icon: Icons.repeat_outlined,
            label: 'Ciclo',
            value: labelCicloAssinatura(a.ciclo),
          ),
          _divider(),
          _infoRow(
            icon: Icons.credit_card_outlined,
            label: 'Forma',
            value: labelFormaPagamento(a.formaPagamento),
          ),
          _divider(),
          _infoRow(
            icon: Icons.person_outline,
            label: 'Cliente',
            value: a.clienteNomeEmpresa ?? '—',
          ),
          _divider(),
          _infoRow(
            icon: Icons.inventory_2_outlined,
            label: 'Produto',
            value: labelProdutoAssinatura(a),
          ),
          _divider(),
          _infoRow(
            icon: Icons.language_outlined,
            label: 'Site',
            value: siteNome,
          ),
          _divider(),
          _infoRow(
            icon: Icons.event_outlined,
            label: 'Próxima cobrança',
            value: formatDateTable(a.proximaCobranca),
          ),
          _divider(),
          _infoRow(
            icon: Icons.tag_outlined,
            label: 'Código Asaas',
            value: a.asaasSubscriptionId ?? '—',
          ),
        ],
      ),
    );
  }

  Widget _cobrancasSection(AssinaturaModel a) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            appText(
              'Cobranças',
              bold: true,
              color: ConvertixColors.textPrimary,
            ),
            const Spacer(),
            if (a.cobrancas.isNotEmpty)
              appContainer(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                backgroundColor: ConvertixColors.primaryLight,
                radius: BorderRadius.circular(AppTheme.radiusPill),
                child: appText(
                  '${a.cobrancas.length}',
                  bold: true,
                  fontSize: AppFontSizes.verySmall,
                  color: ConvertixColors.primary,
                ),
              ),
          ],
        ),
        appSizedBox(height: AppSpacing.normal),
        if (a.cobrancas.isEmpty)
          appContainer(
            width: double.infinity,
            padding: EdgeInsets.all(AppSpacing.medium),
            backgroundColor: ConvertixColors.background,
            radius: BorderRadius.circular(AppTheme.radiusInput),
            border: Border.all(color: ConvertixColors.border),
            child: appText(
              'Nenhuma cobrança registrada.',
              color: ConvertixColors.textMuted,
            ),
          )
        else
          ...a.cobrancas.map(_cobrancaItem),
      ],
    );
  }

  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: ConvertixColors.border.withValues(alpha: 0.8),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppSpacing.normal),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ConvertixColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: ConvertixColors.primary),
          ),
          appSizedBox(width: AppSpacing.normal),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                appText(
                  label,
                  color: ConvertixColors.textMuted,
                  fontSize: AppFontSizes.verySmall,
                ),
                appSizedBox(height: 2),
                appText(
                  value,
                  bold: true,
                  color: ConvertixColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cobrancaItem(PagamentoModel p) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: appContainer(
        padding: const EdgeInsets.all(12),
        backgroundColor: ConvertixColors.background,
        radius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: ConvertixColors.border),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: ConvertixColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 18,
                color: ConvertixColors.primary,
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    p.descricao ?? 'Cobrança',
                    bold: true,
                    color: ConvertixColors.textPrimary,
                  ),
                  appSizedBox(height: 2),
                  appText(
                    formatDateTable(p.createdAt),
                    color: ConvertixColors.textMuted,
                    fontSize: AppFontSizes.verySmall,
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                appText(
                  p.valor == null ? '—' : formataDinheiro(p.valor!),
                  bold: true,
                  color: ConvertixColors.textPrimary,
                ),
                appSizedBox(height: 4),
                financeiroStatusChip(p.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
