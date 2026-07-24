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
  State<AssinaturaDetalheDialog> createState() => _AssinaturaDetalheDialogState();
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
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
          child: Material(
            color: ConvertixColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                appDialogHeader(
                  title: 'Detalhe da assinatura',
                  icon: Icons.autorenew_outlined,
                  subtitle: _assinatura?.descricao,
                  onClose: () => Navigator.of(context).pop(),
                ),
                Expanded(
                  child: loading
                      ? appLoadingCovertix()
                      : _assinatura == null
                          ? Center(
                              child: appText(
                                'Assinatura não encontrada',
                                color: ConvertixColors.textMuted,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              financeiroStatusChip(a.status, assinatura: true),
              const Spacer(),
              appText(
                a.valor == null ? '—' : formataDinheiro(a.valor!),
                bold: true,
                color: ConvertixColors.textPrimary,
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          _info('Ciclo', labelCicloAssinatura(a.ciclo)),
          _info('Forma', labelFormaPagamento(a.formaPagamento)),
          _info('Cliente', a.clienteNomeEmpresa ?? '—'),
          _info('Produto', labelProdutoAssinatura(a)),
          _info(
            'Site',
            (a.siteNome == null || a.siteNome!.trim().isEmpty)
                ? '—'
                : a.siteNome!.trim(),
          ),
          _info('Próxima cobrança', formatDateTable(a.proximaCobranca)),
          _info('Código Asaas', a.asaasSubscriptionId ?? '—'),
          if (_isAdmin && a.status == StatusAssinatura.active) ...[
            appSizedBox(height: AppSpacing.normal),
            appElevatedButtonCovertixTransparent(
              title: 'Cancelar assinatura',
              height: 44,
              onTap: _cancelar,
            ),
          ],
          appSizedBox(height: AppSpacing.medium),
          appText(
            'Cobranças',
            bold: true,
            color: ConvertixColors.textPrimary,
          ),
          appSizedBox(height: AppSpacing.normal),
          if (a.cobrancas.isEmpty)
            appText('Nenhuma cobrança registrada.', color: ConvertixColors.textMuted)
          else
            ...a.cobrancas.map(_cobrancaItem),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: appText(label, color: ConvertixColors.textMuted),
          ),
          Expanded(
            child: appText(value, color: ConvertixColors.textPrimary, bold: true),
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    p.descricao ?? 'Cobrança',
                    bold: true,
                    color: ConvertixColors.textPrimary,
                  ),
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
