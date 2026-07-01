import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> getBioLinks({int? id}) async {
  final params = <String, String>{};
  if (id != null) params['id'] = id.toString();

  return getHTTP(
    endpoint: AppEndpoints.endpointBioLinks,
    parameters: params.isEmpty ? null : params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postBioLinkNovo(Map<String, dynamic> body) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointBioLinksNovo,
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> putBioLinkAlterar(int id, Map<String, dynamic> body) async {
  return putHTTP(
    endpoint: AppEndpoints.endpointBioLinksAlterar,
    parameters: {'id': id.toString()},
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> deleteBioLink(int id) async {
  return deleteHTTP(
    endpoint: AppEndpoints.endpointBioLinksApagar,
    parameters: {'id': id.toString()},
    headers: await getAuthHeaders(),
  );
}
