import 'package:muller_package/muller_package.dart';

/// Metadados extras da resposta HTTP (ex.: Retry-After), sem alterar o AppResponse do pacote.
class ApiResponseMeta {
  static final Expando<Map<String, String>> _headers = Expando();

  static void attachHeaders(AppResponse response, Map<String, String> headers) {
    _headers[response] = Map<String, String>.from(headers);
  }

  static Map<String, String> headersOf(AppResponse response) {
    return _headers[response] ?? const {};
  }
}

AppResponse appResponseWithHeaders({
  required int statusCode,
  required String body,
  Map<String, String>? headers,
}) {
  final response = AppResponse(statusCode: statusCode, body: body);
  if (headers != null && headers.isNotEmpty) {
    ApiResponseMeta.attachHeaders(response, headers);
  }
  return response;
}
