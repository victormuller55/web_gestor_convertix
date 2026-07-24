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
    }
    if (state is PagamentosErrorState) {
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
          curr is PagamentosLoadingState,
      listener: (_, state) => _onState(state),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
        child: Material(
          color: ConvertixColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          clipBehavior: Clip.antiAlias,
          child: Column(
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
              Expanded(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _loading,
                  builder: (_, loading, __) {
                    if (loading) return appLoadingCovertix();
                    return ValueListenableBuilder<PagamentoModel?>(
                      valueListenable: _pagamento,
                      builder: (_, p, __) {
                        if (p == null) {
                          return Center(
                            child: appText(
                              'Pagamento não encontrado',
                              color: ConvertixColors.textMuted,
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
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.medium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              financeiroStatusChip(p.status),
              const Spacer(),
              appText(
                p.valor == null ? '—' : formataDinheiro(p.valor!),
                bold: true,
                color: ConvertixColors.textPrimary,
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          _info('Forma', labelFormaPagamento(p.formaPagamento)),
          _info('Vencimento', formatDateTable(p.dataVencimento)),
          _info(
            'Mensagem',
            labelMensagemPagamento(p.mensagemAsaas, status: p.status),
          ),
          if (p.invoiceUrl != null && p.invoiceUrl!.isNotEmpty) ...[
            appSizedBox(height: AppSpacing.normal),
            appElevatedButtonCovertix(
              title: 'Ir para pagamento',
              height: 44,
              onTap: () => openExternalLink(p.invoiceUrl!),
            ),
          ],
          if (p.formaPagamento == FormaPagamento.pix &&
              (p.qrCode != null || p.codigoPix != null)) ...[
            appSizedBox(height: AppSpacing.small),
            appElevatedButtonCovertixTransparent(
              title: 'Ver PIX',
              height: 44,
              onTap: _abrirPix,
            ),
          ],
          ValueListenableBuilder<bool>(
            valueListenable: _isAdmin,
            builder: (_, isAdmin, __) {
              if (!isAdmin) return const SizedBox.shrink();
              return Column(
                children: [
                  if (StatusPagamento.podeCancelar(p.status)) ...[
                    appSizedBox(height: AppSpacing.small),
                    appElevatedButtonCovertixTransparent(
                      title: 'Cancelar',
                      height: 44,
                      onTap: _cancelar,
                    ),
                  ],
                  if (StatusPagamento.podeEstornar(p.status)) ...[
                    appSizedBox(height: AppSpacing.small),
                    appElevatedButtonCovertix(
                      title: 'Estornar',
                      height: 44,
                      onTap: _estornar,
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.small),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: appText(label, color: ConvertixColors.textMuted, bold: true),
          ),
          Expanded(
            child: appText(value, color: ConvertixColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
