import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_icone.dart';

class BioLinkItemModel {
  int? id;
  int? biolinkId;
  String? titulo;
  String? url;
  String? icone;
  int? ordem;
  bool? ativo;
  DateTime? createdAt;
  DateTime? updatedAt;

  BioLinkItemModel({
    this.id,
    this.biolinkId,
    this.titulo,
    this.url,
    this.icone,
    this.ordem,
    this.ativo,
    this.createdAt,
    this.updatedAt,
  });

  factory BioLinkItemModel.empty({required int biolinkId, int ordem = 1}) {
    return BioLinkItemModel(
      biolinkId: biolinkId,
      titulo: '',
      url: '',
      icone: null,
      ordem: ordem,
      ativo: true,
    );
  }

  BioLinkItemModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    biolinkId = json['biolink_id'];
    titulo = json['titulo'];
    url = json['url'];
    icone = BioLinkItemIcone.fromJson(json['icone']);
    ordem = json['ordem'];
    ativo = json['ativo'];
    createdAt = parseApiDateTime(json['created_at']);
    updatedAt = parseApiDateTime(json['updated_at']);
  }

  Map<String, dynamic> toJsonCadastro({bool includeBiolinkId = true}) {
    return {
      if (includeBiolinkId) 'biolink_id': biolinkId,
      'titulo': titulo ?? '',
      'url': url ?? '',
      'icone': _nullableString(icone),
      'ordem': ordem ?? 1,
      'ativo': ativo ?? true,
    };
  }

  static String? _nullableString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }
}
