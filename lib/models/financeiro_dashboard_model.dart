import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';


class FinanceiroDashboardModel {
  double totalPago;
  double totalPendente;
  int quantidadePagamentos;
  int quantidadePendentes;
  PagamentoResumoModel? ultimoPagamento;
  DateTime? proximaCobranca;
  bool assinaturaAtiva;
  double? valorAssinatura;
  String? metodoPagamentoAssinatura;
  String? descricaoAssinatura;
  String? statusUltimoPagamento;

  FinanceiroDashboardModel({
    this.totalPago = 0,
    this.totalPendente = 0,
    this.quantidadePagamentos = 0,
    this.quantidadePendentes = 0,
    this.ultimoPagamento,
    this.proximaCobranca,
    this.assinaturaAtiva = false,
    this.valorAssinatura,
    this.metodoPagamentoAssinatura,
    this.descricaoAssinatura,
    this.statusUltimoPagamento,
  });

  static final empty = FinanceiroDashboardModel();

  factory FinanceiroDashboardModel.fromMap(Map<String, dynamic> json) {
    PagamentoResumoModel? ultimo;
    final rawUltimo = json['ultimo_pagamento'];
    if (rawUltimo is Map) {
      ultimo = PagamentoResumoModel.fromMap(Map<String, dynamic>.from(rawUltimo));
    }

    return FinanceiroDashboardModel(
      totalPago: _parseDouble(json['total_pago']) ?? 0,
      totalPendente: _parseDouble(json['total_pendente']) ?? 0,
      quantidadePagamentos: json['quantidade_pagamentos'] ?? 0,
      quantidadePendentes: json['quantidade_pendentes'] ?? 0,
      ultimoPagamento: ultimo,
      proximaCobranca: parseApiDateTime(json['proxima_cobranca']),
      assinaturaAtiva: json['assinatura_ativa'] == true,
      valorAssinatura: _parseDouble(json['valor_assinatura']),
      metodoPagamentoAssinatura: json['metodo_pagamento_assinatura']?.toString(),
      descricaoAssinatura: json['descricao_assinatura']?.toString(),
      statusUltimoPagamento: json['status_ultimo_pagamento']?.toString(),
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return double.tryParse(value.toString());
}

