import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/services/biolink_service.dart';

Future<PageResponse<BioLinkModel>> listarBioLinks({
  int? id,
  int page = 0,
  int size = PageResponse.defaultSize,
}) async {
  final response = await getBioLinks(id: id, page: page, size: size);
  return PageResponse.fromMap(
    Map<String, dynamic>.from(jsonDecode(response.body) as Map),
    BioLinkModel.fromMap,
  );
}

Future<List<BioLinkModel>> listarBioLinksLookup({int? id}) async {
  final page = await listarBioLinks(
    id: id,
    page: 0,
    size: PageResponse.maxSize,
  );
  return page.content;
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
