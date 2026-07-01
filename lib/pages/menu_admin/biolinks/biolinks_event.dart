import 'package:image_picker/image_picker.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';

abstract class BiolinksEvent {}

class BiolinksLoadEvent extends BiolinksEvent {
  final bool forceRefresh;
  BiolinksLoadEvent({this.forceRefresh = false});
}

class BiolinksSaveEvent extends BiolinksEvent {
  final BioLinkModel biolink;
  final XFile? foto;
  BiolinksSaveEvent({required this.biolink, this.foto});
}

class BiolinksDeleteEvent extends BiolinksEvent {
  final int biolinkId;
  BiolinksDeleteEvent({required this.biolinkId});
}
