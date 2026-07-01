import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> getBioLinkItens({
  required int biolinkId,
  int? id,
}) async {
  final params = <String, String>{'biolink_id': biolinkId.toString()};
  if (id != null) params['id'] = id.toString();

  return getHTTP(
    endpoint: AppEndpoints.endpointBioLinkItens,
    parameters: params,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> postBioLinkItemNovo(Map<String, dynamic> body) async {
  return postHTTP(
    endpoint: AppEndpoints.endpointBioLinkItensNovo,
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> putBioLinkItemAlterar({
  required int biolinkId,
  required int id,
  required Map<String, dynamic> body,
}) async {
  return putHTTP(
    endpoint: AppEndpoints.endpointBioLinkItensAlterar,
    parameters: {
      'biolink_id': biolinkId.toString(),
      'id': id.toString(),
    },
    body: body,
    headers: await getAuthHeaders(),
  );
}

Future<AppResponse> deleteBioLinkItem({
  required int biolinkId,
  required int id,
}) async {
  return deleteHTTP(
    endpoint: AppEndpoints.endpointBioLinkItensApagar,
    parameters: {
      'biolink_id': biolinkId.toString(),
      'id': id.toString(),
    },
    headers: await getAuthHeaders(),
  );
}
