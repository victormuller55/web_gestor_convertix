import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamento_pix_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';

class PagamentoDetalheDialog extends StatefulWidget {
  final int pagamentoId;

  const PagamentoDetalheDialog({super.key, required this.pagamentoId});

  @override
  State<PagamentoDetalheDialog> createState() => _PagamentoDetalheDialogState();
}

class _PagamentoDetalheDialogState extends State<PagamentoDetalheDialog> {
  final PagamentosBloc bloc = PagamentosBloc();
  final ValueNotifier<PagamentoModel?> _pagamento = ValueNotifier(null);
  final ValueNotifier<bool> _isAdmin = ValueNotifier(false);
  final ValueNotifier<bool> _loading = ValueNotifier(true);
  bool _alterado = false;

  @override
  void initState() {
    super.initState();
    _carregarPermissao();
    bloc.add(PagamentosDetalheEvent(pagamentoId: widget.pagamentoId));
  }

  Future<void> _carregarPermissao() async {
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    _isAdmin.value = isAdmin;
  }

  @override
  void dispose() {
    _pagamento.dispose();
    _isAdmin.dispose();
    _loading.dispose();
    bloc.close();
    super.dispose();
  }

  void _onState(PagamentosState state) {
    if (state is PagamentosDetalheSuccessState) {
      _pagamento.value = state.pagamento;
      _loading.value = false;
    }
    if (state is PagamentosActionSuccessState) {
      showToastSuccess(message: state.message);
      _pagamento.value = state.pagamento;
      _loading.value = false;
      _alterado = true;
    }
    if (state is PagamentosStatusUpdatedState) {
      _pagamento.value = state.pagamento;
      _loading.value = false;
      _alterado = true;
      showToastSuccess(message: 'Status atualizado');
    }
    if (state is PagamentosErrorState) {
      _loading.value = false;
      showToastError(message: state.errorModel.mensagem);
    }
    if (state is PagamentosSaveErrorState) {
      _loading.value = false;
      showToastError(message: state.errorModel.mensagem);
    }
    if (state is PagamentosLoadingState && _pagamento.value == null) {
      _loading.value = true;
    }
  }

  Future<void> _cancelar() async {
    if (!_isAdmin.value) return;
    final p = _pagamento.value;
    if (p?.id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Cancelar pagamento',
      message: 'Deseja cancelar este pagamento?',
      icon: Icons.cancel_outlined,
      confirmLabel: 'Cancelar pagamento',
      destructive: true,
    );
    if (ok == true) {
      bloc.add(PagamentosCancelarEvent(pagamentoId: p!.id!));
    }
  }

  Future<void> _estornar() async {
    if (!_isAdmin.value) return;
    final p = _pagamento.value;
    if (p?.id == null) return;
    final ok = await showAppConfirmDialog(
      context,
      title: 'Estornar pagamento',
      message: 'Deseja estornar este pagamento?',
      icon: Icons.undo_outlined,
      confirmLabel: 'Estornar',
      destructive: true,
    );
    if (ok == true) {
      bloc.add(PagamentosEstornarEvent(pagamentoId: p!.id!));
    }
  }

  void _abrirPix() {
    final p = _pagamento.value;
    if (p == null) return;
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PagamentoPixDialog(pagamento: p),
      ),
    ).then((pago) {
      if (pago == true) _alterado = true;
      bloc.add(PagamentosDetalheEvent(pagamentoId: widget.pagamentoId));
    });
  }

  void _fechar() => Navigator.of(context).pop(_alterado);

  @override
  Widget build(BuildContext context) {
    return BlocListener<PagamentosBloc, PagamentosState>(
      bloc: bloc,
      listenWhen: (prev, curr) =>
          curr is PagamentosDetalheSuccessState ||
          curr is PagamentosActionSuccessState ||
          curr is PagamentosStatusUpdatedState ||
          curr is PagamentosErrorState ||
          curr is PagamentosSaveErrorState ||
          curr is PagamentosLoadingState,
      listener: (_, state) => _onState(state),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 720),
        child: Material(
          color: ConvertixColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ValueListenableBuilder<PagamentoModel?>(
                valueListenable: _pagamento,
                builder: (_, p, __) => appDialogHeader(
                  title: 'Detalhe do pagamento',
                  icon: Icons.receipt_long_outlined,
                  subtitle: p?.descricao,
                  onClose: _fechar,
                ),
              ),
              Flexible(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (_, loading, __) {
                    if (loading) {
                      return SizedBox(
                        height: 180,
                        child: appLoadingCovertix(),
                      );
                    }
                    return ValueListenableBuilder<PagamentoModel?>(
                      valueListenable: _pagamento,
                      builder: (_, p, __) {
                        if (p == null) {
                          return Padding(
                            padding: EdgeInsets.all(AppSpacing.medium),
                            child: Center(
                              child: appText(
                                'Pagamento não encontrado',
                                color: ConvertixColors.textMuted,
                              ),
                            ),
                          );
                        }
                        return _content(p);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(PagamentoModel p) {
    final temInvoice = p.invoiceUrl != null && p.invoiceUrl!.isNotEmpty;
    final temPix = p.formaPagamento == FormaPagamento.pix &&
        (p.qrCode != null || p.codigoPix != null);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
        AppSpacing.medium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _resumoCard(p),
          appSizedBox(height: AppSpacing.medium),
          _detalhesCard(p),
          appSizedBox(height: AppSpacing.medium),
          _acoes(p, temInvoice: temInvoice, temPix: temPix),
        ],
      ),
    );
  }

  Widget _resumoCard(PagamentoModel p) {
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
              financeiroStatusChip(p.status),
              const Spacer(),
              Icon(
                Icons.payments_outlined,
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
            p.valor == null ? '—' : formataDinheiro(p.valor!),
            bold: true,
            fontSize: AppFontSizes.medium,
            color: ConvertixColors.textPrimary,
          ),
        ],
      ),
    );
  }

  Widget _detalhesCard(PagamentoModel p) {
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
            icon: Icons.credit_card_outlined,
            label: 'Forma',
            value: labelFormaPagamento(p.formaPagamento),
          ),
          _divider(),
          _infoRow(
            icon: Icons.event_outlined,
            label: 'Vencimento',
            value: formatDateTable(p.dataVencimento),
          ),
          _divider(),
          _infoRow(
            icon: Icons.chat_bubble_outline,
            label: 'Mensagem',
            value: labelMensagemPagamento(p.mensagemAsaas, status: p.status),
          ),
        ],
      ),
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

  Widget _acoes(
    PagamentoModel p, {
    required bool temInvoice,
    required bool temPix,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isAdmin,
      builder: (_, isAdmin, __) {
        final podeCancelar = isAdmin && StatusPagamento.podeCancelar(p.status);
        final podeEstornar = isAdmin && StatusPagamento.podeEstornar(p.status);
        final temAcoes =
            temInvoice || temPix || isAdmin || podeCancelar || podeEstornar;

        if (!temAcoes) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            appText(
              'Ações',
              bold: true,
              color: ConvertixColors.textPrimary,
            ),
            appSizedBox(height: AppSpacing.normal),
            if (temInvoice) ...[
              appElevatedButtonCovertix(
                title: 'Ir para pagamento',
                height: 44,
                onTap: () => openExternalLink(p.invoiceUrl!),
              ),
              appSizedBox(height: AppSpacing.small),
            ],
            if (temPix) ...[
              appElevatedButtonCovertixTransparent(
                title: 'Ver PIX',
                height: 44,
                onTap: _abrirPix,
              ),
              appSizedBox(height: AppSpacing.small),
            ],
            if (isAdmin) ...[
              appElevatedButtonCovertixTransparent(
                title: 'Atualizar status',
                height: 44,
                onTap: () {
                  if (p.id == null) return;
                  _loading.value = true;
                  bloc.add(
                    PagamentosSincronizarStatusEvent(pagamentoId: p.id!),
                  );
                },
              ),
              appSizedBox(height: AppSpacing.small),
            ],
            if (podeCancelar) ...[
              appElevatedButtonCovertixTransparent(
                title: 'Cancelar',
                height: 44,
                onTap: _cancelar,
              ),
              appSizedBox(height: AppSpacing.small),
            ],
            if (podeEstornar)
              appElevatedButtonCovertix(
                title: 'Estornar',
                height: 44,
                color: ConvertixColors.error,
                invertedStyle: true,
                onTap: _estornar,
              ),
          ],
        );
      },
    );
  }
}
