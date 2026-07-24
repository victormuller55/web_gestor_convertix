import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';

abstract class SitesEvent {}

class SitesLoadEvent extends SitesEvent {
  final String? query;
  final int page;
  final int size;

  SitesLoadEvent({
    this.query,
    this.page = 0,
    this.size = PageResponse.defaultSize,
  });
}

class SitesSaveEvent extends SitesEvent {
  final SiteModel site;
  SitesSaveEvent({required this.site});
}

class SitesDeleteEvent extends SitesEvent {
  final int siteId;
  SitesDeleteEvent({required this.siteId});
}
