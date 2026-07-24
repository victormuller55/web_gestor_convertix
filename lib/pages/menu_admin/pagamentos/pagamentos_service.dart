import 'dart:convert';

import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_service.dart';
import 'package:web_gestor_site_covertix/services/pagamento_service.dart';

Future<PagamentoPageModel> listarHistoricoPagamentos({
  int page = 0,
  int size = 30,
}) async {
  final response = await getPagamentosHistorico(page: page, size: size);
  return PagamentoPageModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoPageModel> listarPagamentos({
  String? status,
  String? formaPagamento,
  String? dataInicio,
  String? dataFim,
  int page = 0,
  int size = 20,
}) async {
  final response = await getPagamentos(
    status: status,
    formaPagamento: formaPagamento,
    dataInicio: dataInicio,
    dataFim: dataFim,
    page: page,
    size: size,
  );
  return PagamentoPageModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoModel> obterPagamento(int id) async {
  final response = await getPagamentoById(id);
  return PagamentoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoModel> sincronizarStatusPagamento(int id) async {
  final response = await getPagamentoStatus(id);
  await invalidarCacheFinanceiro();
  return PagamentoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoModel> criarPagamento({
  required double valor,
  required String descricao,
  int? clienteId,
  int? siteId,
  String? dataVencimento,
  String? externalReference,
}) async {
  final body = <String, dynamic>{
    'valor': valor,
    'descricao': descricao,
    if (clienteId != null) 'cliente_id': clienteId,
    if (siteId != null) 'site_id': siteId,
    if (dataVencimento != null && dataVencimento.isNotEmpty)
      'data_vencimento': dataVencimento,
    if (externalReference != null && externalReference.isNotEmpty)
      'external_reference': externalReference,
  };
  final response = await postPagamento(body);
  await invalidarCacheFinanceiro();
  return PagamentoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoModel> cancelarPagamento(int id) async {
  final response = await postPagamentoCancelar(id);
  await invalidarCacheFinanceiro();
  return PagamentoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<PagamentoModel> estornarPagamento(
  int id, {
  double? valor,
  String? descricao,
}) async {
  final response = await postPagamentoEstornar(
    id,
    valor: valor,
    descricao: descricao,
  );
  await invalidarCacheFinanceiro();
  return PagamentoModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}
