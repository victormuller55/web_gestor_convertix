import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';

abstract class AssinaturasState {}

class AssinaturasInitialState extends AssinaturasState {}

class AssinaturasLoadingState extends AssinaturasState {}

class AssinaturasSuccessState extends AssinaturasState {
  final PageResponse<AssinaturaModel> page;
  AssinaturasSuccessState({required this.page});

  List<AssinaturaModel> get assinaturas => page.content;
}

class AssinaturasErrorState extends AssinaturasState {
  final ErrorModel errorModel;
  AssinaturasErrorState({required this.errorModel});
}

class AssinaturasSaveLoadingState extends AssinaturasState {}

class AssinaturasSaveSuccessState extends AssinaturasState {
  final AssinaturaModel assinatura;
  AssinaturasSaveSuccessState({required this.assinatura});
}

class AssinaturasSaveErrorState extends AssinaturasState {
  final ErrorModel errorModel;
  AssinaturasSaveErrorState({required this.errorModel});
}

class AssinaturasActionSuccessState extends AssinaturasState {
  final String message;
  AssinaturasActionSuccessState({required this.message});
}

class AssinaturasDetalheSuccessState extends AssinaturasState {
  final AssinaturaModel assinatura;
  AssinaturasDetalheSuccessState({required this.assinatura});
}
