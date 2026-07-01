class BioLinkModel {
  int? id;
  int? siteId;
  String? siteNome;
  String? nomeUsuario;
  String? descricao;
  String? fotoPerfil;
  DateTime? createdAt;
  DateTime? updatedAt;

  BioLinkModel({
    this.id,
    this.siteId,
    this.siteNome,
    this.nomeUsuario,
    this.descricao,
    this.fotoPerfil,
    this.createdAt,
    this.updatedAt,
  });

  factory BioLinkModel.empty() {
    return BioLinkModel(
      nomeUsuario: '',
      descricao: '',
      fotoPerfil: '',
    );
  }

  BioLinkModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    siteId = json['site_id'];
    siteNome = json['site_nome'];
    nomeUsuario = json['nome_usuario'];
    descricao = json['descricao'];
    fotoPerfil = json['foto_perfil'];
    createdAt = _parseDateTime(json['created_at']);
    updatedAt = _parseDateTime(json['updated_at']);
  }

  Map<String, dynamic> toJsonCadastro() {
    return {
      'site_id': siteId,
      'nome_usuario': nomeUsuario ?? '',
      'descricao': _nullableString(descricao),
    };
  }

  static String? _nullableString(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}
