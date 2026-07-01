class UsuarioModel {
  int? id;
  String? nome;
  String? email;
  String? tipo;
  bool? ativo;
  int? clienteId;
  String? nomeEmpresa;
  String? documento;
  String? telefone;
  String? senha;
  String? token;
  String? foto;
  DateTime? createdAt;
  DateTime? updatedAt;
  UsuarioModel({
    this.id,
    this.nome,
    this.email,
    this.tipo,
    this.ativo,
    this.clienteId,
    this.nomeEmpresa,
    this.documento,
    this.telefone,
    this.senha,
    this.token,
    this.foto,
    this.createdAt,
    this.updatedAt,
  });
  factory UsuarioModel.empty() {
    return UsuarioModel(
      id: null,
      nome: '',
      email: '',
      tipo: null,
      ativo: null,
      clienteId: null,
      nomeEmpresa: null,
      documento: null,
      telefone: null,
      senha: null,
      token: null,
      foto: null,
      createdAt: null,
      updatedAt: null,
    );
  }
  bool get isAdmin => tipo == 'ADMIN';
  bool get isCliente => tipo == 'CLIENTE';
  UsuarioModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    nome = json['nome'];
    email = json['email'];
    tipo = json['tipo'];
    ativo = json['ativo'];
    clienteId = json['cliente_id'];
    nomeEmpresa = json['nome_empresa'];
    documento = json['documento'] ?? json['cnpj'];
    telefone = json['telefone'];
    senha = json['senha'];
    token = json['token'];
    foto = json['foto'];
    createdAt = _parseDate(json['created_at']);
    updatedAt = _parseDate(json['updated_at']);
  }
  Map<String, dynamic> toJsonCadastroAdmin() {
    return {
      'nome': nome ?? '',
      'email': email ?? '',
      'senha': senha ?? '',
      'ativo': ativo ?? true,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'tipo': tipo,
      'ativo': ativo,
      'cliente_id': clienteId,
      'nome_empresa': nomeEmpresa,
      'documento': documento,
      'telefone': telefone,
      'foto': foto,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }
}
