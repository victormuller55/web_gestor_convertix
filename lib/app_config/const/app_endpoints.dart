const String server = 'https://api.convertix.net.br';
const String api = '$server/api/v1';

String fotoUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '$server$path';
}

class AppEndpoints {
  // Auth
  static String endpointAuthLogin = '$api/auth/login';

  // Usuários (ADMIN)
  static String endpointUsuarios = '$api/usuarios';
  static String endpointUsuariosNovo = '$api/usuarios/novo';
  static String endpointUsuariosAlterar = '$api/usuarios/alterar-dados';
  static String endpointUsuariosApagar = '$api/usuarios/apagar';

  // Clientes (ADMIN)
  static String endpointClientes = '$api/clientes';
  static String endpointClientesNovo = '$api/clientes/novo';
  static String endpointClientesAlterar = '$api/clientes/alterar-dados';
  static String endpointClientesApagar = '$api/clientes/apagar';

  // Sites
  static String endpointSites = '$api/sites';
  static String endpointSitesNovo = '$api/sites/novo';
  static String endpointSitesAlterar = '$api/sites/alterar-dados';
  static String endpointSitesApagar = '$api/sites/apagar';

  // BioLinks
  static String endpointBioLinks = '$api/biolinks';
  static String endpointBioLinksNovo = '$api/biolinks/novo';
  static String endpointBioLinksAlterar = '$api/biolinks/alterar-dados';
  static String endpointBioLinksApagar = '$api/biolinks/apagar';

  // Itens de BioLink
  static String endpointBioLinkItens = '$api/biolinks/itens';
  static String endpointBioLinkItensNovo = '$api/biolinks/itens/novo';
  static String endpointBioLinkItensAlterar = '$api/biolinks/itens/alterar-dados';
  static String endpointBioLinkItensApagar = '$api/biolinks/itens/apagar';
}
