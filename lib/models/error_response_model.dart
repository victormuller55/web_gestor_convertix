import 'package:muller_package/muller_package.dart';

class ErrorResponseModel {
  DateTime? timestamp;
  int? status;
  String? error;
  String? message;
  Map<String, String>? errors;
  int? retryAfterSeconds;

  ErrorResponseModel({
    this.timestamp,
    this.status,
    this.error,
    this.message,
    this.errors,
    this.retryAfterSeconds,
  });

  ErrorResponseModel.fromMap(
    Map<String, dynamic> json, {
    Map<String, String>? headers,
  }) {
    timestamp = json['timestamp'] != null
        ? DateTime.tryParse(json['timestamp'].toString())
        : null;
    status = json['status'] is int
        ? json['status'] as int
        : int.tryParse('${json['status'] ?? ''}');
    error = json['error']?.toString();
    message = json['message']?.toString();
    final rawErrors = json['errors'];
    if (rawErrors is Map) {
      errors = rawErrors.map(
        (key, value) => MapEntry(key.toString(), value.toString()),
      );
    }
    retryAfterSeconds = _parseRetryAfter(headers);
  }

  ErrorModel toErrorModel() {
    var mensagem = message ?? error ?? 'Erro desconhecido';
    if (errors != null && errors!.isNotEmpty) {
      mensagem = errors!.values.join('\n');
    }
    return ErrorModel(
      mensagem: mensagem,
      erro: retryAfterSeconds?.toString() ?? error ?? '',
      tipo: status?.toString() ?? '',
    );
  }
}

int? _parseRetryAfter(Map<String, String>? headers) {
  if (headers == null || headers.isEmpty) return null;
  final raw = headers['retry-after'] ?? headers['Retry-After'];
  if (raw == null || raw.trim().isEmpty) return null;
  return int.tryParse(raw.trim());
}
