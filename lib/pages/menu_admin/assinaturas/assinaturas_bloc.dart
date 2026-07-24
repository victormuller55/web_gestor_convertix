import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_state.dart';

class AssinaturasBloc extends Bloc<AssinaturasEvent, AssinaturasState> {
  AssinaturasBloc() : super(AssinaturasInitialState()) {
    on<AssinaturasLoadEvent>((event, emit) async {
      emit(AssinaturasLoadingState());
      try {
        final assinaturas = await listarAssinaturas(
          forceRefresh: event.forceRefresh,
          status: event.status,
        );
        emit(AssinaturasSuccessState(assinaturas: assinaturas));
      } catch (e) {
        emit(AssinaturasErrorState(errorModel: parseApiError(e)));
      }
    });

    on<AssinaturasCreateEvent>((event, emit) async {
      emit(AssinaturasSaveLoadingState());
      try {
        final assinatura = await criarAssinatura(event.body);
        emit(AssinaturasSaveSuccessState(assinatura: assinatura));
      } catch (e) {
        emit(AssinaturasSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<AssinaturasCancelarEvent>((event, emit) async {
      emit(AssinaturasLoadingState());
      try {
        await cancelarAssinatura(event.assinaturaId);
        emit(AssinaturasActionSuccessState(
          message: 'Assinatura cancelada com sucesso',
        ));
      } catch (e) {
        emit(AssinaturasErrorState(errorModel: parseApiError(e)));
      }
    });

    on<AssinaturasDetalheEvent>((event, emit) async {
      emit(AssinaturasLoadingState());
      try {
        final assinatura = await obterAssinatura(event.assinaturaId);
        emit(AssinaturasDetalheSuccessState(assinatura: assinatura));
      } catch (e) {
        emit(AssinaturasErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
