import 'package:web_gestor_site_covertix/models/app_enums.dart';

class PlanoAssinatura {
  final String id;
  final String titulo;
  final String? tipoSite;
  final double? valorFixo;
  final String descricaoPadrao;
  final bool manual;

  const PlanoAssinatura({
    required this.id,
    required this.titulo,
    this.tipoSite,
    this.valorFixo,
    required this.descricaoPadrao,
    this.manual = false,
  });

  static const biolink = PlanoAssinatura(
    id: 'biolink',
    titulo: 'BioLink Profissional',
    tipoSite: TipoSite.biolink,
    valorFixo: 30,
    descricaoPadrao: 'Assinatura mensal BioLink Profissional',
  );

  static const landingPage = PlanoAssinatura(
    id: 'landing_page',
    titulo: 'Landing Page',
    tipoSite: TipoSite.landingPage,
    valorFixo: 90,
    descricaoPadrao: 'Assinatura mensal Landing Page',
  );

  static const siteInstitucional = PlanoAssinatura(
    id: 'site_institucional',
    titulo: 'Site Institucional Completo',
    tipoSite: TipoSite.siteComercial,
    valorFixo: 170,
    descricaoPadrao: 'Assinatura mensal Site Institucional Completo',
  );

  static const outro = PlanoAssinatura(
    id: 'outro',
    titulo: 'Outro valor',
    descricaoPadrao: '',
    manual: true,
  );

  static const List<PlanoAssinatura> todos = [
    biolink,
    landingPage,
    siteInstitucional,
    outro,
  ];

  static PlanoAssinatura porTipoSite(String? tipo) {
    switch (tipo) {
      case TipoSite.biolink:
        return biolink;
      case TipoSite.landingPage:
        return landingPage;
      case TipoSite.siteComercial:
        return siteInstitucional;
      default:
        return outro;
    }
  }

  String get labelValor {
    if (manual || valorFixo == null) return 'Valor manual';
    final inteiro = valorFixo == valorFixo!.roundToDouble();
    final texto = inteiro
        ? valorFixo!.toStringAsFixed(0)
        : valorFixo!.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $texto/mês';
  }
}
