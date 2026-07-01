import 'package:muller_package/app_consts/app_strings.dart';
import 'package:muller_package/functions/validators.dart';

export 'package:muller_package/functions/util.dart' show validateNotEmpty;
export 'package:muller_package/functions/formatters.dart'
    show formataCPF, formataCelular, formataCNPJ;
export 'package:muller_package/functions/validators.dart' show validaCPF;

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

  final digits = value.replaceAll(RegExp(r'\D'), '');
  if (digits.length == 11) {
    return validaCPF(digits) ? null : 'Documento inválido';
  }
  if (digits.length == 14) {
    return validaCNPJ(digits) ? null : 'Documento inválido';
  }
  return 'Documento inválido';
}
