import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';

abstract class UsuariosEvent {}

class UsuariosLoadEvent extends UsuariosEvent {
  final bool forceRefresh;
  UsuariosLoadEvent({this.forceRefresh = false});
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
