import 'package:muller_package/app_consts/app_strings.dart';
import 'package:muller_package/functions/validators.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';

export 'package:muller_package/functions/util.dart' show validateNotEmpty;
export 'package:muller_package/functions/formatters.dart'
    show formataCPF, formataCelular, formataCNPJ;
export 'package:muller_package/functions/validators.dart' show validaCPF;

const int senhaMinLength = 8;
const int senhaMaxLength = 128;

String? validateMoney(
  String? value, {
  bool required = true,
  String field = 'Valor',
  double min = 0.01,
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? '$field é obrigatório' : null;
  }

  final parsed = parseMoneyBr(trimmed);
  if (parsed == null || parsed <= 0) {
    return '$field inválido';
  }
  if (parsed < min) {
    final minLabel = min.toStringAsFixed(2).replaceAll('.', ',');
    return '$field mínimo é R\$ $minLabel';
  }
  if (parsed > 999999999.99) {
    return '$field muito alto';
  }
  return null;
}

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
  if (!validaEmail(value)) return AppStrings.emailInvalido;
  return null;
}

String? validateSenhaLogin(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Digite sua senha';
  }
  return null;
}

/// Senha de cadastro/atualização: 8–128 caracteres.
/// Em edição, deixe [required] = false para permitir não alterar.
String? validateSenha(
  String? value, {
  bool required = true,
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'Senha é obrigatória' : null;
  }
  if (trimmed.length < senhaMinLength || trimmed.length > senhaMaxLength) {
    return 'A senha deve ter entre $senhaMinLength e $senhaMaxLength caracteres';
  }
  return null;
}

bool validaCNPJ(String value) {
  value = value.replaceAll(RegExp(r'\D'), '');
  if (value.length != 14) return false;
  if (RegExp(r'^(\d)\1*$').hasMatch(value)) return false;

  const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];

  int calcDigit(String str, List<int> weights) {
    var sum = 0;
    for (var i = 0; i < weights.length; i++) {
      sum += int.parse(str[i]) * weights[i];
    }
    final mod = sum % 11;
    return mod < 2 ? 0 : 11 - mod;
  }

  final d1 = calcDigit(value.substring(0, 12), weights1);
  if (d1 != int.parse(value[12])) return false;
  final d2 = calcDigit(value.substring(0, 13), weights2);
  if (d2 != int.parse(value[13])) return false;
  return true;
}

String? validateDocumento(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'O documento é obrigatório';
  }

  final trimmed = value.trim();
  if (trimmed.length < 11 || trimmed.length > 18) {
    return 'Documento deve ter entre 11 e 18 caracteres';
  }

  final digits = trimmed.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11) {
    return validaCPF(digits) ? null : 'Documento inválido';
  }
  if (digits.length == 14) {
    return validaCNPJ(digits) ? null : 'Documento inválido';
  }
  return 'Documento inválido';
}

String? validateNomeUsuarioBioLink(String? value) {
  final nome = normalizeNomeUsuarioBioLink(value);
  if (nome.isEmpty) return 'Nome de usuário é obrigatório';
  if (nome.length < 3 || nome.length > 50) {
    return 'Nome de usuário deve ter entre 3 e 50 caracteres';
  }
  if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(nome)) {
    return 'Use apenas letras, números, ponto, underscore ou hífen';
  }
  return null;
}

String normalizeNomeUsuarioBioLink(String? value) {
  var nome = value?.trim() ?? '';
  if (nome.startsWith('@')) {
    nome = nome.substring(1);
  }
  return nome;
}

/// Valida URL completa (deve começar com http:// ou https://).
String? validateHttpUrl(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'URL é obrigatória' : null;
  }
  final url = normalizeUrl(trimmed);
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'A URL deve começar com http:// ou https://';
  }
  final uri = Uri.tryParse(url);
  if (uri == null || uri.host.isEmpty) {
    return 'URL inválida';
  }
  return null;
}

/// Campo de domínio do formulário (prefixo https:// visual); valida o valor final.
String? validateDominioUrlForm(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'URL é obrigatória' : null;
  }
  return validateHttpUrl(normalizeUrl(trimmed), required: required);
}

/// Slug / subdomínio: apenas letras, números e hífen.
String? validateSlug(
  String? value, {
  bool required = false,
  String field = 'Slug',
}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? '$field é obrigatório' : null;
  }
  if (!RegExp(r'^[A-Za-z0-9-]+$').hasMatch(trimmed)) {
    return '$field deve conter apenas letras, números e hífen';
  }
  return null;
}

String? validateCep(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'CEP é obrigatório' : null;
  }
  if (!RegExp(r'^\d{8}$|^\d{5}-\d{3}$').hasMatch(trimmed)) {
    return 'CEP inválido. Use 12345678 ou 12345-678';
  }
  return null;
}

String? validateCartaoNumero(String? value, {bool required = true}) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return required ? 'Número do cartão é obrigatório' : null;
  }
  if (digits.length < 13 || digits.length > 19) {
    return 'Número do cartão deve ter entre 13 e 19 dígitos';
  }
  return null;
}

String? validateCartaoExpiryMonth(String? value, {bool required = true}) {
  final trimmed = value?.trim() ?? '';
  if (trimmed.isEmpty) {
    return required ? 'Mês de validade é obrigatório' : null;
  }
  if (!RegExp(r'^(0[1-9]|1[0-2])$').hasMatch(trimmed)) {
    return 'Mês de validade inválido (01–12)';
  }
  return null;
}

String? validateCartaoCcv(String? value, {bool required = true}) {
  final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) {
    return required ? 'CVV é obrigatório' : null;
  }
  if (digits.length < 3 || digits.length > 4) {
    return 'CVV deve ter 3 ou 4 dígitos';
  }
  return null;
}
