import 'dart:convert';

import 'package:web_gestor_site_covertix/core/cache/cache_keys.dart';
import 'package:web_gestor_site_covertix/core/cache/page_data_cache.dart';
import 'package:web_gestor_site_covertix/models/financeiro_dashboard_model.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/services/financeiro_service.dart';
import 'package:web_gestor_site_covertix/services/pagamento_service.dart';

Future<FinanceiroDashboardModel> carregarFinanceiroDashboard({
  bool forceRefresh = false,
}) async {
  if (!forceRefresh) {
    final cached = await PageDataCache.getJson(CacheKeys.financeiroDashboard);
    if (cached != null) {
      return FinanceiroDashboardModel.fromMap(cached);
    }
  }

  final response = await getFinanceiroDashboard();
  final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  await PageDataCache.setJson(CacheKeys.financeiroDashboard, map);
  return FinanceiroDashboardModel.fromMap(map);
}

Future<List<PagamentoResumoModel>> carregarUltimosPagamentos() async {
  final response = await getPagamentosUltimos();
  final list = jsonDecode(response.body) as List;
  return list
      .whereType<Map>()
      .map((e) => PagamentoResumoModel.fromMap(Map<String, dynamic>.from(e)))
      .toList();
}

Future<void> invalidarCacheFinanceiro() async {
  await PageDataCache.invalidate(CacheKeys.financeiroDashboard);
  await PageDataCache.invalidate(CacheKeys.pagamentosHistorico);
}
