import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';
import 'package:web_gestor_site_covertix/services/biolink_service.dart';

Future<List<BioLinkModel>> listarBioLinks({bool forceRefresh = false}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJsonList(CacheKeys.biolinks);
    if (cached != null) {
      return cached.map(BioLinkModel.fromMap).toList();
    }
  }
  final response = await getBioLinks();
  final list = jsonDecode(response.body) as List;
  final maps = list
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  await PageDataCache.setJsonList(CacheKeys.biolinks, maps);
  return maps.map(BioLinkModel.fromMap).toList();
}

Future<BioLinkModel> criarBioLink(BioLinkModel biolink, {XFile? foto}) async {
  final response = await postMultipart(
    endpoint: AppEndpoints.endpointBioLinksNovo,
    dados: biolink.toJsonCadastro(),
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.biolinks);
  if (response.body.isEmpty) return biolink;
  return BioLinkModel.fromMap(jsonDecode(response.body));
}

Future<BioLinkModel> alterarBioLink(
  int id,
  BioLinkModel biolink, {
  XFile? foto,
}) async {
  final response = await putMultipart(
    endpoint: AppEndpoints.endpointBioLinksAlterar,
    parameters: {'id': id.toString()},
    dados: biolink.toJsonCadastro(),
    foto: foto,
  );
  await PageDataCache.invalidate(CacheKeys.biolinks);
  return BioLinkModel.fromMap(jsonDecode(response.body));
}

Future<void> excluirBioLink(int id) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointBioLinksApagar,
    parameters: {'id': id.toString()},
  );
  await PageDataCache.invalidate(CacheKeys.biolinks);
}
