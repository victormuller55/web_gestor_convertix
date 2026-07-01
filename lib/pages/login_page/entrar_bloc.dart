import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/function/api_error.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_event.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_service.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_state.dart';
import 'package:web_gestor_site_covertix/pages/menu.dart';

class EntrarBloc extends Bloc<EntrarEvent, EntrarState> {
  EntrarBloc() : super(EntrarInitialState()) {
    on<EntrarLoginEvent>((event, emit) async {
      emit(EntrarLoadingState());
      try {
        final response = await login(event.email, event.senha);
        final usuarioModel = UsuarioModel.fromMap(jsonDecode(response.body));
        if (usuarioModel.token != null && usuarioModel.token!.isNotEmpty) {
          await saveToken(usuarioModel.token!);
          await saveUsuarioLogado(usuarioModel);
        }
        showToastSuccess(message: AppStrings.loginEfetuadoComSucesso);
        emit(EntrarSuccessState(usuarioModel: usuarioModel));
        open(screen: const HomePage(), closePrevious: true);
      } catch (e) {
        emit(EntrarErrorState(errorModel: errorModelFromException(e)));
      }
    });
  }
}
