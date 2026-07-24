import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';

abstract class UsuariosEvent {}

class UsuariosLoadEvent extends UsuariosEvent {
  final String? query;
  final int page;
  final int size;

  UsuariosLoadEvent({
    this.query,
    this.page = 0,
    this.size = PageResponse.defaultSize,
  });
}

class UsuariosSaveEvent extends UsuariosEvent {
  final UsuarioModel usuario;
  final XFile? foto;
  UsuariosSaveEvent({required this.usuario, this.foto});
}

class UsuariosDeleteEvent extends UsuariosEvent {
  final int usuarioId;
  UsuariosDeleteEvent({required this.usuarioId});
}
