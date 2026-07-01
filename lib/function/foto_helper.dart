import 'package:image_picker/image_picker.dart';

const int maxFotoBytes = 5 * 1024 * 1024;

const _extensoesValidas = {'.jpg', '.jpeg', '.png', '.webp'};

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

  final bytes = await file.length();
  if (bytes > maxFotoBytes) {
    return 'Arquivo excede o tamanho máximo permitido de 5 MB';
  }
  return null;
}
