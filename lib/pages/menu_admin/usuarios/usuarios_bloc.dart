import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_state.dart';

class UsuariosBloc extends Bloc<UsuariosEvent, UsuariosState> {
  UsuariosBloc() : super(UsuariosInitialState()) {
    on<UsuariosLoadEvent>((event, emit) async {
      emit(UsuariosLoadingState());
      try {
        final usuarios = await listarUsuariosAdmin(forceRefresh: event.forceRefresh);
        emit(UsuariosSuccessState(usuarios: usuarios));
      } catch (e) {
        emit(UsuariosErrorState(errorModel: parseApiError(e)));
      }
    });

    on<UsuariosSaveEvent>((event, emit) async {
      emit(UsuariosSaveLoadingState());
      try {
        final usuario = event.usuario;
        if (usuario.id != null && usuario.id! > 0) {
          await alterarUsuarioAdmin(usuario.id!, usuario, foto: event.foto);
        } else {
          await criarUsuarioAdmin(usuario, foto: event.foto);
        }
        emit(UsuariosSaveSuccessState());
      } catch (e) {
        emit(UsuariosSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<UsuariosDeleteEvent>((event, emit) async {
      emit(UsuariosLoadingState());
      try {
        await excluirUsuarioAdmin(event.usuarioId);
        emit(UsuariosDeleteSuccessState());
      } catch (e) {
        emit(UsuariosErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
