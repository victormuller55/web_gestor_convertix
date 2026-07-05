import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/widgets/login/login_screen_decoration.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_page.dart';
import 'package:web_gestor_site_covertix/pages/menu.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _carregando = true;
  bool _sessaoValida = false;

  @override
  void initState() {
    super.initState();
    _verificarSessao();
  }

  Future<void> _verificarSessao() async {
    final sessaoValida = await hasSessaoValida();
    if (!mounted) return;
    setState(() {
      _sessaoValida = sessaoValida;
      _carregando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_carregando) {
      return scaffold(
        title: AppStrings.vazio,
        showAppBar: false,
        background: ConvertixColors.primaryDarker,
        body: LoginScreenBackground(
          child: appLoading(
            child: CircularProgressIndicator(
              color: ConvertixColors.primary,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return _sessaoValida ? const HomePage() : const LoginPage();
  }
}
