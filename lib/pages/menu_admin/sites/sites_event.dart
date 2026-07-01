import 'package:web_gestor_site_covertix/models/site_model.dart';

abstract class SitesEvent {}

class SitesLoadEvent extends SitesEvent {
  final bool forceRefresh;
  SitesLoadEvent({this.forceRefresh = false});
}

class SitesSaveEvent extends SitesEvent {
  final SiteModel site;
  SitesSaveEvent({required this.site});
}

class SitesDeleteEvent extends SitesEvent {
  final int siteId;
  SitesDeleteEvent({required this.siteId});
}
