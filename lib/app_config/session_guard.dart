import 'package:flutter/cupertino.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_page.dart';

bool _logoutEmAndamento = false;

/// Em 401 autenticado: limpa o token e redireciona para o login.
Future<void> forceLogoutOnUnauthorized() async {
  if (_logoutEmAndamento) return;
  _logoutEmAndamento = true;
  try {
    final tinhaSessao = await hasTokenSalvo();
    if (!tinhaSessao) return;

    await clearToken();

    final navigator = AppContext.navigatorKey.currentState;
    if (navigator == null) return;

    await navigator.pushAndRemoveUntil(
      CupertinoPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
  } finally {
    _logoutEmAndamento = false;
  }
}
