import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_bloc.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_event.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_logo.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final EntrarBloc bloc = EntrarBloc();
  final _formKey = GlobalKey<FormState>();

  late final AppFormField _loginForm;
  late final AppFormField _passwordForm;

  void _save() {
    if (_formKey.currentState!.validate()) {
      bloc.add(EntrarLoginEvent(_loginForm.value, _passwordForm.value));
    }
  }

  @override
  void initState() {
    super.initState();
    _loginForm = AppFormField(
      context: context,
      width: 360,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      icon: const Icon(Icons.email_outlined, color: ConvertixColors.textMuted),
      backgroundColor: ConvertixColors.surface,
      hintColor: ConvertixColors.textMuted,
      inputColor: ConvertixColors.textPrimary,
      hint: AppStrings.digiteSeuEmail,
      validator: validateEmail,
    );

    _passwordForm = AppFormField(
      context: context,
      width: 360,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      icon: const Icon(Icons.lock_outline, color: ConvertixColors.textMuted),
      backgroundColor: ConvertixColors.surface,
      hintColor: ConvertixColors.textMuted,
      inputColor: ConvertixColors.textPrimary,
      hint: AppStrings.digiteSuaSenha,
      showContent: false,
      validator: validateSenhaLogin,
    );
  }

  Widget _formHeader() {
    return Column(
      children: [
        appLogoConvertix(height: 56, alignment: Alignment.center),
        appSizedBox(height: AppSpacing.big),
        appText(
          'Use suas credenciais para acessar o gestor web',
          color: ConvertixColors.textSecondary,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.big),
      ],
    );
  }

  Widget _loginErrorBanner(ErrorModel error) {
    return appContainer(
      width: 360,
      padding: EdgeInsets.all(AppSpacing.normal),
      margin: EdgeInsets.only(bottom: AppSpacing.medium),
      backgroundColor: ConvertixColors.errorBackground,
      radius: BorderRadius.circular(AppTheme.radiusInput),
      border: Border.all(color: ConvertixColors.error.withValues(alpha: 0.3)),
      child: appText(
        error.mensagem!,
        textAlign: TextAlign.center,
        color: ConvertixColors.error,
      ),
    );
  }

  Widget _loginFields() {
    return Column(
      children: [
        _loginForm.formulario,
        _passwordForm.formulario,
      ],
    );
  }

  Widget _loginButtons() {
    return Column(
      children: [
        appSizedBox(height: AppSpacing.medium),
        appElevatedButtonCovertix(title: AppStrings.entrar, onTap: _save, width: 360, height: 48),
        appSizedBox(height: AppSpacing.normal),
        appElevatedButtonCovertix(
          title: 'Não tenho conta',
          onTap: () => openExternalLink('https://convertix.net.br/pages/home.html#planos'),
          width: 360,
          height: 48,
          invertedStyle: true,
        ),
      ],
    );
  }

  Widget _loginFooter() {
    return Column(
      children: [
        appSizedBox(height: AppSpacing.big),
        appText(
          '© Convertix ${DateTime.now().year}',
          color: ConvertixColors.textMuted,
          fontSize: AppFontSizes.verySmall,
        ),
      ],
    );
  }

  Widget _formularioLogin({ErrorModel? error}) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _formHeader(),
          if (error != null && error.mensagem!.isNotEmpty) _loginErrorBanner(error),
          _loginFields(),
          _loginButtons(),
          _loginFooter(),
        ],
      ),
    );
  }

  Widget _loginCard() {
    return appContainer(
      constraints: const BoxConstraints(maxWidth: 440),
      width: double.infinity,
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusCard + 4),
      border: Border.all(color: AppColors.white.withValues(alpha: 0.65), width: 1.5),
      shadow: BoxShadow(
        color: AppColors.grey900.withValues(alpha: 0.22),
        blurRadius: 48,
        offset: const Offset(0, 20),
      ),
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.giant, vertical: AppSpacing.giant),
      child: _bodyBuilder(),
    );
  }

  Widget _loading() {
    return appContainer(
      height: 320,
      child: appLoading(
        child: CircularProgressIndicator(color: ConvertixColors.primary, strokeWidth: 2.5),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<EntrarBloc, EntrarState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is EntrarLoadingState) {
          return _loading();
        }
        return _formularioLogin(error: state.errorModel);
      },
    );
  }

  Widget _loginBackground({required Widget child}) {
    return appContainer(
      width: double.infinity,
      height: double.infinity,
      gradient: ConvertixColors.loginPanelGradient,
      child: Center(
        child: SingleChildScrollView(padding: EdgeInsets.all(AppSpacing.medium), child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: AppStrings.vazio,
      showAppBar: false,
      background: ConvertixColors.primaryDarker,
      body: _loginBackground(child: _loginCard()),
    );
  }

  @override
  void dispose() {
    _loginForm.controller.dispose();
    _passwordForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
