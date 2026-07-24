import 'dart:convert';

import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/session_guard.dart';
import 'package:web_gestor_site_covertix/function/api_response_meta.dart';
import 'package:web_gestor_site_covertix/models/error_response_model.dart';

ErrorModel errorModelFromException(
  Object e, {
  bool isAuthEndpoint = false,
}) {
  if (e is ApiException) {
    final statusCode = e.response.statusCode;
    final headers = ApiResponseMeta.headersOf(e.response);
    final body = e.response.body.toString().trim();

    if (!isAuthEndpoint && statusCode == 401) {
      forceLogoutOnUnauthorized();
    }

    if (body.isEmpty) {
      return _fallbackError(statusCode, headers: headers);
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('message') || decoded.containsKey('errors')) {
          final model = ErrorResponseModel.fromMap(
            decoded,
            headers: headers,
          );
          model.status ??= statusCode;
          model.retryAfterSeconds ??= _retryAfterFromHeaders(headers);
          return model.toErrorModel();
        }
        return ErrorModel.fromMap(decoded);
      }
    } catch (_) {
      // corpo não-JSON
    }

    return _fallbackError(statusCode, body: body, headers: headers);
  }

  return ErrorModel.empty();
}

ErrorModel parseApiError(Object e, {bool isAuthEndpoint = false}) =>
    errorModelFromException(e, isAuthEndpoint: isAuthEndpoint);

int? retryAfterSecondsFromError(ErrorModel error) {
  if (error.tipo != '429') return null;
  return int.tryParse(error.erro ?? '');
}

ErrorModel _fallbackError(
  int statusCode, {
  String? body,
  Map<String, String>? headers,
}) {
  final retryAfter = _retryAfterFromHeaders(headers);
  var mensagem = body ?? 'Erro desconhecido';

  if (statusCode == 401) {
    mensagem = 'Usuário ou senha inválidos.';
  } else if (statusCode == 403) {
    mensagem = 'Sem permissão para acessar este recurso.';
  } else if (statusCode == 429) {
    mensagem =
        'Limite de requisições excedido. Tente novamente em breve.';
  }

  return ErrorModel(
    mensagem: mensagem,
    erro: retryAfter?.toString() ?? body ?? '',
    tipo: '$statusCode',
  );
}

int? _retryAfterFromHeaders(Map<String, String>? headers) {
  if (headers == null || headers.isEmpty) return null;
  final raw = headers['retry-after'] ?? headers['Retry-After'];
  if (raw == null || raw.trim().isEmpty) return null;
  return int.tryParse(raw.trim());
}
