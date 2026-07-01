import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';

abstract class ClientesState {}

class ClientesInitialState extends ClientesState {}

class ClientesLoadingState extends ClientesState {}

class ClientesSuccessState extends ClientesState {
  final List<ClienteModel> clientes;
  ClientesSuccessState({required this.clientes});
}

class ClientesErrorState extends ClientesState {
  final ErrorModel errorModel;
  ClientesErrorState({required this.errorModel});
}

class ClientesSaveLoadingState extends ClientesState {}

class ClientesSaveSuccessState extends ClientesState {}

class ClientesSaveErrorState extends ClientesState {
  final ErrorModel errorModel;
  ClientesSaveErrorState({required this.errorModel});
}

class ClientesDeleteSuccessState extends ClientesState {}
