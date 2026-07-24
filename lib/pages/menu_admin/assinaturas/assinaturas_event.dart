abstract class AssinaturasEvent {}

class AssinaturasLoadEvent extends AssinaturasEvent {
  final bool forceRefresh;
  final String? status;

  AssinaturasLoadEvent({this.forceRefresh = false, this.status});
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
