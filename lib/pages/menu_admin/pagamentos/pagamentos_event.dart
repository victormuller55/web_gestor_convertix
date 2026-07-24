import 'package:web_gestor_site_covertix/models/page_response.dart';

abstract class PagamentosEvent {}

class PagamentosLoadEvent extends PagamentosEvent {
  final int page;
  final int size;

  PagamentosLoadEvent({
    this.page = 0,
    this.size = PageResponse.defaultSize,
  });
}

class PagamentosCancelarEvent extends PagamentosEvent {
  final int pagamentoId;
  PagamentosCancelarEvent({required this.pagamentoId});
}

class PagamentosEstornarEvent extends PagamentosEvent {
  final int pagamentoId;
  final double? valor;
  final String? descricao;

  PagamentosEstornarEvent({
    required this.pagamentoId,
    this.valor,
    this.descricao,
  });
}

class PagamentosCriarEvent extends PagamentosEvent {
  final double valor;
  final String descricao;
  final int? clienteId;
  final int? siteId;
  final String? dataVencimento;
  final String? externalReference;

  PagamentosCriarEvent({
    required this.valor,
    required this.descricao,
    this.clienteId,
    this.siteId,
    this.dataVencimento,
    this.externalReference,
  });
}

class PagamentosSincronizarStatusEvent extends PagamentosEvent {
  final int pagamentoId;
  PagamentosSincronizarStatusEvent({required this.pagamentoId});
}

class PagamentosDetalheEvent extends PagamentosEvent {
  final int pagamentoId;
  PagamentosDetalheEvent({required this.pagamentoId});
}
