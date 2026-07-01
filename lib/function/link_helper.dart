import 'link_helper_platform.dart'
    if (dart.library.html) 'link_helper_web.dart'
    if (dart.library.io) 'link_helper_io.dart';

const String httpsPrefix = 'https://';

String stripUrlProtocol(String value) {
  return value.trim().replaceFirst(RegExp(r'^https?://'), '');
}

String normalizeUrl(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed == '—') return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  return '$httpsPrefix$trimmed';
}

String dominioParaApi(String value) {
  final stripped = stripUrlProtocol(value);
  return stripped.isEmpty ? '' : stripped;
}

String dominioParaFormulario(String? value) {
  if (value == null || value.trim().isEmpty) return '';
  return stripUrlProtocol(value);
}

Future<void> openExternalLink(String value) async {
  final url = normalizeUrl(value);
  if (url.isEmpty) return;

  final uri = Uri.tryParse(url);
  if (uri == null) return;

  await openLinkPlatform(url);
}
