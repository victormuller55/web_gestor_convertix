import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/financeiro_dashboard_model.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';

abstract class FinanceiroState {}

class FinanceiroInitialState extends FinanceiroState {}

class FinanceiroLoadingState extends FinanceiroState {}

class FinanceiroSuccessState extends FinanceiroState {
  final FinanceiroDashboardModel dashboard;
  final List<PagamentoResumoModel> ultimos;

  FinanceiroSuccessState({
    required this.dashboard,
    required this.ultimos,
  });
}

class FinanceiroErrorState extends FinanceiroState {
  final ErrorModel errorModel;
  FinanceiroErrorState({required this.errorModel});
}
