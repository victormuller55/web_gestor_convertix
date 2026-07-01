import 'dart:convert';

import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/services/site_service.dart';

Future<List<SiteModel>> listarSites({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.sites);
    if (cached != null) {
      return cached.map(SiteModel.fromMap).toList();
    }
  }

  final response = await getSites();
  final list = jsonDecode(response.body) as List;
  final maps = list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  await PageDataCache.setJsonList(CacheKeys.sites, maps);
  return maps.map(SiteModel.fromMap).toList();
}

Future<SiteModel> criarSite(SiteModel site) async {
  final response = await postJson(
    endpoint: AppEndpoints.endpointSitesNovo,
    body: site.toJsonCadastro(),
  );
  await PageDataCache.invalidate(CacheKeys.sites);
  if (response.body.isEmpty) return site;
  return SiteModel.fromMap(jsonDecode(response.body));
}

Future<SiteModel> alterarSite(int id, SiteModel site) async {
  final response = await putJson(
    endpoint: AppEndpoints.endpointSitesAlterar,
    parameters: {'id': id.toString()},
    body: site.toJsonCadastro(),
  );
  await PageDataCache.invalidate(CacheKeys.sites);
  return SiteModel.fromMap(jsonDecode(response.body));
}

Future<void> excluirSite(int id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointSitesApagar,
    parameters: {'id': id.toString()},
  );
  await PageDataCache.invalidate(CacheKeys.sites);
}
