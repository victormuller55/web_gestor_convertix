import 'package:web_gestor_site_covertix/function/date_format.dart';

class ClienteModel {
  int? id;
  String? nomeEmpresa;
  String? documento;
  String? email;
  String? telefone;
  String? senha;
  String? foto;
  DateTime? createdAt;
  DateTime? updatedAt;
  ClienteModel({
    this.id,
    this.nomeEmpresa,
    this.documento,
    this.email,
    this.telefone,
    this.senha,
    this.foto,
    this.createdAt,
    this.updatedAt,
  });
  factory ClienteModel.empty() {
    return ClienteModel(
      id: null,
      nomeEmpresa: '',
      documento: '',
      email: '',
      telefone: '',
      senha: '',
    );
  }
  ClienteModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    nomeEmpresa = json['nome_empresa'];
    documento = json['documento'] ?? json['cnpj'];
    email = json['email'];
    telefone = json['telefone'];
    foto = json['foto'];
    createdAt = parseApiDateTime(json['created_at']);
    updatedAt = parseApiDateTime(json['updated_at']);
  }
  Map<String, dynamic> toJsonCadastro() {
    return {
      'nome_empresa': nomeEmpresa ?? '',
      'documento': documento ?? '',
      'email': email ?? '',
      'senha': senha ?? '',
      'telefone': telefone ?? '',
    };
  }
}
