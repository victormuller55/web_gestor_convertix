import 'dart:convert';

import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_model.dart';
import 'package:web_gestor_site_covertix/services/biolink_item_service.dart';

Future<List<BioLinkItemModel>> listarBioLinkItens(int biolinkId) async {
  final response = await getBioLinkItens(biolinkId: biolinkId);
  final body = jsonDecode(response.body);
  if (body is List) {
    return body
        .map((item) => BioLinkItemModel.fromMap(item as Map<String, dynamic>))
        .toList();
  }
  return [BioLinkItemModel.fromMap(body as Map<String, dynamic>)];
}

Future<BioLinkItemModel> criarBioLinkItem(BioLinkItemModel item) async {
  final response = await postJson(
    endpoint: AppEndpoints.endpointBioLinkItensNovo,
    body: item.toJsonCadastro(),
  );
  return BioLinkItemModel.fromMap(jsonDecode(response.body));
}

Future<BioLinkItemModel> alterarBioLinkItem(BioLinkItemModel item) async {
  final response = await putJson(
    endpoint: AppEndpoints.endpointBioLinkItensAlterar,
    parameters: {
      'biolink_id': item.biolinkId.toString(),
      'id': item.id.toString(),
    },
    body: item.toJsonCadastro(includeBiolinkId: false),
  );
  return BioLinkItemModel.fromMap(jsonDecode(response.body));
}

Future<void> excluirBioLinkItem({
  required int biolinkId,
  required int id,
}) async {
  await deleteJson(
    endpoint: AppEndpoints.endpointBioLinkItensApagar,
    parameters: {
      'biolink_id': biolinkId.toString(),
      'id': id.toString(),
    },
  );
}
