import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';

Future<AppResponse> getAssinaturas({String? status}) async {
  final params = <String, String>{};
  if (status != null && status.isNotEmpty) params['status'] = status;
  return getJson(
    endpoint: AppEndpoints.endpointAssinaturas,
    parameters: params.isEmpty ? null : params,
  );
}

Future<AppResponse> getAssinaturaById(int id) async {
  return getJson(endpoint: AppEndpoints.endpointAssinaturaById(id));
}

Future<AppResponse> postAssinatura(Map<String, dynamic> body) async {
  return postJson(endpoint: AppEndpoints.endpointAssinaturas, body: body);
}

Future<AppResponse> putAssinatura(int id, Map<String, dynamic> body) async {
  return putJson(
    endpoint: AppEndpoints.endpointAssinaturaById(id),
    body: body,
  );
}

Future<void> deleteAssinaturaHttp(int id) async {
  await deleteJson(endpoint: AppEndpoints.endpointAssinaturaById(id));
}
