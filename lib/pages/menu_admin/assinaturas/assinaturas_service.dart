import 'dart:convert';

import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_service.dart';
import 'package:web_gestor_site_covertix/services/assinatura_service.dart';

Future<PageResponse<AssinaturaModel>> listarAssinaturas({
  String? status,
  int page = 0,
  int size = PageResponse.defaultSize,
}) async {
  final response = await getAssinaturas(
    status: status,
    page: page,
    size: size,
  );
  return PageResponse.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    AssinaturaModel.fromMap,
  );
}

Future<List<AssinaturaModel>> listarAssinaturasLookup({String? status}) async {
  final page = await listarAssinaturas(
    status: status,
    page: 0,
    size: PageResponse.maxSize,
  );
  return page.content;
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
