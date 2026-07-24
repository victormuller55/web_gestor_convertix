import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/function/api_error.dart';
import 'package:web_gestor_site_covertix/function/api_response_meta.dart';

Future<http.Response> _request(Future<http.Response> Function() call) async {
  try {
    final response = await call();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    }
    throw ApiException(
      appResponseWithHeaders(
        statusCode: response.statusCode,
        body: response.body,
        headers: response.headers,
      ),
    );
  } catch (e) {
    if (e is ApiException) rethrow;
    throw ApiException(AppResponse(statusCode: 0, body: e.toString()));
  }
}

Future<AppResponse> postJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(
    () => http.post(uri, headers: headers, body: jsonEncode(body)),
  );
  return appResponseWithHeaders(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
    headers: response.headers,
  );
}

Future<AppResponse> putJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(
    () => http.put(uri, headers: headers, body: jsonEncode(body)),
  );
  return appResponseWithHeaders(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
    headers: response.headers,
  );
}

Future<AppResponse> getJson({
  required String endpoint,
  Map<String, String>? parameters,
}) async {
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(() => http.get(uri, headers: headers));
  return appResponseWithHeaders(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
    headers: response.headers,
  );
}

Future<AppResponse> patchJson({
  required String endpoint,
  required Map<String, dynamic> body,
  Map<String, String>? parameters,
}) async {
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
  final uri = Uri.parse(endpoint + _query(parameters));
  final response = await _request(
    () => http.patch(uri, headers: headers, body: jsonEncode(body)),
  );
  return appResponseWithHeaders(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
    headers: response.headers,
  );
}

Future<void> deleteJson({
  required String endpoint,
  Map<String, String>? parameters,
}) async {
  final headers = {
    'Content-Type': 'application/json; charset=UTF-8',
    ...await getAuthHeaders(),
  };
  final uri = Uri.parse(endpoint + _query(parameters));
  await _request(() => http.delete(uri, headers: headers));
}

Future<AppResponse> postMultipart({
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  return _sendMultipart(
    method: 'POST',
    endpoint: endpoint,
    dados: dados,
    foto: foto,
    parameters: parameters,
  );
}

Future<AppResponse> putMultipart({
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  return _sendMultipart(
    method: 'PUT',
    endpoint: endpoint,
    dados: dados,
    foto: foto,
    parameters: parameters,
  );
}

Future<AppResponse> _sendMultipart({
  required String method,
  required String endpoint,
  required Map<String, dynamic> dados,
  XFile? foto,
  Map<String, String>? parameters,
}) async {
  final uri = Uri.parse(endpoint + _query(parameters));
  final request = http.MultipartRequest(method, uri);
  request.headers.addAll(await getAuthHeaders());

  request.files.add(
    http.MultipartFile.fromString(
      'dados',
      jsonEncode(dados),
      contentType: MediaType('application', 'json'),
    ),
  );

  if (foto != null) {
    final bytes = await foto.readAsBytes();
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        bytes,
        filename: foto.name,
        contentType: _mediaTypeFromName(foto.name),
      ),
    );
  }

  final response = await _request(
    () => request.send().then(http.Response.fromStream),
  );
  return appResponseWithHeaders(
    statusCode: response.statusCode,
    body: utf8.decode(response.bodyBytes),
    headers: response.headers,
  );
}

MediaType? _mediaTypeFromName(String name) {
  final lower = name.toLowerCase();
  if (lower.endsWith('.png')) return MediaType('image', 'png');
  if (lower.endsWith('.webp')) return MediaType('image', 'webp');
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
    return MediaType('image', 'jpeg');
  }
  return MediaType('image', 'jpeg');
}

String _query(Map<String, String>? parameters) {
  if (parameters == null || parameters.isEmpty) return '';
  return '?${parameters.entries.map((e) => '${e.key}=${e.value}').join('&')}';
}

ErrorModel parseApiError(Object e) => errorModelFromException(e);
