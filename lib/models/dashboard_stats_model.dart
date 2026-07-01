class DashboardStatsModel {
  final int totalSites;
  final int sitesAtivos;
  final int sitesBioLink;
  final int totalBioLinks;
  final int totalClientes;
  final int totalUsuarios;

  const DashboardStatsModel({
    required this.totalSites,
    required this.sitesAtivos,
    required this.sitesBioLink,
    required this.totalBioLinks,
    required this.totalClientes,
    required this.totalUsuarios,
  });

  static const empty = DashboardStatsModel(
    totalSites: 0,
    sitesAtivos: 0,
    sitesBioLink: 0,
    totalBioLinks: 0,
    totalClientes: 0,
    totalUsuarios: 0,
  );
}
