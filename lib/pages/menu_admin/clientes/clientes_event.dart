import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';

abstract class ClientesEvent {}

class ClientesLoadEvent extends ClientesEvent {
  final bool forceRefresh;
  ClientesLoadEvent({this.forceRefresh = false});
}

class ClientesSaveEvent extends ClientesEvent {
  final ClienteModel cliente;
  final XFile? foto;
  ClientesSaveEvent({required this.cliente, this.foto});
}

class ClientesDeleteEvent extends ClientesEvent {
  final int clienteId;
  ClientesDeleteEvent({required this.clienteId});
}
