import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
const String _keyToken = 'auth_token';
const String _keyUsuario = 'usuario_logado';

Future<String?> getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyToken);
}

Future<void> saveToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyToken, token);
}

Future<void> clearToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_keyToken);
  await prefs.remove(_keyUsuario);
  await PageDataCache.clearAll();
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
