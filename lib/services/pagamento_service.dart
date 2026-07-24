import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';

Future<AppResponse> getPagamentos({
  String? status,
  String? formaPagamento,
  String? dataInicio,
  String? dataFim,
  int page = 0,
  int size = 20,
}) async {
  final params = <String, String>{
    'page': page.toString(),
    'size': size.toString(),
  };
  if (status != null && status.isNotEmpty) params['status'] = status;
  if (formaPagamento != null && formaPagamento.isNotEmpty) {
    params['forma_pagamento'] = formaPagamento;
  }
  if (dataInicio != null && dataInicio.isNotEmpty) {
    params['data_inicio'] = dataInicio;
  }
  if (dataFim != null && dataFim.isNotEmpty) params['data_fim'] = dataFim;

  return getJson(endpoint: AppEndpoints.endpointPagamentos, parameters: params);
}

Future<AppResponse> getPagamentosUltimos() async {
  return getJson(endpoint: AppEndpoints.endpointPagamentosUltimos);
}

Future<AppResponse> getPagamentosHistorico() async {
  return getJson(endpoint: AppEndpoints.endpointPagamentosHistorico);
}

Future<AppResponse> getPagamentoById(int id) async {
  return getJson(endpoint: AppEndpoints.endpointPagamentoById(id));
}

Future<AppResponse> getPagamentoStatus(int id) async {
  return getJson(endpoint: AppEndpoints.endpointPagamentoStatus(id));
}

Future<AppResponse> postPagamento(Map<String, dynamic> body) async {
  return postJson(endpoint: AppEndpoints.endpointPagamentos, body: body);
}

Future<AppResponse> postPagamentoPix(Map<String, dynamic> body) async {
  return postJson(endpoint: AppEndpoints.endpointPagamentosPix, body: body);
}

Future<AppResponse> postPagamentoCartao(Map<String, dynamic> body) async {
  return postJson(endpoint: AppEndpoints.endpointPagamentosCartao, body: body);
}

Future<AppResponse> postPagamentoCancelar(int id) async {
  return postJson(
    endpoint: AppEndpoints.endpointPagamentoCancelar(id),
    body: const {},
  );
}

Future<AppResponse> postPagamentoEstornar(
  int id, {
  double? valor,
  String? descricao,
}) async {
  final body = <String, dynamic>{};
  if (valor != null) body['valor'] = valor;
  if (descricao != null && descricao.isNotEmpty) body['descricao'] = descricao;
  return postJson(
    endpoint: AppEndpoints.endpointPagamentoEstornar(id),
    body: body,
  );
}
