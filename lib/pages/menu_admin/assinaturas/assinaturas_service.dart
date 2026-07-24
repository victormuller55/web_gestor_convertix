import 'dart:convert';

import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_service.dart';
import 'package:web_gestor_site_covertix/services/assinatura_service.dart';

Future<List<AssinaturaModel>> listarAssinaturas({
  bool forceRefresh = false,
  String? status,
}) async {
  if (!forceRefresh && (status == null || status.isEmpty)) {
    final cached = await PageDataCache.getJsonList(CacheKeys.assinaturas);
    if (cached != null) {
      return cached.map(AssinaturaModel.fromMap).toList();
    }
  }

  final response = await getAssinaturas(status: status);
  final list = jsonDecode(response.body) as List;
  final maps = list
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  if (status == null || status.isEmpty) {
    await PageDataCache.setJsonList(CacheKeys.assinaturas, maps);
  }
  return maps.map(AssinaturaModel.fromMap).toList();
}

Future<AssinaturaModel> obterAssinatura(int id) async {
  final response = await getAssinaturaById(id);
  return AssinaturaModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<AssinaturaModel> criarAssinatura(Map<String, dynamic> body) async {
  final response = await postAssinatura(body);
  await PageDataCache.invalidate(CacheKeys.assinaturas);
  await invalidarCacheFinanceiro();
  return AssinaturaModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<AssinaturaModel> atualizarAssinatura(
  int id,
  Map<String, dynamic> body,
) async {
  final response = await putAssinatura(id, body);
  await PageDataCache.invalidate(CacheKeys.assinaturas);
  await invalidarCacheFinanceiro();
  return AssinaturaModel.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
  );
}

Future<void> cancelarAssinatura(int id) async {
  await deleteAssinaturaHttp(id);
  await PageDataCache.invalidate(CacheKeys.assinaturas);
  await invalidarCacheFinanceiro();
}
