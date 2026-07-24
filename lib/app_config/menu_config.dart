import 'package:flutter/material.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/inicio/inicio_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_page.dart';

typedef MenuPageBuilder = Widget Function();

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final MenuPageBuilder pageBuilder;
  final List<String> tiposPermitidos;
  final List<String>? requerSiteTiposCliente;

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.pageBuilder,
    this.tiposPermitidos = const [],
    this.requerSiteTiposCliente,
  });

  bool temPermissao(String? tipo, {Set<String> tiposSiteCliente = const {}}) {
    if (tipo == null || tipo.isEmpty) return false;
    if (tiposPermitidos.isEmpty) return true;
    if (tipo == TipoUsuario.admin) {
      return tiposPermitidos.contains(tipo);
    }
    if (tipo != TipoUsuario.cliente) return false;
    final permitidoPorTipo = tiposPermitidos.contains(tipo);
    if (!permitidoPorTipo) {
      if (requerSiteTiposCliente == null) return false;
      return requerSiteTiposCliente!.any(tiposSiteCliente.contains);
    }
    if (requerSiteTiposCliente != null) {
      return requerSiteTiposCliente!.any(tiposSiteCliente.contains);
    }
    return true;
  }
}

class MenuConfig {
  static final List<MenuItem> todosOsItens = [
    MenuItem(
      id: 'inicio',
      title: 'Início',
      icon: Icons.home_outlined,
      pageBuilder: () => const InicioPage(),
    ),
    MenuItem(
      id: 'usuarios',
      title: 'Usuários',
      icon: Icons.admin_panel_settings_outlined,
      pageBuilder: () => const UsuariosPage(),
      tiposPermitidos: const [TipoUsuario.admin],
    ),
    MenuItem(
      id: 'clientes',
      title: 'Clientes',
      icon: Icons.business_outlined,
      pageBuilder: () => const ClientesPage(),
      tiposPermitidos: const [TipoUsuario.admin],
    ),
    MenuItem(
      id: 'sites',
      title: 'Sites',
      icon: Icons.language_outlined,
      pageBuilder: () => const SitesPage(),
      tiposPermitidos: const [TipoUsuario.admin],
    ),
    MenuItem(
      id: 'biolinks',
      title: 'BioLinks',
      icon: Icons.link_outlined,
      pageBuilder: () => const BioLinksPage(),
      tiposPermitidos: const [TipoUsuario.admin],
    ),
    MenuItem(
      id: 'biolink',
      title: 'BioLink',
      icon: Icons.link_outlined,
      pageBuilder: () => const BioLinksPage(tituloPagina: 'BioLink'),
      tiposPermitidos: const [TipoUsuario.cliente],
    ),
    MenuItem(
      id: 'financeiro',
      title: 'Financeiro',
      icon: Icons.account_balance_wallet_outlined,
      pageBuilder: () => const FinanceiroPage(),
      tiposPermitidos: const [TipoUsuario.admin, TipoUsuario.cliente],
    ),
    MenuItem(
      id: 'pagamentos',
      title: 'Pagamentos e Faturas',
      icon: Icons.receipt_long_outlined,
      pageBuilder: () => const PagamentosPage(hideBackIcon: true),
      tiposPermitidos: const [TipoUsuario.admin, TipoUsuario.cliente],
    ),
    MenuItem(
      id: 'assinaturas',
      title: 'Assinaturas',
      icon: Icons.autorenew_outlined,
      pageBuilder: () => const AssinaturasPage(hideBackIcon: true),
      tiposPermitidos: const [TipoUsuario.admin, TipoUsuario.cliente],
    ),
  ];

  static List<MenuItem> getItensParaUsuario(
    String? tipo, {
    Set<String> tiposSiteCliente = const {},
  }) {
    return todosOsItens
        .where((item) => item.temPermissao(tipo, tiposSiteCliente: tiposSiteCliente))
        .toList();
  }

  static MenuItem? getItemPorId(String id) {
    try {
      return todosOsItens.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}
