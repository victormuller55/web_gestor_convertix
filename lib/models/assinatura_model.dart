import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';

class AssinaturaModel {
  int? id;
  int? clienteId;
  String? clienteNomeEmpresa;
  int? siteId;
  String? siteNome;
  String? siteTipo;
  String? asaasSubscriptionId;
  double? valor;
  String? descricao;
  String? ciclo;
  String? formaPagamento;
  String? status;
  DateTime? proximaCobranca;
  String? mensagemAsaas;
  String? externalReference;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<PagamentoModel> cobrancas;

  AssinaturaModel({
    this.id,
    this.clienteId,
    this.clienteNomeEmpresa,
    this.siteId,
    this.siteNome,
    this.siteTipo,
    this.asaasSubscriptionId,
    this.valor,
    this.descricao,
    this.ciclo,
    this.formaPagamento,
    this.status,
    this.proximaCobranca,
    this.mensagemAsaas,
    this.externalReference,
    this.createdAt,
    this.updatedAt,
    this.cobrancas = const [],
  });

  factory AssinaturaModel.empty() => AssinaturaModel();

  AssinaturaModel.fromMap(Map<String, dynamic> json) : cobrancas = const [] {
    id = json['id'];
    clienteId = json['cliente_id'];
    clienteNomeEmpresa = json['cliente_nome_empresa']?.toString();
    siteId = json['site_id'];
    siteNome = json['site_nome']?.toString();
    siteTipo = json['site_tipo']?.toString();
    asaasSubscriptionId = json['asaas_subscription_id']?.toString();
    valor = _parseDouble(json['valor']);
    descricao = json['descricao']?.toString();
    ciclo = json['ciclo']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    status = json['status']?.toString();
    proximaCobranca = parseApiDateTime(json['proxima_cobranca']);
    mensagemAsaas = json['mensagem_asaas']?.toString();
    externalReference = json['external_reference']?.toString();
    createdAt = parseApiDateTime(json['created_at']);
    updatedAt = parseApiDateTime(json['updated_at']);
    final raw = json['cobrancas'];
    if (raw is List) {
      cobrancas = raw
          .whereType<Map>()
          .map((e) => PagamentoModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Map<String, dynamic> toJsonCreate({
    Map<String, dynamic>? creditCard,
    Map<String, dynamic>? creditCardHolderInfo,
    String? creditCardToken,
  }) {
    final body = <String, dynamic>{
      if (clienteId != null) 'cliente_id': clienteId,
      if (siteId != null) 'site_id': siteId,
      'valor': valor,
      'descricao': descricao ?? '',
      'ciclo': ciclo,
      'forma_pagamento': formaPagamento,
      if (proximaCobranca != null)
        'proxima_cobranca': _formatApiDate(proximaCobranca!),
      if (externalReference != null && externalReference!.isNotEmpty)
        'external_reference': externalReference,
    };

    if (creditCardToken != null && creditCardToken.isNotEmpty) {
      body['credit_card_token'] = creditCardToken;
    } else {
      if (creditCard != null) body['credit_card'] = creditCard;
      if (creditCardHolderInfo != null) {
        body['credit_card_holder_info'] = creditCardHolderInfo;
      }
    }
    return body;
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

String _formatApiDate(DateTime date) {
  final y = date.year;
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}
