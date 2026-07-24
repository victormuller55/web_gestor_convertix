import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_state.dart';

class FinanceiroBloc extends Bloc<FinanceiroEvent, FinanceiroState> {
  FinanceiroBloc() : super(FinanceiroInitialState()) {
    on<FinanceiroLoadEvent>((event, emit) async {
      emit(FinanceiroLoadingState());
      try {
        final dashboard = await carregarFinanceiroDashboard(
          forceRefresh: event.forceRefresh,
        );
        final ultimos = await carregarUltimosPagamentos();
        emit(FinanceiroSuccessState(dashboard: dashboard, ultimos: ultimos));
      } catch (e) {
        emit(FinanceiroErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
