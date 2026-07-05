import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/documento_formatter.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/foto_picker_field.dart';

class ClientesCadastro extends StatefulWidget {
  final ClienteModel cliente;
  final bool isDialog;

  const ClientesCadastro({
    super.key,
    required this.cliente,
    this.isDialog = false,
  });

  @override
  State<ClientesCadastro> createState() => _ClientesCadastroState();
}

class _ClientesCadastroState extends State<ClientesCadastro> {
  final ClientesBloc bloc = ClientesBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.cliente.id != null && widget.cliente.id! > 0;

  late final AppFormField nomeEmpresaForm;
  late final AppFormField documentoForm;
  late final AppFormField emailForm;
  late final AppFormField senhaForm;
  late final AppFormField telefoneForm;
  XFile? _novaFoto;

  double get _fieldWidth => widget.isDialog ? double.infinity : 400;

  String get _formTitle => _isEditMode ? 'Editar cliente' : 'Novo cliente';

  @override
  void initState() {
    super.initState();
    _initForms();
  }

  void _initForms() {
    nomeEmpresaForm = _buildField(
      hint: 'Digite o nome da empresa',
      icon: Icons.business_outlined,
      validator: (v) => validateNotEmpty(v, 'Nome da empresa'),
    );
    documentoForm = AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.badge_outlined, color: ConvertixColors.primary),
      hint: 'CPF ou CNPJ',
      textInputFormatter: DocumentoInputFormatter(),
      validator: validateDocumento,
    );
    emailForm = _buildField(
      hint: AppStrings.digiteSeuEmail,
      icon: Icons.email_outlined,
      validator: validateEmail,
    );
    senhaForm = AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.lock_outline, color: ConvertixColors.primary),
      hint: _isEditMode ? 'Nova senha (opcional)' : AppStrings.digiteSuaSenha,
      showContent: false,
      validator: (value) {
        if (!_isEditMode && (value == null || value.trim().isEmpty)) {
          return 'Senha é obrigatória';
        }
        return null;
      },
    );
    telefoneForm = AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.phone_outlined, color: ConvertixColors.primary),
      hint: 'Telefone (opcional)',
      textInputFormatter: AppFormFormatters.phoneFormatter,
    );

    nomeEmpresaForm.controller.text = widget.cliente.nomeEmpresa ?? '';
    documentoForm.controller.text = formataDocumento(widget.cliente.documento ?? '');
    emailForm.controller.text = widget.cliente.email ?? '';
    telefoneForm.controller.text = widget.cliente.telefone ?? '';
  }

  AppFormField _buildField({
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final senha = senhaForm.value.trim();
    final cliente = ClienteModel(
      id: widget.cliente.id,
      nomeEmpresa: nomeEmpresaForm.value.trim(),
      documento: documentoForm.value.trim(),
      email: emailForm.value.trim(),
      senha: senha.isEmpty ? null : senha,
      telefone: telefoneForm.value.trim(),
    );

    bloc.add(ClientesSaveEvent(cliente: cliente, foto: _novaFoto));
  }

  void _onBlocState(BuildContext context, ClientesState state) {
    if (state is ClientesSaveSuccessState) {
      showToastSuccess(message: 'Cliente salvo com sucesso');
      Navigator.pop(context, true);
    }
    if (state is ClientesSaveErrorState) {
      showToastError(message: state.errorModel.mensagem ?? 'Erro ao salvar');
    }
  }

  Widget _loadingView() {
    return appContainer(
      height: 320,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _fotoPicker() {
    return FotoPickerField(
      fotoAtual: widget.cliente.foto,
      onFotoChanged: (file) => _novaFoto = file,
    );
  }

  Widget _formFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fotoPicker(),
          appSizedBox(height: AppSpacing.normal),
          nomeEmpresaForm.formulario,
          documentoForm.formulario,
          emailForm.formulario,
          senhaForm.formulario,
          telefoneForm.formulario,
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

  Widget _formContentBody(ClientesState state) {
    if (state is ClientesSaveLoadingState) return _loadingView();
    if (widget.isDialog) return _formFields();
    return _pageLayout();
  }

  Widget _formContent() {
    return BlocConsumer<ClientesBloc, ClientesState>(
      bloc: bloc,
      listener: _onBlocState,
      buildWhen: (previous, current) =>
          (current is ClientesSaveLoadingState) !=
          (previous is ClientesSaveLoadingState),
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
      icon: _isEditMode ? Icons.edit_outlined : Icons.person_add_outlined,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _dialogScrollArea() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
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
    nomeEmpresaForm.controller.dispose();
    documentoForm.controller.dispose();
    emailForm.controller.dispose();
    senhaForm.controller.dispose();
    telefoneForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
