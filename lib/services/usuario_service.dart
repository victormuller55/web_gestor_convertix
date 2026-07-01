import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> getUsuarios({
  int? id,
  String? query,
  bool? ativo,
}) async {
  return getHTTP(
    endpoint: AppEndpoints.endpointUsuarios,
    parameters: _queryParams(id: id, query: query, ativo: ativo),
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postUsuarioNovo(Map<String, dynamic> body) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointUsuariosNovo,
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> putUsuarioAlterar(int id, Map<String, dynamic> body) async {
  return putHTTP(
    endpoint: AppEndpoints.endpointUsuariosAlterar,
    parameters: {'id': id.toString()},
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> deleteUsuario(int id) async {
  return deleteHTTP(
    endpoint: AppEndpoints.endpointUsuariosApagar,
    parameters: {'id': id.toString()},
    headers: await getAuthHeaders(),
  );
}

Map<String, String>? _queryParams({int? id, String? query, bool? ativo}) {
  final params = <String, String>{};
  if (id != null) params['id'] = id.toString();
  if (query != null && query.isNotEmpty) params['query'] = query;
  if (ativo != null) params['ativo'] = ativo.toString();
  return params.isEmpty ? null : params;
}
