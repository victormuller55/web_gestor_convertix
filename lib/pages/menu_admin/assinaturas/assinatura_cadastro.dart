import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/money_input_formatter.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/plano_assinatura.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_state.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';

class AssinaturaCadastro extends StatefulWidget {
  const AssinaturaCadastro({super.key});

  @override
  State<AssinaturaCadastro> createState() => _AssinaturaCadastroState();
}

class _AssinaturaCadastroState extends State<AssinaturaCadastro> {
  final AssinaturasBloc bloc = AssinaturasBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField _valorForm;
  late final AppFormField _descricaoForm;
  late final AppFormField _proximaForm;
  late final AppFormField _referenciaForm;

  bool _isAdmin = false;
  bool _carregandoSites = false;
  List<ClienteModel> _clientes = [];
  List<SiteModel> _todosSites = [];
  List<AssinaturaModel> _assinaturas = [];
  List<SiteModel> _sitesDisponiveis = [];

  int? _clienteId;
  int? _siteId;
  PlanoAssinatura _plano = PlanoAssinatura.biolink;

  @override
  void initState() {
    super.initState();
    _valorForm = AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: ConvertixColors.inputFill,
      icon: const Icon(Icons.attach_money, color: ConvertixColors.primary),
      hint: 'Valor (ex: 49,90)',
      textInputType: TextInputType.number,
      textInputFormatter: const MoneyInputFormatter(),
      validator: (v) => validateMoney(v),
    );
    _descricaoForm = _field('Descrição', Icons.description_outlined);
    _proximaForm = _field('Próxima cobrança (dd/mm/aaaa)', Icons.event_outlined);
    _referenciaForm = _field(
      'Referência externa (opcional)',
      Icons.tag_outlined,
      required: false,
    );
    final proxima = DateTime.now().add(const Duration(days: 30));
    _proximaForm.controller.text = formatDateForm(proxima);
    _aplicarPlano(_plano);
    _carregarContexto();
  }

  Future<void> _carregarContexto() async {
    final admin = await isAdminLogado();
    if (!mounted) return;
    setState(() => _isAdmin = admin);
    if (!admin) return;

    try {
      final results = await Future.wait([
        listarClientes(),
        listarSites(),
        listarAssinaturas(),
      ]);
      if (!mounted) return;
      setState(() {
        _clientes = results[0] as List<ClienteModel>;
        _todosSites = results[1] as List<SiteModel>;
        _assinaturas = results[2] as List<AssinaturaModel>;
      });
    } catch (_) {
      if (!mounted) return;
      showToastError(message: 'Não foi possível carregar clientes e sites');
    }
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

  Set<int> get _sitesComAssinaturaAtiva {
    return _assinaturas
        .where((a) => a.status == StatusAssinatura.active && a.siteId != null)
        .map((a) => a.siteId!)
        .toSet();
  }

  Future<void> _onClienteChanged(int? clienteId) async {
    setState(() {
      _clienteId = clienteId;
      _siteId = null;
      _sitesDisponiveis = [];
      _carregandoSites = clienteId != null;
    });

    if (clienteId == null) return;

    try {
      // Garante dados frescos de assinaturas ao trocar cliente.
      final assinaturas = await listarAssinaturas(
        forceRefresh: true,
        status: StatusAssinatura.active,
      );
      if (!mounted) return;

      final ocupados = assinaturas
          .where((a) => a.siteId != null)
          .map((a) => a.siteId!)
          .toSet();

      final disponiveis = _todosSites
          .where((s) => s.clienteId == clienteId && s.id != null && !ocupados.contains(s.id))
          .toList();

      setState(() {
        _assinaturas = assinaturas;
        _sitesDisponiveis = disponiveis;
        _carregandoSites = false;
      });
    } catch (_) {
      if (!mounted) return;
      final disponiveis = _todosSites
          .where(
            (s) =>
                s.clienteId == clienteId &&
                s.id != null &&
                !_sitesComAssinaturaAtiva.contains(s.id),
          )
          .toList();
      setState(() {
        _sitesDisponiveis = disponiveis;
        _carregandoSites = false;
      });
    }
  }

  void _onSiteChanged(int? siteId) {
    SiteModel? site;
    if (siteId != null) {
      for (final item in _sitesDisponiveis) {
        if (item.id == siteId) {
          site = item;
          break;
        }
      }
      if (site != null) {
        _aplicarPlano(PlanoAssinatura.porTipoSite(site.tipo));
      }
    }
    setState(() => _siteId = siteId);
  }

  void _aplicarPlano(PlanoAssinatura plano) {
    _plano = plano;
    if (!plano.manual && plano.valorFixo != null) {
      _valorForm.controller.text = formatMoneyInput(plano.valorFixo!);
      _descricaoForm.controller.text = plano.descricaoPadrao;
    } else if (plano.manual) {
      if (_descricaoForm.value.trim().isEmpty ||
          PlanoAssinatura.todos.any((p) => p.descricaoPadrao == _descricaoForm.value.trim())) {
        _descricaoForm.controller.clear();
      }
      _valorForm.controller.clear();
    }
  }

  void _selecionarPlano(PlanoAssinatura plano) {
    _aplicarPlano(plano);
    setState(() {});
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  void _onState(AssinaturasState state) {
    if (state is AssinaturasSaveErrorState) {
      showToastError(message: state.errorModel.mensagem);
    }
    if (state is AssinaturasSaveSuccessState) {
      showToastSuccess(message: 'Assinatura criada com sucesso');
      Navigator.of(context).pop(true);
    }
  }

  void _submit() {
    if (_clienteId == null) {
      showToastWarning(message: 'Selecione o cliente');
      return;
    }
    if (_siteId == null) {
      showToastWarning(message: 'Selecione um site sem assinatura');
      return;
    }

    if (_plano.manual) {
      if (!_formKey.currentState!.validate()) return;
    }

    final valor = _plano.manual
        ? parseMoneyBr(_valorForm.value)
        : _plano.valorFixo;
    if (valor == null || valor <= 0) {
      showToastWarning(message: 'Informe um valor válido');
      return;
    }

    final descricao = _plano.manual
        ? _descricaoForm.value.trim()
        : (_descricaoForm.value.trim().isEmpty
            ? _plano.descricaoPadrao
            : _descricaoForm.value.trim());
    if (descricao.isEmpty) {
      showToastWarning(message: 'Informe a descrição');
      return;
    }

    final proxima = parseFormDate(_proximaForm.value);
    // forma_pagamento omitida: o cliente escolhe o método em cada cobrança (Asaas UNDEFINED).
    final body = <String, dynamic>{
      'cliente_id': _clienteId,
      'site_id': _siteId,
      'valor': valor,
      'descricao': descricao,
      'ciclo': CicloAssinatura.monthly,
      if (proxima != null) 'proxima_cobranca': formatApiDate(proxima),
      if (_referenciaForm.value.trim().isNotEmpty)
        'external_reference': _referenciaForm.value.trim(),
    };

    bloc.add(AssinaturasCreateEvent(body: body));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AssinaturasBloc, AssinaturasState>(
      bloc: bloc,
      listenWhen: (prev, curr) =>
          curr is AssinaturasSaveSuccessState ||
          curr is AssinaturasSaveErrorState,
      buildWhen: (prev, curr) =>
          curr is AssinaturasSaveLoadingState ||
          prev is AssinaturasSaveLoadingState,
      listener: (_, state) => _onState(state),
      builder: (context, state) {
        final saving = state is AssinaturasSaveLoadingState;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 780),
          child: Material(
            color: ConvertixColors.surface,
            borderRadius: BorderRadius.circular(AppTheme.radiusCard),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                appDialogHeader(
                  title: 'Nova assinatura',
                  icon: Icons.autorenew_outlined,
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
                                if (_isAdmin) ...[
                                  _clienteDropdown(),
                                  appSizedBox(height: AppSpacing.normal),
                                  _siteDropdown(),
                                  appSizedBox(height: AppSpacing.medium),
                                ],
                                appText(
                                  'Plano / mensalidade',
                                  bold: true,
                                  color: ConvertixColors.textPrimary,
                                ),
                                appSizedBox(height: AppSpacing.small),
                                ...PlanoAssinatura.todos.map(_planoOption),
                                if (_plano.manual) ...[
                                  appSizedBox(height: AppSpacing.normal),
                                  _valorForm.formulario,
                                  _descricaoForm.formulario,
                                ] else ...[
                                  appSizedBox(height: AppSpacing.normal),
                                  _resumoPlanoFixo(),
                                ],
                                appSizedBox(height: AppSpacing.normal),
                                _infoFormaPagamentoCliente(),
                                _proximaForm.formulario,
                                _referenciaForm.formulario,
                                appSizedBox(height: AppSpacing.medium),
                                appElevatedButtonCovertix(
                                  title: 'Criar assinatura',
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

  Widget _clienteDropdown() {
    return covertixDropdownFormField<int?>(
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
      onChanged: _onClienteChanged,
    );
  }

  Widget _siteDropdown() {
    if (_clienteId == null) {
      return appText(
        'Selecione um cliente para listar os sites sem assinatura.',
        color: ConvertixColors.textMuted,
        fontSize: AppFontSizes.verySmall,
      );
    }

    if (_carregandoSites) {
      return appText(
        'Carregando sites...',
        color: ConvertixColors.textMuted,
        fontSize: AppFontSizes.verySmall,
      );
    }

    if (_sitesDisponiveis.isEmpty) {
      return appContainer(
        padding: const EdgeInsets.all(12),
        backgroundColor: ConvertixColors.inputFill,
        radius: BorderRadius.circular(AppTheme.radiusInput),
        border: Border.all(color: ConvertixColors.border),
        child: appText(
          'Este cliente não possui sites sem assinatura ativa.',
          color: ConvertixColors.textSecondary,
          fontSize: AppFontSizes.verySmall,
        ),
      );
    }

    return covertixDropdownFormField<int?>(
      value: _siteId,
      hint: 'Site sem assinatura',
      items: _sitesDisponiveis
          .map(
            (s) => DropdownMenuItem(
              value: s.id,
              child: Text(
                '${s.nome ?? 'Site ${s.id}'} (${SiteModel.labelTipo(s.tipo)})',
              ),
            ),
          )
          .toList(),
      onChanged: _onSiteChanged,
    );
  }

  Widget _planoOption(PlanoAssinatura plano) {
    final selected = _plano.id == plano.id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusInput),
        onTap: () => _selecionarPlano(plano),
        child: appContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          backgroundColor: selected
              ? ConvertixColors.primary.withValues(alpha: 0.08)
              : ConvertixColors.inputFill,
          radius: BorderRadius.circular(AppTheme.radiusInput),
          border: Border.all(
            color: selected ? ConvertixColors.primary : ConvertixColors.border,
            width: selected ? 1.5 : 1,
          ),
          child: Row(
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: selected ? ConvertixColors.primary : ConvertixColors.textMuted,
                size: 20,
              ),
              appSizedBox(width: AppSpacing.normal),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      plano.titulo,
                      bold: true,
                      color: ConvertixColors.textPrimary,
                      fontSize: AppFontSizes.verySmall,
                    ),
                    appText(
                      plano.labelValor,
                      color: ConvertixColors.textSecondary,
                      fontSize: AppFontSizes.verySmall,
                    ),
                  ],
                ),
              ),
              if (plano.tipoSite != null)
                appText(
                  SiteModel.labelTipo(plano.tipoSite),
                  color: ConvertixColors.primary,
                  fontSize: AppFontSizes.verySmall,
                  bold: true,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _resumoPlanoFixo() {
    return appContainer(
      padding: const EdgeInsets.all(12),
      backgroundColor: ConvertixColors.inputFill,
      radius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(
            _plano.descricaoPadrao,
            color: ConvertixColors.textPrimary,
            bold: true,
          ),
          appSizedBox(height: 4),
          appText(
            _plano.labelValor,
            color: ConvertixColors.primary,
            bold: true,
          ),
          appSizedBox(height: 4),
          appText(
            'Ciclo: Mensal',
            color: ConvertixColors.textMuted,
            fontSize: AppFontSizes.verySmall,
          ),
        ],
      ),
    );
  }

  Widget _infoFormaPagamentoCliente() {
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
                'A forma de pagamento (PIX, cartão ou boleto) é escolhida pelo cliente em cada cobrança mensal.',
                color: ConvertixColors.textSecondary,
                fontSize: AppFontSizes.verySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
