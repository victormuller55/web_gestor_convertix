import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';

const String _keyToken = 'auth_token';
const String _keyUsuario = 'usuario_logado';
const String _keyAuthExpiresAt = 'auth_expires_at';
const Duration _tokenTtl = Duration(hours: 24);

Future<bool> _isSessaoExpirada(SharedPreferences prefs) async {
  final expiresAtRaw = prefs.getString(_keyAuthExpiresAt);
  if (expiresAtRaw == null || expiresAtRaw.isEmpty) return true;
  final expiresAt = DateTime.tryParse(expiresAtRaw);
  if (expiresAt == null) return true;
  return DateTime.now().isAfter(expiresAt);
}

Future<void> _clearSessao(SharedPreferences prefs) async {
  await prefs.remove(_keyToken);
  await prefs.remove(_keyUsuario);
  await prefs.remove(_keyAuthExpiresAt);
  await prefs.remove('auth_saved_day');
  await prefs.remove('theme_dark_mode');
  await PageDataCache.clearAll();
}

Future<bool> _ensureSessaoAtiva() async {
  final prefs = await SharedPreferences.getInstance();
  if (!await _isSessaoExpirada(prefs)) return true;

  if (prefs.containsKey(_keyToken) || prefs.containsKey(_keyUsuario)) {
    await _clearSessao(prefs);
  }
  return false;
}

/// Indica se há token persistido (mesmo que a sessão possa estar inválida na API).
Future<bool> hasTokenSalvo() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_keyToken);
  return token != null && token.isNotEmpty;
}

Future<bool> hasSessaoValida() async {
  if (!await _ensureSessaoAtiva()) return false;

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString(_keyToken);
  if (token == null || token.isEmpty) return false;

  final usuarioJson = prefs.getString(_keyUsuario);
  return usuarioJson != null && usuarioJson.isNotEmpty;
}

Future<String?> getToken() async {
  if (!await _ensureSessaoAtiva()) return null;

  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token);
  final expiresAt = DateTime.now().add(_tokenTtl).toIso8601String();
  await prefs.setString(_keyAuthExpiresAt, expiresAt);
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await _clearSessao(prefs);
}

Future<Map<String, String>> getAuthHeaders() async {
  final token = await getToken();
  if (token == null || token.isEmpty) return {};
  return {'Authorization': 'Bearer $token'};
}

Future<void> saveUsuarioLogado(UsuarioModel usuario) async {
  final prefs = await SharedPreferences.getInstance();
  final data = usuario.toMap()..remove('token');
  await prefs.setString(_keyUsuario, jsonEncode(data));
}

Future<UsuarioModel?> getUsuarioLogado() async {
  if (!await _ensureSessaoAtiva()) return null;

  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString(_keyUsuario);
  if (jsonStr == null || jsonStr.isEmpty) return null;
  try {
    final map = jsonDecode(jsonStr) as Map<String, dynamic>;
    return UsuarioModel.fromMap(map);
  } catch (_) {
    return null;
  }
}

Future<String?> getTipoUsuarioLogado() async {
  final usuario = await getUsuarioLogado();
  return usuario?.tipo;
}

Future<bool> isAdminLogado() async {
  final usuario = await getUsuarioLogado();
  return usuario?.isAdmin ?? false;
}

Future<bool> podeCadastrarSitesEBioLinks() async => isAdminLogado();
