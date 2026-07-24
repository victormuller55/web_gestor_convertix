import 'package:web_gestor_site_covertix/models/page_response.dart';

abstract class AssinaturasEvent {}

class AssinaturasLoadEvent extends AssinaturasEvent {
  final String? status;
  final int page;
  final int size;

  AssinaturasLoadEvent({
    this.status,
    this.page = 0,
    this.size = PageResponse.defaultSize,
  });
}

class AssinaturasCreateEvent extends AssinaturasEvent {
  final Map<String, dynamic> body;
  AssinaturasCreateEvent({required this.body});
}

class AssinaturasCancelarEvent extends AssinaturasEvent {
  final int assinaturaId;
  AssinaturasCancelarEvent({required this.assinaturaId});
}

class AssinaturasDetalheEvent extends AssinaturasEvent {
  final int assinaturaId;
  AssinaturasDetalheEvent({required this.assinaturaId});
}
