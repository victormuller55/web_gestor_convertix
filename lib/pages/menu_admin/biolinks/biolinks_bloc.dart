import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_state.dart';

class BiolinksBloc extends Bloc<BiolinksEvent, BiolinksState> {
  BiolinksBloc() : super(BiolinksInitialState()) {
    on<BiolinksLoadEvent>((event, emit) async {
      emit(BiolinksLoadingState());
      try {
        final page = await listarBioLinks(page: event.page, size: event.size);
        emit(BiolinksSuccessState(page: page));
      } catch (e) {
        emit(BiolinksErrorState(errorModel: parseApiError(e)));
      }
    });

    on<BiolinksSaveEvent>((event, emit) async {
      emit(BiolinksSaveLoadingState());
      try {
        final biolink = event.biolink;
        if (biolink.id != null && biolink.id! > 0) {
          await alterarBioLink(biolink.id!, biolink, foto: event.foto);
        } else {
          await criarBioLink(biolink, foto: event.foto);
        }
        emit(BiolinksSaveSuccessState());
      } catch (e) {
        emit(BiolinksSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<BiolinksDeleteEvent>((event, emit) async {
      emit(BiolinksLoadingState());
      try {
        await excluirBioLink(event.biolinkId);
        emit(BiolinksDeleteSuccessState());
      } catch (e) {
        emit(BiolinksErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
