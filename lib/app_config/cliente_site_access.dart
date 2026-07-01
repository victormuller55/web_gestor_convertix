import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';

Future<Set<String>> obterTiposSiteDoCliente() async {
  try {
    final sites = await listarSites();
    return sites.map((s) => s.tipo).whereType<String>().toSet();
  } catch (_) {
    return {};
  }
}

