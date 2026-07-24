import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';

abstract class PagamentosState {}

class PagamentosInitialState extends PagamentosState {}

class PagamentosLoadingState extends PagamentosState {}

class PagamentosSuccessState extends PagamentosState {
  final PagamentoPageModel page;
  PagamentosSuccessState({required this.page});

  List<PagamentoModel> get pagamentos => page.content;
}

class PagamentosErrorState extends PagamentosState {
  final ErrorModel errorModel;
  PagamentosErrorState({required this.errorModel});
}

class PagamentosSaveLoadingState extends PagamentosState {}

class PagamentosSaveSuccessState extends PagamentosState {
  final PagamentoModel pagamento;
  PagamentosSaveSuccessState({required this.pagamento});
}

class PagamentosSaveErrorState extends PagamentosState {
  final ErrorModel errorModel;
  PagamentosSaveErrorState({required this.errorModel});
}

class PagamentosActionSuccessState extends PagamentosState {
  final PagamentoModel pagamento;
  final String message;
  PagamentosActionSuccessState({
    required this.pagamento,
    required this.message,
  });
}

class PagamentosDetalheSuccessState extends PagamentosState {
  final PagamentoModel pagamento;
  PagamentosDetalheSuccessState({required this.pagamento});
}

class PagamentosStatusUpdatedState extends PagamentosState {
  final PagamentoModel pagamento;
  PagamentosStatusUpdatedState({required this.pagamento});
}
