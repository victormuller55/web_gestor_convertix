import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';

Future<AppResponse> login(String email, String senha) async {
  return postHTTP(endpoint: AppEndpoints.endpointAuthLogin, body: {'email': email, 'senha': senha});
}
