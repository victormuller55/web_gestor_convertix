import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_state.dart';

class PagamentosBloc extends Bloc<PagamentosEvent, PagamentosState> {
  PagamentosBloc() : super(PagamentosInitialState()) {
    on<PagamentosLoadEvent>((event, emit) async {
      emit(PagamentosLoadingState());
      try {
        final page = await listarHistoricoPagamentos(
          page: event.page,
          size: event.size,
        );
        emit(PagamentosSuccessState(
          page: PagamentoPageModel(
            content: _ordenarPagamentos(page.content),
            page: page.page,
            size: page.size,
            totalElements: page.totalElements,
            totalPages: page.totalPages,
          ),
        ));
      } catch (e) {
        emit(PagamentosErrorState(errorModel: parseApiError(e)));
      }
    });

    on<PagamentosCriarEvent>((event, emit) async {
      emit(PagamentosSaveLoadingState());
      try {
        final pagamento = await criarPagamento(
          valor: event.valor,
          descricao: event.descricao,
          clienteId: event.clienteId,
          siteId: event.siteId,
          dataVencimento: event.dataVencimento,
          externalReference: event.externalReference,
        );
        emit(PagamentosSaveSuccessState(pagamento: pagamento));
      } catch (e) {
        emit(PagamentosSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<PagamentosCancelarEvent>((event, emit) async {
      emit(PagamentosLoadingState());
      try {
        final pagamento = await cancelarPagamento(event.pagamentoId);
        emit(PagamentosActionSuccessState(
          pagamento: pagamento,
          message: 'Pagamento cancelado com sucesso',
        ));
      } catch (e) {
        emit(PagamentosErrorState(errorModel: parseApiError(e)));
      }
    });

    on<PagamentosEstornarEvent>((event, emit) async {
      emit(PagamentosLoadingState());
      try {
        final pagamento = await estornarPagamento(
          event.pagamentoId,
          valor: event.valor,
          descricao: event.descricao,
        );
        emit(PagamentosActionSuccessState(
          pagamento: pagamento,
          message: 'Estorno realizado com sucesso',
        ));
      } catch (e) {
        emit(PagamentosErrorState(errorModel: parseApiError(e)));
      }
    });

    on<PagamentosSincronizarStatusEvent>((event, emit) async {
      try {
        final pagamento = await sincronizarStatusPagamento(event.pagamentoId);
        emit(PagamentosStatusUpdatedState(pagamento: pagamento));
      } catch (e) {
        emit(PagamentosSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<PagamentosDetalheEvent>((event, emit) async {
      emit(PagamentosLoadingState());
      try {
        final pagamento = await obterPagamento(event.pagamentoId);
        emit(PagamentosDetalheSuccessState(pagamento: pagamento));
      } catch (e) {
        emit(PagamentosErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}

/// Vencimento mais longe primeiro; recebidos/confirmados sempre por último.
List<PagamentoModel> _ordenarPagamentos(List<PagamentoModel> pagamentos) {
  final ordenados = List<PagamentoModel>.from(pagamentos);
  ordenados.sort((a, b) {
    final aRecebido = StatusPagamento.isPago(a.status);
    final bRecebido = StatusPagamento.isPago(b.status);
    if (aRecebido != bRecebido) {
      return aRecebido ? 1 : -1;
    }

    final aVenc = a.dataVencimento;
    final bVenc = b.dataVencimento;
    if (aVenc == null && bVenc == null) return 0;
    if (aVenc == null) return 1;
    if (bVenc == null) return -1;
    return bVenc.compareTo(aVenc);
  });
  return ordenados;
}
