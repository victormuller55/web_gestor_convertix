import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';

abstract class SitesState {}

class SitesInitialState extends SitesState {}

class SitesLoadingState extends SitesState {}

class SitesSuccessState extends SitesState {
  final List<SiteModel> sites;
  SitesSuccessState({required this.sites});
}

class SitesErrorState extends SitesState {
  final ErrorModel errorModel;
  SitesErrorState({required this.errorModel});
}

class SitesSaveLoadingState extends SitesState {}

class SitesSaveSuccessState extends SitesState {}

class SitesSaveErrorState extends SitesState {
  final ErrorModel errorModel;
  SitesSaveErrorState({required this.errorModel});
}

class SitesDeleteSuccessState extends SitesState {}
