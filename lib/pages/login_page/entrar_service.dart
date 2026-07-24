import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';

Future<AppResponse> login(String email, String senha) async {
  return postJson(
    endpoint: AppEndpoints.endpointAuthLogin,
    body: {'email': email, 'senha': senha},
  );
}
