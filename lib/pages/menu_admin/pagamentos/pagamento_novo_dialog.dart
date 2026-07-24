import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/function/money_input_formatter.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';

class PagamentoNovoDialog extends StatefulWidget {
  const PagamentoNovoDialog({super.key});

  @override
  State<PagamentoNovoDialog> createState() => _PagamentoNovoDialogState();
}

class _PagamentoNovoDialogState extends State<PagamentoNovoDialog> {
  final PagamentosBloc bloc = PagamentosBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _valorForm;
  late final AppFormField _descricaoForm;
  late final AppFormField _referenciaForm;
  late final AppFormField _vencimentoForm;

  bool _isAdmin = false;
  List<ClienteModel> _clientes = [];
  int? _clienteId;
  bool _loadingClientes = false;

  @override
  void initState() {
    super.initState();
    _initForms();
    _carregarContexto();
  }

  Future<void> _carregarContexto() async {
    final admin = await isAdminLogado();
    if (!mounted) return;
    setState(() => _isAdmin = admin);
    if (admin) {
      setState(() => _loadingClientes = true);
      try {
        final clientes = await listarClientesLookup();
        if (!mounted) return;
        setState(() {
          _clientes = clientes;
          _loadingClientes = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _loadingClientes = false);
      }
    }
  }

  void _initForms() {
    _valorForm = AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: ConvertixColors.inputFill,
      icon: const Icon(Icons.attach_money, color: ConvertixColors.primary),
      hint: 'Valor (ex: 99,90)',
      textInputType: TextInputType.number,
      textInputFormatter: const MoneyInputFormatter(),
      // Asaas UNDEFINED (cliente escolhe a forma) exige mínimo R$ 5,00
      validator: (v) => validateMoney(v, min: 5),
    );
    _descricaoForm = _field('Descrição', Icons.description_outlined);
    _referenciaForm = _field(
      'Referência externa (opcional)',
      Icons.tag_outlined,
      required: false,
    );
    _vencimentoForm = _field(
      'Vencimento (dd/mm/aaaa)',
      Icons.event_outlined,
      required: false,
    );
    _vencimentoForm.controller.text = formatDateForm(DateTime.now());
  }

  AppFormField _field(String hint, IconData icon, {bool required = true}) {
    return AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: ConvertixColors.inputFill,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: required ? (v) => validateNotEmpty(v, hint) : null,
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(PagamentosState state) {
    if (state is PagamentosSaveErrorState) {
      showToastError(message: state.errorModel.mensagem);
    }
    if (state is PagamentosSaveSuccessState) {
      final invoiceUrl = state.pagamento.invoiceUrl;
      showToastSuccess(message: 'Cobrança gerada. O cliente escolhe a forma ao pagar.');
      if (!mounted) return;
      Navigator.of(context).pop(true);

      if (invoiceUrl != null && invoiceUrl.isNotEmpty) {
        final rootContext = AppContext.navigatorKey.currentContext;
        if (rootContext != null) {
          showDialog<void>(
            context: rootContext,
            builder: (_) => Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: _LinkCobrancaDialog(invoiceUrl: invoiceUrl),
            ),
          );
        }
      }
    }
  }

  bool _camposValidos() {
    if (_isAdmin && _clienteId == null) {
      showToastWarning(message: 'Selecione o cliente');
      return false;
    }
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    return true;
  }

  void _submit() {
    if (!_camposValidos()) return;

    final valor = parseMoneyBr(_valorForm.value);
    if (valor == null || valor <= 0) {
      showToastWarning(message: 'Informe um valor válido');
      return;
    }

    final vencimento = parseFormDate(_vencimentoForm.value);
    final dataApi = vencimento != null ? formatApiDate(vencimento) : null;
    final referencia = _referenciaForm.value.trim();

    bloc.add(PagamentosCriarEvent(
      valor: valor,
      descricao: _descricaoForm.value.trim(),
      clienteId: _clienteId,
      dataVencimento: dataApi,
      externalReference: referencia.isEmpty ? null : referencia,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PagamentosBloc, PagamentosState>(
      bloc: bloc,
      listenWhen: (prev, curr) =>
          curr is PagamentosSaveSuccessState ||
          curr is PagamentosSaveErrorState,
      buildWhen: (prev, curr) =>
          curr is PagamentosSaveLoadingState ||
          prev is PagamentosSaveLoadingState,
      listener: (_, state) => _onState(state),
      builder: (context, state) {
        final saving = state is PagamentosSaveLoadingState;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
          child: Material(
            color: ConvertixColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                appDialogHeader(
                  title: 'Novo pagamento',
                  icon: Icons.payment_outlined,
                  onClose: saving ? null : () => Navigator.of(context).pop(false),
                ),
                Expanded(
                  child: saving
                      ? appLoadingCovertix()
                      : Form(
                          key: _formKey,
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(AppSpacing.medium),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _infoFormaCliente(),
                                if (_isAdmin) _clienteDropdown(),
                                _valorForm.formulario,
                                _descricaoForm.formulario,
                                _vencimentoForm.formulario,
                                _referenciaForm.formulario,
                                appSizedBox(height: AppSpacing.medium),
                                appElevatedButtonCovertix(
                                  title: 'Gerar pagamento',
                                  height: 48,
                                  onTap: _submit,
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoFormaCliente() {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.normal),
      child: appContainer(
        padding: const EdgeInsets.all(12),
        backgroundColor: ConvertixColors.primary.withValues(alpha: 0.06),
        radius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: ConvertixColors.primary.withValues(alpha: 0.25)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, size: 18, color: ConvertixColors.primary),
            appSizedBox(width: AppSpacing.small),
            Expanded(
              child: appText(
                'A forma de pagamento (PIX, cartão ou boleto) é escolhida pelo cliente na hora de pagar, pelo link da cobrança.',
                color: ConvertixColors.textSecondary,
                fontSize: AppFontSizes.verySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _clienteDropdown() {
    if (_loadingClientes) {
      return Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.normal),
        child: appText('Carregando clientes...', color: ConvertixColors.textMuted),
      );
    }
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.normal),
      child: covertixDropdownFormField<int?>(
        value: _clienteId,
        hint: 'Cliente',
        items: _clientes
            .where((c) => c.id != null)
            .map(
              (c) => DropdownMenuItem(
                value: c.id,
                child: Text(c.nomeEmpresa ?? 'Cliente ${c.id}'),
              ),
            )
            .toList(),
        onChanged: (v) => setState(() => _clienteId = v),
        validator: (v) => v == null ? 'Selecione o cliente' : null,
      ),
    );
  }
}

class _LinkCobrancaDialog extends StatelessWidget {
  final String invoiceUrl;

  const _LinkCobrancaDialog({required this.invoiceUrl});

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            appDialogHeader(
              title: 'Cobrança gerada',
              icon: Icons.link_outlined,
              onClose: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpacing.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  appText(
                    'Envie o link abaixo para o cliente. Nele ele escolhe PIX, cartão ou boleto.',
                    color: ConvertixColors.textSecondary,
                  ),
                  appSizedBox(height: AppSpacing.normal),
                  appContainer(
                    padding: const EdgeInsets.all(12),
                    backgroundColor: ConvertixColors.inputFill,
                    radius: BorderRadius.circular(AppTheme.radiusInput),
                    border: Border.all(color: ConvertixColors.border),
                    child: SelectableText(
                      invoiceUrl,
                      style: TextStyle(
                        color: ConvertixColors.textPrimary,
                        fontSize: AppFontSizes.verySmall,
                      ),
                    ),
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonCovertix(
                    title: 'Ir para pagamento',
                    height: 44,
                    onTap: () => openExternalLink(invoiceUrl),
                  ),
                  appSizedBox(height: AppSpacing.small),
                  appElevatedButtonCovertixTransparent(
                    title: 'Fechar',
                    height: 44,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
