import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/site_dominio_model.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';
import 'package:web_gestor_site_covertix/widgets/dominio_url_form_field.dart';

class SitesCadastro extends StatefulWidget {
  final SiteModel site;
  final bool isDialog;
  final bool isAdmin;

  const SitesCadastro({
    super.key,
    required this.site,
    this.isDialog = false,
    this.isAdmin = true,
  });

  @override
  State<SitesCadastro> createState() => _SitesCadastroState();
}

class _SitesCadastroState extends State<SitesCadastro> {
  final SitesBloc bloc = SitesBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.site.id != null && widget.site.id! > 0;

  late final AppFormField nomeForm;
  late final TextEditingController _dominioController;
  late final AppFormField subdominioForm;
  late final AppFormField valorDominioForm;
  late final AppFormField dataCompraForm;
  late final AppFormField dataFimForm;
  late final AppFormField dataRenovacaoForm;

  final ValueNotifier<bool> _dominioTemTextoNotifier = ValueNotifier(false);

  List<ClienteModel> _clientes = [];
  final ValueNotifier<bool> _carregandoClientesNotifier = ValueNotifier(false);

  int? _clienteIdSelecionado;
  String _tipoSelecionado = TipoSite.biolink;
  String _statusSelecionado = StatusSite.ativo;

  double get _fieldWidth => widget.isDialog ? double.infinity : 400;

  String get _formTitle => _isEditMode ? 'Editar site' : 'Novo site';

  @override
  void initState() {
    super.initState();
    _clienteIdSelecionado = widget.site.clienteId;
    _tipoSelecionado = widget.site.tipo ?? TipoSite.biolink;
    _statusSelecionado = widget.site.status ?? StatusSite.ativo;
    _initForms();

    if (widget.isAdmin) {
      _carregarClientes();
    }
  }

  void _initForms() {
    nomeForm = _buildField(
      hint: 'Digite o nome do site',
      icon: Icons.language_outlined,
      validator: (v) => validateNotEmpty(v, 'Nome'),
    );
    _dominioController = TextEditingController(
      text: dominioParaFormulario(widget.site.dominio),
    );
    _dominioTemTextoNotifier.value = _dominioController.text.trim().isNotEmpty;
    _dominioController.addListener(_onDominioChanged);

    subdominioForm = _buildField(
      hint: 'Subdomínio (opcional)',
      icon: Icons.link_outlined,
    );

    final info = widget.site.dominioInfo;
    valorDominioForm = _buildField(
      hint: 'Valor pago (opcional)',
      icon: Icons.payments_outlined,
      textInputFormatter: AppFormFormatters.realFormatter,
    );
    dataCompraForm = _buildField(
      hint: 'Data compra (dd/mm/aaaa)',
      icon: Icons.calendar_today_outlined,
      textInputFormatter: AppFormFormatters.dateFormatter,
    );
    dataFimForm = _buildField(
      hint: 'Data vencimento (dd/mm/aaaa)',
      icon: Icons.event_busy_outlined,
      textInputFormatter: AppFormFormatters.dateFormatter,
    );
    dataRenovacaoForm = _buildField(
      hint: 'Data renovação (opcional)',
      icon: Icons.autorenew_outlined,
      textInputFormatter: AppFormFormatters.dateFormatter,
    );

    if (info?.valorDominio != null) {
      valorDominioForm.controller.text = formatMoneyInput(info!.valorDominio!);
    }
    dataCompraForm.controller.text = formatDateForm(info?.dataCompraDominio);
    dataFimForm.controller.text = formatDateForm(info?.dataFimDominio);
    dataRenovacaoForm.controller.text = formatDateForm(info?.dataRenovacao);

    nomeForm.controller.text = widget.site.nome ?? '';
    subdominioForm.controller.text = widget.site.subdominio ?? '';
  }

  void _onDominioChanged() {
    final temTexto = _dominioController.text.trim().isNotEmpty;
    if (temTexto != _dominioTemTextoNotifier.value) {
      _dominioTemTextoNotifier.value = temTexto;
    }
  }

  Future<void> _carregarClientes() async {
    _carregandoClientesNotifier.value = true;
    try {
      final clientes = await listarClientes();
      if (!mounted) return;
      _clientes = clientes;
      _carregandoClientesNotifier.value = false;
    } catch (_) {
      if (mounted) {
        showToastError(message: 'Erro ao carregar clientes');
        _carregandoClientesNotifier.value = false;
      }
    }
  }

  AppFormField _buildField({
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputFormatter? textInputFormatter,
  }) {
    return AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      backgroundColor: AppColors.grey100,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
      textInputFormatter: textInputFormatter,
    );
  }

  Widget _dropdownField({required String label, required Widget child}) {
    return appContainer(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(label, color: ConvertixColors.textSecondary, fontSize: AppFontSizes.verySmall),
          appSizedBox(height: AppSpacing.small),
          child,
        ],
      ),
    );
  }

  Widget _clienteDropdownLoading() {
    return _dropdownField(
      label: 'Cliente',
      child: appContainer(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: ConvertixColors.primary),
        ),
      ),
    );
  }

  Widget _clienteDropdownEmpty() {
    return _dropdownField(
      label: 'Cliente',
      child: appText(
        'Nenhum cliente cadastrado',
        color: ConvertixColors.textMuted,
      ),
    );
  }

  Widget _clienteDropdownField() {
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return _dropdownField(
          label: 'Cliente',
          child: CovertixDropdownFormField<int>(
            value: _clienteIdSelecionado,
            hint: 'Selecione o cliente',
            items: _clientes.map((cliente) {
              return DropdownMenuItem(
                value: cliente.id,
                child: Text(cliente.nomeEmpresa ?? 'Cliente #${cliente.id}'),
              );
            }).toList(),
            onChanged: (value) => setDropdownState(() => _clienteIdSelecionado = value),
            validator: (value) => value == null ? 'Cliente é obrigatório' : null,
          ),
        );
      },
    );
  }

  Widget _clienteDropdown() {
    return ValueListenableBuilder<bool>(
      valueListenable: _carregandoClientesNotifier,
      builder: (_, loading, __) {
        if (loading) return _clienteDropdownLoading();
        if (_clientes.isEmpty) return _clienteDropdownEmpty();
        return _clienteDropdownField();
      },
    );
  }

  Widget _tipoDropdown() {
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return _dropdownField(
          label: 'Tipo',
          child: CovertixDropdownFormField<String>(
            value: _tipoSelecionado,
            hint: 'Selecione o tipo',
            items: const [
              DropdownMenuItem(value: TipoSite.biolink, child: Text('BioLink')),
              DropdownMenuItem(value: TipoSite.landingPage, child: Text('Landing Page')),
              DropdownMenuItem(value: TipoSite.siteComercial, child: Text('Site Comercial')),
            ],
            onChanged: (value) {
              if (value != null) setDropdownState(() => _tipoSelecionado = value);
            },
          ),
        );
      },
    );
  }

  Widget _statusDropdown() {
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return _dropdownField(
          label: 'Status',
          child: CovertixDropdownFormField<String>(
            value: _statusSelecionado,
            hint: 'Selecione o status',
            items: const [
              DropdownMenuItem(value: StatusSite.ativo, child: Text('Ativo')),
              DropdownMenuItem(value: StatusSite.inativo, child: Text('Inativo')),
              DropdownMenuItem(
                value: StatusSite.emDesenvolvimento,
                child: Text('Em desenvolvimento'),
              ),
            ],
            onChanged: (value) {
              if (value != null) setDropdownState(() => _statusSelecionado = value);
            },
          ),
        );
      },
    );
  }

  SiteDominioModel? _buildDominioInfo() {
    final valor = parseMoneyBr(valorDominioForm.value);
    final compra = parseFormDate(dataCompraForm.value);
    final fim = parseFormDate(dataFimForm.value);
    final renovacao = parseFormDate(dataRenovacaoForm.value);

    final hasAny =
        valor != null || compra != null || fim != null || renovacao != null;
    if (!hasAny) return null;

    return SiteDominioModel(
      valorDominio: valor,
      dataCompraDominio: compra,
      dataFimDominio: fim,
      dataRenovacao: renovacao,
    );
  }

  String? _validarDominioInfo() {
    if (!_dominioTemTextoNotifier.value) return null;

    final info = _buildDominioInfo();
    if (info == null) return null;

    if (info.dataCompraDominio == null || info.dataFimDominio == null) {
      return 'Informe compra e vencimento do domínio';
    }

    if (info.dataFimDominio!.isBefore(info.dataCompraDominio!)) {
      return 'Vencimento deve ser igual ou posterior à compra';
    }

    if (info.valorDominio != null && info.valorDominio! <= 0) {
      return 'Valor do domínio deve ser maior que zero';
    }

    return null;
  }

  void _save() {
    if (!_isEditMode && !widget.isAdmin) {
      showToastError(
        message: 'Apenas administradores podem cadastrar sites.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final erroDominio = _validarDominioInfo();
    if (erroDominio != null) {
      showToastError(message: erroDominio);
      return;
    }

    final dominio = dominioParaApi(_dominioController.text);
    final hasDominio = dominio.isNotEmpty;
    final dominioInfo = hasDominio ? _buildDominioInfo() : null;
    final tinhaInfo = widget.site.dominioInfo?.hasPersistedData ?? false;

    final site = SiteModel(
      id: widget.site.id,
      clienteId: widget.isAdmin ? _clienteIdSelecionado : widget.site.clienteId,
      nome: nomeForm.value.trim(),
      tipo: _tipoSelecionado,
      dominio: dominio,
      subdominio: subdominioForm.value.trim(),
      status: _statusSelecionado,
      dominioInfo: dominioInfo,
      removeDominioInfo: !hasDominio || (dominioInfo == null && tinhaInfo),
    );

    bloc.add(SitesSaveEvent(site: site));
  }

  void _onBlocState(BuildContext context, SitesState state) {
    if (state is SitesSaveSuccessState) {
      showToastSuccess(message: 'Site salvo com sucesso');
      Navigator.pop(context, true);
    }
    if (state is SitesSaveErrorState) {
      showToastError(message: state.errorModel.mensagem ?? 'Erro ao salvar');
    }
  }

  Widget _loadingView() {
    return appContainer(
      height: 360,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _dominioInfoHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        appText(
          'Informações do domínio',
          bold: true,
          color: ConvertixColors.textPrimary,
        ),
        appSizedBox(height: AppSpacing.small),
        appText(
          'Opcional. Preencha para controlar valor e vencimento.',
          color: ConvertixColors.textMuted,
          fontSize: AppFontSizes.verySmall,
        ),
      ],
    );
  }

  Widget _dominioInfoSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _dominioTemTextoNotifier,
      builder: (_, temTexto, __) {
        if (!temTexto) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            appSizedBox(height: AppSpacing.normal),
            _dominioInfoHeader(),
            valorDominioForm.formulario,
            dataCompraForm.formulario,
            dataFimForm.formulario,
            dataRenovacaoForm.formulario,
          ],
        );
      },
    );
  }

  Widget _dominioField() {
    return dominioUrlFormField(
      controller: _dominioController,
      width: _fieldWidth,
    );
  }

  Widget _formFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.isAdmin) _clienteDropdown(),
          nomeForm.formulario,
          _tipoDropdown(),
          _dominioField(),
          _dominioInfoSection(),
          subdominioForm.formulario,
          _statusDropdown(),
        ],
      ),
    );
  }

  Widget _pageTitle() {
    return appText(
      _formTitle,
      fontSize: AppFontSizes.verySmall,
      bold: true,
      color: ConvertixColors.textPrimary,
    );
  }

  Widget _pageLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(),
        appSizedBox(height: AppSpacing.big),
        _formFields(),
        appSizedBox(height: AppSpacing.big),
        _actionButtons(),
      ],
    );
  }

  Widget _formContentBody(SitesState state) {
    if (state is SitesSaveLoadingState) return _loadingView();
    if (widget.isDialog) return _formFields();
    return _pageLayout();
  }

  Widget _formContent() {
    return BlocConsumer<SitesBloc, SitesState>(
      bloc: bloc,
      listener: _onBlocState,
      buildWhen: (previous, current) =>
          (current is SitesSaveLoadingState) !=
          (previous is SitesSaveLoadingState),
      builder: (context, state) => _formContentBody(state),
    );
  }

  Widget _actionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - AppSpacing.normal) / 2;
        return Row(
          children: [
            Expanded(
              child: appElevatedButtonCovertix(
                title: AppStrings.salvar,
                height: 42,
                width: buttonWidth,
                onTap: _save,
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              child: appElevatedButtonCovertix(
                title: AppStrings.cancelar,
                height: 42,
                width: buttonWidth,
                primary: false,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogHeader() {
    return appDialogHeader(
      title: _formTitle,
      icon: _isEditMode ? Icons.edit_outlined : Icons.language_outlined,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _dialogScrollArea() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 620),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _formContent(),
      ),
    );
  }

  Widget _dialogActionsFooter() {
    return appContainer(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: _actionButtons(),
    );
  }

  Widget _dialogContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogHeader(),
            _dialogScrollArea(),
            _dialogActionsFooter(),
          ],
        ),
      ),
    );
  }

  Widget _scaffoldContent() {
    return scaffold(
      title: _formTitle,
      background: ConvertixColors.background,
      body: appContainer(
        padding: const EdgeInsets.all(24),
        child: _formContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDialog ? _dialogContent() : _scaffoldContent();
  }

  @override
  void dispose() {
    _dominioController.removeListener(_onDominioChanged);
    _dominioTemTextoNotifier.dispose();
    _carregandoClientesNotifier.dispose();
    nomeForm.controller.dispose();
    _dominioController.dispose();
    subdominioForm.controller.dispose();
    valorDominioForm.controller.dispose();
    dataCompraForm.controller.dispose();
    dataFimForm.controller.dispose();
    dataRenovacaoForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
