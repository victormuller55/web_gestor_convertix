import 'package:bloc/bloc.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_state.dart';

class SitesBloc extends Bloc<SitesEvent, SitesState> {
  SitesBloc() : super(SitesInitialState()) {
    on<SitesLoadEvent>((event, emit) async {
      emit(SitesLoadingState());
      try {
        final sites = await listarSites(forceRefresh: event.forceRefresh);
        emit(SitesSuccessState(sites: sites));
      } catch (e) {
        emit(SitesErrorState(errorModel: parseApiError(e)));
      }
    });

    on<SitesSaveEvent>((event, emit) async {
      emit(SitesSaveLoadingState());
      try {
        final site = event.site;
        if (site.id != null && site.id! > 0) {
          await alterarSite(site.id!, site);
        } else {
          await criarSite(site);
        }
        emit(SitesSaveSuccessState());
      } catch (e) {
        emit(SitesSaveErrorState(errorModel: parseApiError(e)));
      }
    });

    on<SitesDeleteEvent>((event, emit) async {
      emit(SitesLoadingState());
      try {
        await excluirSite(event.siteId);
        emit(SitesDeleteSuccessState());
      } catch (e) {
        emit(SitesErrorState(errorModel: parseApiError(e)));
      }
    });
  }
}
