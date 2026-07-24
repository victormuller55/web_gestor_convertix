import 'dart:convert';

import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/services/site_service.dart';

Future<PageResponse<SiteModel>> listarSites({
  String? query,
  int page = 0,
  int size = PageResponse.defaultSize,
}) async {
  final response = await getSites(query: query, page: page, size: size);
  return PageResponse.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    SiteModel.fromMap,
  );
}

Future<List<SiteModel>> listarSitesLookup({String? query}) async {
  final page = await listarSites(
    query: query,
    page: 0,
    size: PageResponse.maxSize,
  );
  return page.content;
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
