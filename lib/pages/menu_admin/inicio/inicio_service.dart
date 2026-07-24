import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/dashboard_stats_model.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_service.dart';

Future<DashboardStatsModel> carregarDashboardStats() async {
  final isAdmin = await isAdminLogado();

  final sitesFuture = listarSites(size: PageResponse.maxSize);
  final biolinksFuture = listarBioLinks(size: PageResponse.maxSize);
  final clientesFuture = isAdmin
      ? listarClientes(size: PageResponse.maxSize)
      : Future.value(const PageResponse<ClienteModel>());
  final usuariosFuture = isAdmin
      ? listarUsuariosAdmin(size: PageResponse.maxSize)
      : Future.value(const PageResponse<UsuarioModel>());

  final sitesPage = await sitesFuture;
  final biolinksPage = await biolinksFuture;
  final clientesPage = await clientesFuture;
  final usuariosPage = await usuariosFuture;

  final sites = sitesPage.content;
  return DashboardStatsModel(
    totalSites: sitesPage.totalElements,
    sitesAtivos: sites.where((s) => s.status == StatusSite.ativo).length,
    sitesBioLink: sites.where((s) => s.tipo == TipoSite.biolink).length,
    totalBioLinks: biolinksPage.totalElements,
    totalClientes: clientesPage.totalElements,
    totalUsuarios: usuariosPage.totalElements,
  );
}
