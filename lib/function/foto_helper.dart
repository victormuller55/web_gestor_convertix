import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

const int maxFotoBytes = 5 * 1024 * 1024;

const _extensoesValidas = {'.jpg', '.jpeg', '.png', '.webp'};

const mensagemConteudoIncompativel =
    'Conteúdo do arquivo não corresponde ao tipo informado';

String? validarFoto(XFile file) {
  final nome = file.name.toLowerCase();
  final extensaoValida = _extensoesValidas.any(nome.endsWith);
  if (!extensaoValida) {
    return 'Formato de imagem não suportado. Use JPEG, PNG ou WebP';
  }
  return null;
}

Future<String?> validarFotoComTamanho(XFile file) async {
  final erroFormato = validarFoto(file);
  if (erroFormato != null) return erroFormato;

  final bytes = await file.readAsBytes();
  if (bytes.length > maxFotoBytes) {
    return 'Arquivo excede o tamanho máximo permitido de 5 MB';
  }

  if (!_conteudoCorrespondeAoTipo(bytes, file.name)) {
    return mensagemConteudoIncompativel;
  }

  return null;
}

bool _conteudoCorrespondeAoTipo(Uint8List bytes, String name) {
  if (bytes.length < 12) return false;

  final lower = name.toLowerCase();
  final isJpeg = lower.endsWith('.jpg') || lower.endsWith('.jpeg');
  final isPng = lower.endsWith('.png');
  final isWebp = lower.endsWith('.webp');

  if (isJpeg) {
    return bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
  }
  if (isPng) {
    return bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
  }
  if (isWebp) {
    final riff = String.fromCharCodes(bytes.sublist(0, 4));
    final webp = String.fromCharCodes(bytes.sublist(8, 12));
    return riff == 'RIFF' && webp == 'WEBP';
  }
  return false;
}
