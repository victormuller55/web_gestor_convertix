import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> getClientes({
  int? id,
  String? query,
  int page = 0,
  int size = 30,
}) async {
  final params = <String, String>{
    'page': page.toString(),
    'size': size.toString(),
  };
  if (id != null) params['id'] = id.toString();
  if (query != null && query.isNotEmpty) params['query'] = query;

  return getHTTP(
    endpoint: AppEndpoints.endpointClientes,
    parameters: params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postClienteNovo(Map<String, dynamic> body) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointClientesNovo,
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> putClienteAlterar(int id, Map<String, dynamic> body) async {
  return putHTTP(
    endpoint: AppEndpoints.endpointClientesAlterar,
    parameters: {'id': id.toString()},
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> deleteCliente(int id) async {
  return deleteHTTP(
    endpoint: AppEndpoints.endpointClientesApagar,
    parameters: {'id': id.toString()},
    headers: await getAuthHeaders(),
  );
}
