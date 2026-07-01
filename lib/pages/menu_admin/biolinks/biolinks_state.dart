import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';

abstract class BiolinksState {}

class BiolinksInitialState extends BiolinksState {}

class BiolinksLoadingState extends BiolinksState {}

class BiolinksSuccessState extends BiolinksState {
  final List<BioLinkModel> biolinks;
  BiolinksSuccessState({required this.biolinks});
}

class BiolinksErrorState extends BiolinksState {
  final ErrorModel errorModel;
  BiolinksErrorState({required this.errorModel});
}

class BiolinksSaveLoadingState extends BiolinksState {}

class BiolinksSaveSuccessState extends BiolinksState {}

class BiolinksSaveErrorState extends BiolinksState {
  final ErrorModel errorModel;
  BiolinksSaveErrorState({required this.errorModel});
}

class BiolinksDeleteSuccessState extends BiolinksState {}
