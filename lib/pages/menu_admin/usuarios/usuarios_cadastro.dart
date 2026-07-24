import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/foto_picker_field.dart';

class UsuariosCadastro extends StatefulWidget {
  final UsuarioModel usuario;
  final bool isDialog;

  const UsuariosCadastro({
    super.key,
    required this.usuario,
    this.isDialog = false,
  });

  @override
  State<UsuariosCadastro> createState() => _UsuariosCadastroState();
}

class _UsuariosCadastroState extends State<UsuariosCadastro> {
  final UsuariosBloc bloc = UsuariosBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.usuario.id != null && widget.usuario.id! > 0;

  late final AppFormField nomeForm;
  late final AppFormField emailForm;
  late final AppFormField senhaForm;
  bool _ativo = true;
  XFile? _novaFoto;

  double get _fieldWidth => widget.isDialog ? double.infinity : 400;

  String get _formTitle => _isEditMode ? 'Editar usuário' : 'Novo usuário admin';

  @override
  void initState() {
    super.initState();
    _ativo = widget.usuario.ativo ?? true;
    _initForms();
  }

  void _initForms() {
    nomeForm = _buildField(
      hint: AppStrings.digiteSeuNome,
      icon: Icons.person_outline,
      validator: (v) => validateNotEmpty(v, AppStrings.nome),
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
      backgroundColor: ConvertixColors.inputFill,
      icon: const Icon(Icons.lock_outline, color: ConvertixColors.primary),
      hint: _isEditMode
          ? 'Nova senha (opcional, mín. 8 caracteres)'
          : 'Senha (mín. 8 caracteres)',
      showContent: false,
      validator: (value) => validateSenha(value, required: !_isEditMode),
    );

    nomeForm.controller.text = widget.usuario.nome ?? '';
    emailForm.controller.text = widget.usuario.email ?? '';
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
      backgroundColor: ConvertixColors.inputFill,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final senha = senhaForm.value.trim();
    final usuario = UsuarioModel(
      id: widget.usuario.id,
      nome: nomeForm.value.trim(),
      email: emailForm.value.trim(),
      senha: senha.isEmpty ? null : senha,
      ativo: _ativo,
      tipo: widget.usuario.tipo ?? 'ADMIN',
    );

    bloc.add(UsuariosSaveEvent(usuario: usuario, foto: _novaFoto));
  }

  void _onBlocState(BuildContext context, UsuariosState state) {
    if (state is UsuariosSaveSuccessState) {
      showToastSuccess(message: 'Usuário salvo com sucesso');
      Navigator.pop(context, true);
    }
    if (state is UsuariosSaveErrorState) {
      showToastError(message: state.errorModel.mensagem ?? 'Erro ao salvar');
    }
  }

  Widget _loadingView() {
    return appContainer(
      height: 280,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _ativoSwitch() {
    return StatefulBuilder(
      builder: (context, setSwitchState) {
        return Row(
          children: [
            Switch(
              value: _ativo,
              activeTrackColor: ConvertixColors.primaryLight,
              thumbColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.selected)
                    ? ConvertixColors.primary
                    : null,
              ),
              onChanged: (value) => setSwitchState(() => _ativo = value),
            ),
            appText(
              _ativo ? 'Usuário ativo' : 'Usuário inativo',
              color: ConvertixColors.textSecondary,
            ),
          ],
        );
      },
    );
  }

  Widget _fotoPicker() {
    return FotoPickerField(
      fotoAtual: widget.usuario.foto,
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
          nomeForm.formulario,
          emailForm.formulario,
          senhaForm.formulario,
          appSizedBox(height: AppSpacing.normal),
          _ativoSwitch(),
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

  Widget _formContentBody(UsuariosState state) {
    if (state is UsuariosSaveLoadingState) return _loadingView();
    if (widget.isDialog) return _formFields();
    return _pageLayout();
  }

  Widget _formContent() {
    return BlocConsumer<UsuariosBloc, UsuariosState>(
      bloc: bloc,
      listener: _onBlocState,
      buildWhen: (previous, current) =>
          (current is UsuariosSaveLoadingState) !=
          (previous is UsuariosSaveLoadingState),
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
      icon: _isEditMode
          ? Icons.admin_panel_settings_outlined
          : Icons.person_add_alt_1_outlined,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _dialogScrollArea() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 420),
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
      title: _isEditMode ? 'Editar usuário' : 'Novo usuário',
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
    nomeForm.controller.dispose();
    emailForm.controller.dispose();
    senhaForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
