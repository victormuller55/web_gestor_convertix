import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/services/cliente_service.dart';

Future<List<ClienteModel>> listarClientes({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.clientes);
    if (cached != null) {
      return cached.map(ClienteModel.fromMap).toList();
    }
  }
  final response = await getClientes();
  final list = jsonDecode(response.body) as List;
  final maps = list
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  await PageDataCache.setJsonList(CacheKeys.clientes, maps);
  return maps.map(ClienteModel.fromMap).toList();
}

Future<ClienteModel> criarCliente(ClienteModel cliente, {XFile? foto}) async {
  final response = await postMultipart(
    endpoint: AppEndpoints.endpointClientesNovo,
    dados: cliente.toJsonCadastro(),
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.clientes);
  if (response.body.isEmpty) return cliente;
  return ClienteModel.fromMap(jsonDecode(response.body));
}

Future<ClienteModel> alterarCliente(
  int id,
  ClienteModel cliente, {
  XFile? foto,
}) async {
  final body = cliente.toJsonCadastro();
  if (body['senha'] == null || body['senha'].toString().isEmpty) {
    body.remove('senha');
  }
  final response = await putMultipart(
    endpoint: AppEndpoints.endpointClientesAlterar,
    parameters: {'id': id.toString()},
    dados: body,
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.clientes);
  return ClienteModel.fromMap(jsonDecode(response.body));
}

Future<void> excluirCliente(int id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointClientesApagar,
    parameters: {'id': id.toString()},
  );
  await PageDataCache.invalidate(CacheKeys.clientes);
}
