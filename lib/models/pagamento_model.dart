import 'package:web_gestor_site_covertix/function/date_format.dart';

class HistoricoStatusPagamentoModel {
  int? id;
  String? statusAnterior;
  String? statusNovo;
  String? origem;
  String? mensagem;
  DateTime? createdAt;

  HistoricoStatusPagamentoModel({
    this.id,
    this.statusAnterior,
    this.statusNovo,
    this.origem,
    this.mensagem,
    this.createdAt,
  });

  HistoricoStatusPagamentoModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    statusAnterior = json['status_anterior']?.toString();
    statusNovo = json['status_novo']?.toString();
    origem = json['origem']?.toString();
    mensagem = json['mensagem']?.toString();
    createdAt = parseApiDateTime(json['created_at']);
  }
}

class PagamentoResumoModel {
  int? id;
  double? valor;
  String? descricao;
  String? status;
  String? formaPagamento;
  int? parcelas;
  String? asaasPaymentId;
  String? invoiceUrl;
  String? comprovanteUrl;
  DateTime? createdAt;
  DateTime? dataConfirmacao;

  PagamentoResumoModel({
    this.id,
    this.valor,
    this.descricao,
    this.status,
    this.formaPagamento,
    this.parcelas,
    this.asaasPaymentId,
    this.invoiceUrl,
    this.comprovanteUrl,
    this.createdAt,
    this.dataConfirmacao,
  });

  PagamentoResumoModel.fromMap(Map<String, dynamic> json) {
    id = json['id'];
    valor = _parseDouble(json['valor']);
    descricao = json['descricao']?.toString();
    status = json['status']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    parcelas = json['parcelas'];
    asaasPaymentId = json['asaas_payment_id']?.toString();
    invoiceUrl = json['invoice_url']?.toString();
    comprovanteUrl = json['comprovante_url']?.toString();
    createdAt = parseApiDateTime(json['created_at']);
    dataConfirmacao = parseApiDateTime(json['data_confirmacao']);
  }
}

class PagamentoModel {
  int? id;
  int? clienteId;
  String? clienteNomeEmpresa;
  int? siteId;
  int? assinaturaId;
  String? asaasPaymentId;
  double? valor;
  String? descricao;
  String? status;
  String? formaPagamento;
  int? parcelas;
  String? qrCode;
  String? codigoPix;
  String? invoiceUrl;
  String? comprovanteUrl;
  DateTime? dataVencimento;
  DateTime? dataConfirmacao;
  String? mensagemAsaas;
  String? externalReference;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<HistoricoStatusPagamentoModel> historicoStatus;

  PagamentoModel({
    this.id,
    this.clienteId,
    this.clienteNomeEmpresa,
    this.siteId,
    this.assinaturaId,
    this.asaasPaymentId,
    this.valor,
    this.descricao,
    this.status,
    this.formaPagamento,
    this.parcelas,
    this.qrCode,
    this.codigoPix,
    this.invoiceUrl,
    this.comprovanteUrl,
    this.dataVencimento,
    this.dataConfirmacao,
    this.mensagemAsaas,
    this.externalReference,
    this.createdAt,
    this.updatedAt,
    this.historicoStatus = const [],
  });

  factory PagamentoModel.empty() => PagamentoModel();

  PagamentoModel.fromMap(Map<String, dynamic> json)
      : historicoStatus = const [] {
    id = json['id'];
    clienteId = json['cliente_id'];
    clienteNomeEmpresa = json['cliente_nome_empresa']?.toString();
    siteId = json['site_id'];
    assinaturaId = json['assinatura_id'];
    asaasPaymentId = json['asaas_payment_id']?.toString();
    valor = _parseDouble(json['valor']);
    descricao = json['descricao']?.toString();
    status = json['status']?.toString();
    formaPagamento = json['forma_pagamento']?.toString();
    parcelas = json['parcelas'];
    qrCode = json['qr_code']?.toString();
    codigoPix = json['codigo_pix']?.toString();
    invoiceUrl = json['invoice_url']?.toString();
    comprovanteUrl = json['comprovante_url']?.toString();
    dataVencimento = parseApiDateTime(json['data_vencimento']);
    dataConfirmacao = parseApiDateTime(json['data_confirmacao']);
    mensagemAsaas = json['mensagem_asaas']?.toString();
    externalReference = json['external_reference']?.toString();
    createdAt = parseApiDateTime(json['created_at']);
    updatedAt = parseApiDateTime(json['updated_at']);
    historicoStatus = _parseHistorico(json['historico_status']);
  }

  PagamentoResumoModel toResumo() {
    return PagamentoResumoModel(
      id: id,
      valor: valor,
      descricao: descricao,
      status: status,
      formaPagamento: formaPagamento,
      parcelas: parcelas,
      asaasPaymentId: asaasPaymentId,
      invoiceUrl: invoiceUrl,
      comprovanteUrl: comprovanteUrl,
      createdAt: createdAt,
      dataConfirmacao: dataConfirmacao,
    );
  }
}

class PagamentoPageModel {
  List<PagamentoModel> content;
  int page;
  int size;
  int totalElements;
  int totalPages;

  PagamentoPageModel({
    this.content = const [],
    this.page = 0,
    this.size = 30,
    this.totalElements = 0,
    this.totalPages = 0,
  });

  PagamentoPageModel.fromMap(Map<String, dynamic> json)
      : content = const [],
        page = 0,
        size = 30,
        totalElements = 0,
        totalPages = 0 {
    page = json['page'] ?? 0;
    size = json['size'] ?? 30;
    totalElements = json['total_elements'] ?? 0;
    totalPages = json['total_pages'] ?? 0;
    final raw = json['content'];
    if (raw is List) {
      content = raw
          .whereType<Map>()
          .map((e) => PagamentoModel.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

List<HistoricoStatusPagamentoModel> _parseHistorico(dynamic value) {
  if (value is! List) return const [];
  return value
      .whereType<Map>()
      .map((e) => HistoricoStatusPagamentoModel.fromMap(Map<String, dynamic>.from(e)))
      .toList();
}
