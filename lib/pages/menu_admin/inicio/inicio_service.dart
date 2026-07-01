import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/dashboard_stats_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_service.dart';

Future<DashboardStatsModel> carregarDashboardStats({bool forceRefresh = false}) async {
  final isAdmin = await isAdminLogado();

  final sitesFuture = listarSites(forceRefresh: forceRefresh);
  final biolinksFuture = listarBioLinks(forceRefresh: forceRefresh);
  final clientesFuture = isAdmin ? listarClientes(forceRefresh: forceRefresh) : Future.value([]);
  final usuariosFuture = isAdmin ? listarUsuariosAdmin(forceRefresh: forceRefresh) : Future.value([]);

  final results = await Future.wait([sitesFuture, biolinksFuture, clientesFuture, usuariosFuture]);

  final sites = results[0];
  final biolinks = results[1];
  final clientes = results[2];
  final usuarios = results[3];

  return DashboardStatsModel(
    totalSites: sites.length,
    sitesAtivos: sites.where((s) => s.status == StatusSite.ativo).length,
    sitesBioLink: sites.where((s) => s.tipo == TipoSite.biolink).length,
    totalBioLinks: biolinks.length,
    totalClientes: clientes.length,
    totalUsuarios: usuarios.length,
  );
}
