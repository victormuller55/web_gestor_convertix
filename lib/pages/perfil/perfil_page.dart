import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/api_error.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/documento_formatter.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/perfil/perfil_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/foto_picker_field.dart';

class PerfilPage extends StatefulWidget {
  final UsuarioModel usuario;

  const PerfilPage({super.key, required this.usuario});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final AppFormField nomeForm;
  late final AppFormField emailForm;
  late final AppFormField senhaForm;
  late final AppFormField nomeEmpresaForm;
  late final AppFormField documentoForm;
  late final AppFormField telefoneForm;
  late final AppFormField nomeSomenteLeituraForm;

  XFile? _novaFoto;
  final ValueNotifier<bool> _salvandoNotifier = ValueNotifier(false);

  bool get _isAdmin => widget.usuario.isAdmin;
  bool get _isCliente => widget.usuario.isCliente;

  @override
  void initState() {
    super.initState();
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
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.lock_outline, color: ConvertixColors.primary),
      hint: 'Nova senha (opcional)',
      showContent: false,
    );
    nomeEmpresaForm = _buildField(
      hint: 'Digite o nome da empresa',
      icon: Icons.business_outlined,
      validator: (v) => validateNotEmpty(v, 'Nome da empresa'),
    );
    documentoForm = AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.badge_outlined, color: ConvertixColors.primary),
      hint: 'CPF ou CNPJ',
      textInputFormatter: DocumentoInputFormatter(),
      validator: validateDocumento,
    );
    telefoneForm = AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.phone_outlined, color: ConvertixColors.primary),
      hint: 'Telefone (opcional)',
      textInputFormatter: AppFormFormatters.phoneFormatter,
    );
    nomeSomenteLeituraForm = _buildField(
      hint: AppStrings.digiteSeuNome,
      icon: Icons.person_outline,
      enabled: false,
    );

    nomeForm.controller.text = widget.usuario.nome ?? '';
    emailForm.controller.text = widget.usuario.email ?? '';
    nomeSomenteLeituraForm.controller.text = widget.usuario.nome ?? '';
    nomeEmpresaForm.controller.text = widget.usuario.nomeEmpresa ?? '';
    documentoForm.controller.text = formataDocumento(widget.usuario.documento ?? '');
    telefoneForm.controller.text = widget.usuario.telefone ?? '';
  }

  AppFormField _buildField({
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      backgroundColor: AppColors.grey100,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
      enable: enabled,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    _salvandoNotifier.value = true;

    try {
      final senha = senhaForm.value.trim();
      final dados = UsuarioModel(
        nome: nomeForm.value.trim(),
        email: emailForm.value.trim(),
        senha: senha.isEmpty ? null : senha,
        nomeEmpresa: nomeEmpresaForm.value.trim(),
        documento: documentoForm.value.trim(),
        telefone: telefoneForm.value.trim(),
      );

      await salvarPerfil(
        usuarioAtual: widget.usuario,
        dados: dados,
        foto: _novaFoto,
      );

      if (!mounted) return;
      showToastSuccess(message: 'Perfil atualizado com sucesso');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showToastError(message: errorModelFromException(e).mensagem);
    } finally {
      if (mounted) _salvandoNotifier.value = false;
    }
  }

  Widget _tipoInfoIcon() {
    return Icon(Icons.verified_user_outlined, color: ConvertixColors.primary, size: 18);
  }

  Widget _tipoInfoText(String tipo) {
    return appText(
      'Tipo de conta: $tipo',
      color: ConvertixColors.primaryDark,
      fontSize: AppFontSizes.verySmall,
    );
  }

  Widget _tipoInfo() {
    final tipo = widget.usuario.tipo ?? '—';
    return appContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      backgroundColor: ConvertixColors.primaryLight.withValues(alpha: 0.5),
      radius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(color: ConvertixColors.primary.withValues(alpha: 0.15)),
      child: Row(
        children: [
          _tipoInfoIcon(),
          appSizedBox(width: AppSpacing.normal),
          _tipoInfoText(tipo),
        ],
      ),
    );
  }

  List<Widget> _adminFields() {
    return [
      FotoPickerField(
        fotoAtual: widget.usuario.foto,
        onFotoChanged: (file) => _novaFoto = file,
      ),
      appSizedBox(height: AppSpacing.normal),
      _tipoInfo(),
      appSizedBox(height: AppSpacing.normal),
      nomeForm.formulario,
      emailForm.formulario,
      senhaForm.formulario,
    ];
  }

  List<Widget> _clienteFields() {
    return [
      FotoPickerField(
        fotoAtual: widget.usuario.foto,
        onFotoChanged: (file) => _novaFoto = file,
      ),
      appSizedBox(height: AppSpacing.normal),
      _tipoInfo(),
      appSizedBox(height: AppSpacing.normal),
      nomeSomenteLeituraForm.formulario,
      nomeEmpresaForm.formulario,
      documentoForm.formulario,
      emailForm.formulario,
      telefoneForm.formulario,
      senhaForm.formulario,
    ];
  }

  Widget _formFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_isAdmin) ..._adminFields(),
          if (_isCliente) ..._clienteFields(),
        ],
      ),
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

  Widget _savingOverlay() {
    return SizedBox(
      height: 280,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _formBody(bool salvando) {
    if (salvando) {
      return _savingOverlay();
    }
    return _formFields();
  }

  Widget _dialogHeader(bool salvando) {
    return appDialogHeader(
      title: 'Meu perfil',
      icon: Icons.person_outline,
      onClose: salvando ? null : () => Navigator.pop(context),
    );
  }

  Widget _scrollableFormSection(bool salvando) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: _isCliente ? 520 : 420),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _formBody(salvando),
      ),
    );
  }

  Widget _footerSection(bool salvando) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: salvando ? const SizedBox.shrink() : _actionButtons(),
    );
  }

  Widget _dialogContent(bool salvando) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _dialogHeader(salvando),
        _scrollableFormSection(salvando),
        _footerSection(salvando),
      ],
    );
  }

  Widget _perfilDialog() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: ValueListenableBuilder<bool>(
          valueListenable: _salvandoNotifier,
          builder: (_, salvando, __) => _dialogContent(salvando),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _perfilDialog();
  }

  @override
  void dispose() {
    _salvandoNotifier.dispose();
    nomeForm.controller.dispose();
    emailForm.controller.dispose();
    senhaForm.controller.dispose();
    nomeEmpresaForm.controller.dispose();
    documentoForm.controller.dispose();
    telefoneForm.controller.dispose();
    nomeSomenteLeituraForm.controller.dispose();
    super.dispose();
  }
}
