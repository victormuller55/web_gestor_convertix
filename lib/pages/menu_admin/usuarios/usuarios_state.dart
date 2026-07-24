import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';

abstract class UsuariosState {}

class UsuariosInitialState extends UsuariosState {}

class UsuariosLoadingState extends UsuariosState {}

class UsuariosSuccessState extends UsuariosState {
  final PageResponse<UsuarioModel> page;
  UsuariosSuccessState({required this.page});

  List<UsuarioModel> get usuarios => page.content;
}

class UsuariosErrorState extends UsuariosState {
  final ErrorModel errorModel;
  UsuariosErrorState({required this.errorModel});
}

class UsuariosSaveLoadingState extends UsuariosState {}

class UsuariosSaveSuccessState extends UsuariosState {}

class UsuariosSaveErrorState extends UsuariosState {
  final ErrorModel errorModel;
  UsuariosSaveErrorState({required this.errorModel});
}

class UsuariosDeleteSuccessState extends UsuariosState {}
