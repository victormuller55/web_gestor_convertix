import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_state.dart';

class ClientesBloc extends Bloc<ClientesEvent, ClientesState> {
  ClientesBloc() : super(ClientesInitialState()) {
    on<ClientesLoadEvent>((event, emit) async {
      emit(ClientesLoadingState());
      try {
        final page = await listarClientes(
          query: event.query,
          page: event.page,
          size: event.size,
        );
        emit(ClientesSuccessState(page: page));
      } catch (e) {
        emit(ClientesErrorState(errorModel: parseApiError(e)));
      }
    });

    on<ClientesSaveEvent>((event, emit) async {
      emit(ClientesSaveLoadingState());
      try {
        final cliente = event.cliente;
        if (cliente.id != null && cliente.id! > 0) {
          await alterarCliente(cliente.id!, cliente, foto: event.foto);
        } else {
          await criarCliente(cliente, foto: event.foto);
        }
        emit(ClientesSaveSuccessState());
      } catch (e) {
        emit(ClientesSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<ClientesDeleteEvent>((event, emit) async {
      emit(ClientesLoadingState());
      try {
        await excluirCliente(event.clienteId);
        emit(ClientesDeleteSuccessState());
      } catch (e) {
        emit(ClientesErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
