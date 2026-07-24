import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';

class PagamentoPixDialog extends StatefulWidget {
  final PagamentoModel pagamento;

  const PagamentoPixDialog({super.key, required this.pagamento});

  @override
  State<PagamentoPixDialog> createState() => _PagamentoPixDialogState();
}

class _PagamentoPixDialogState extends State<PagamentoPixDialog> {
  final PagamentosBloc bloc = PagamentosBloc();
  late PagamentoModel _pagamento;
  Timer? _pollTimer;
  bool _confirmado = false;

  @override
  void initState() {
    super.initState();
    _pagamento = widget.pagamento;
    _confirmado = StatusPagamento.isPago(_pagamento.status);
    if (!_confirmado && _pagamento.id != null) {
      _pollTimer = Timer.periodic(const Duration(seconds: 7), (_) {
        bloc.add(PagamentosSincronizarStatusEvent(pagamentoId: _pagamento.id!));
      });
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    bloc.close();
    super.dispose();
  }

  void _onState(PagamentosState state) {
    if (state is PagamentosStatusUpdatedState) {
      setState(() => _pagamento = state.pagamento);
      if (StatusPagamento.isPago(state.pagamento.status) && !_confirmado) {
        _confirmado = true;
        _pollTimer?.cancel();
        showToastSuccess(message: 'Pagamento confirmado!');
      }
    }
    if (state is PagamentosSaveErrorState) {
      showToastError(message: state.errorModel.mensagem);
    }
  }

  Future<void> _copiarCodigo() async {
    final codigo = _pagamento.codigoPix;
    if (codigo == null || codigo.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: codigo));
    showToastSuccess(message: 'Código PIX copiado');
  }

  Widget? _qrImage() {
    final raw = _pagamento.qrCode;
    if (raw == null || raw.isEmpty) return null;
    try {
      final cleaned = raw.contains(',') ? raw.split(',').last : raw;
      final bytes = base64Decode(cleaned);
      return Image.memory(bytes, width: 220, height: 220, fit: BoxFit.contain);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<PagamentosBloc, PagamentosState>(
      bloc: bloc,
      listener: (_, state) => _onState(state),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 720),
        child: Material(
          color: ConvertixColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusCard),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              appDialogHeader(
                title: _confirmado ? 'Pagamento confirmado' : 'Pagamento PIX',
                icon: _confirmado ? Icons.check_circle_outline : Icons.qr_code_2_outlined,
                subtitle: _pagamento.descricao,
                onClose: () => Navigator.of(context).pop(true),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(AppSpacing.medium),
                  child: Column(
                    children: [
                      financeiroStatusChip(_pagamento.status),
                      appSizedBox(height: AppSpacing.medium),
                      appText(
                        _pagamento.valor == null
                            ? '—'
                            : formataDinheiro(_pagamento.valor!),
                        bold: true,
                        fontSize: AppFontSizes.medium,
                        color: ConvertixColors.textPrimary,
                      ),
                      appSizedBox(height: AppSpacing.medium),
                      if (!_confirmado) ...[
                        _qrImage() ??
                            appText(
                              'QR Code indisponível',
                              color: ConvertixColors.textMuted,
                            ),
                        appSizedBox(height: AppSpacing.medium),
                        if (_pagamento.codigoPix != null &&
                            _pagamento.codigoPix!.isNotEmpty) ...[
                          appContainer(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            backgroundColor: ConvertixColors.background,
                            radius: BorderRadius.circular(AppTheme.radiusInput),
                            border: Border.all(color: ConvertixColors.border),
                            child: SelectableText(
                              _pagamento.codigoPix!,
                              style: TextStyle(
                                fontSize: AppFontSizes.verySmall,
                                color: ConvertixColors.textSecondary,
                              ),
                            ),
                          ),
                          appSizedBox(height: AppSpacing.normal),
                          appElevatedButtonCovertix(
                            title: 'Copiar código PIX',
                            height: 44,
                            onTap: _copiarCodigo,
                          ),
                        ],
                        appSizedBox(height: AppSpacing.medium),
                        appText(
                          'Aguardando confirmação… atualizamos automaticamente.',
                          color: ConvertixColors.textMuted,
                          fontSize: AppFontSizes.verySmall,
                        ),
                      ] else
                        Icon(
                          Icons.check_circle,
                          color: const Color(0xFF059669),
                          size: 72,
                        ),
                      appSizedBox(height: AppSpacing.medium),
                      appElevatedButtonCovertixTransparent(
                        title: 'Fechar',
                        height: 44,
                        onTap: () => Navigator.of(context).pop(true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
