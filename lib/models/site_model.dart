import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/site_dominio_model.dart';

class SiteModel {
  int? id;
  int? clienteId;
  String? clienteNomeEmpresa;
  String? nome;
  String? tipo;
  String? dominio;
  String? subdominio;
  String? status;
  SiteDominioModel? dominioInfo;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool removeDominioInfo = false;

  SiteModel({
    this.id,
    this.clienteId,
    this.clienteNomeEmpresa,
    this.nome,
    this.tipo,
    this.dominio,
    this.subdominio,
    this.status,
    this.dominioInfo,
    this.createdAt,
    this.updatedAt,
    this.removeDominioInfo = false,
  });

  factory SiteModel.empty({int? clienteId}) {
    return SiteModel(
      id: null,
      clienteId: clienteId,
      nome: '',
      tipo: TipoSite.biolink,
      dominio: '',
      subdominio: '',
      status: StatusSite.ativo,
      dominioInfo: SiteDominioModel.empty(),
    );
  }

  SiteModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    clienteId = json['cliente_id'];
    clienteNomeEmpresa = json['cliente_nome_empresa'];
    nome = json['nome'];
    tipo = json['tipo'];
    dominio = json['dominio'];
    subdominio = json['subdominio'];
    status = json['status'];
    final info = json['dominio_info'];
    dominioInfo = info is Map<String, dynamic>
        ? SiteDominioModel.fromMap(info)
        : null;
    createdAt = _parseDateTime(json['created_at']);
    updatedAt = _parseDateTime(json['updated_at']);
  }

  Map<String, dynamic> toJsonCadastro() {
    final map = <String, dynamic>{
      'cliente_id': clienteId,
      'nome': nome ?? '',
      'tipo': tipo ?? TipoSite.biolink,
      'dominio': _nullableString(dominio),
      'subdominio': _nullableString(subdominio),
      'status': status ?? StatusSite.ativo,
    };

    final hasDominio = _nullableString(dominio) != null;
    if (!hasDominio || removeDominioInfo) {
      map['dominio_info'] = null;
    } else if (dominioInfo != null && dominioInfo!.hasPersistedData) {
      map['dominio_info'] = dominioInfo!.toJson();
    }

    return map;
  }

  static String? _nullableString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  static String labelTipo(String? tipo) {
    switch (tipo) {
      case TipoSite.biolink:
        return 'BioLink';
      case TipoSite.landingPage:
        return 'Landing Page';
      case TipoSite.siteComercial:
        return 'Site Comercial';
      default:
        return tipo ?? '—';
    }
  }

  static String labelStatus(String? status) {
    switch (status) {
      case StatusSite.ativo:
        return 'Ativo';
      case StatusSite.inativo:
        return 'Inativo';
      case StatusSite.emDesenvolvimento:
        return 'Em desenvolvimento';
      default:
        return status ?? '—';
    }
  }
}
