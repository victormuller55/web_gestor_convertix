import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> getSites({int? id, String? query}) async {
  final params = <String, String>{};
  if (id != null) params['id'] = id.toString();
  if (query != null && query.isNotEmpty) params['query'] = query;

  return getHTTP(
    endpoint: AppEndpoints.endpointSites,
    parameters: params.isEmpty ? null : params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postSiteNovo(Map<String, dynamic> body) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointSitesNovo,
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> putSiteAlterar(int id, Map<String, dynamic> body) async {
  return putHTTP(
    endpoint: AppEndpoints.endpointSitesAlterar,
    parameters: {'id': id.toString()},
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> deleteSite(int id) async {
  return deleteHTTP(
    endpoint: AppEndpoints.endpointSitesApagar,
    parameters: {'id': id.toString()},
    headers: await getAuthHeaders(),
  );
}
