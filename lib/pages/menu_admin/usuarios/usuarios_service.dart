import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/services/usuario_service.dart';

Future<PageResponse<UsuarioModel>> listarUsuariosAdmin({
  String? query,
  bool? ativo,
  int page = 0,
  int size = PageResponse.defaultSize,
}) async {
  final response = await getUsuarios(
    query: query,
    ativo: ativo,
    page: page,
    size: size,
  );
  return PageResponse.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    UsuarioModel.fromMap,
  );
}

Future<List<UsuarioModel>> listarUsuariosLookup({
  String? query,
  bool? ativo,
}) async {
  final page = await listarUsuariosAdmin(
    query: query,
    ativo: ativo,
    page: 0,
    size: PageResponse.maxSize,
  );
  return page.content;
}

Future<UsuarioModel> criarUsuarioAdmin(
  UsuarioModel usuario, {
  XFile? foto,
}) async {
  final response = await postMultipart(
    endpoint: AppEndpoints.endpointUsuariosNovo,
    dados: usuario.toJsonCadastroAdmin(),
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.usuarios);
  if (response.body.isEmpty) return usuario;
  return UsuarioModel.fromMap(jsonDecode(response.body));
}

Future<UsuarioModel> alterarUsuarioAdmin(
  int id,
  UsuarioModel usuario, {
  XFile? foto,
}) async {
  final body = usuario.toJsonCadastroAdmin();
  if (body['senha'] == null || body['senha'].toString().isEmpty) {
    body.remove('senha');
  }
  final response = await putMultipart(
    endpoint: AppEndpoints.endpointUsuariosAlterar,
    parameters: {'id': id.toString()},
    dados: body,
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.usuarios);
  return UsuarioModel.fromMap(jsonDecode(response.body));
}

Future<void> excluirUsuarioAdmin(int id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointUsuariosApagar,
    parameters: {'id': id.toString()},
  );
  await PageDataCache.invalidate(CacheKeys.usuarios);
}
