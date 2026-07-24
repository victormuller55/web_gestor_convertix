import 'package:web_gestor_site_covertix/function/date_format.dart';

class SiteDominioModel {
  double? valorDominio;
  int? duracaoDominio;
  DateTime? dataCompraDominio;
  DateTime? dataFimDominio;
  DateTime? dataRenovacao;

  SiteDominioModel({
    this.valorDominio,
    this.duracaoDominio,
    this.dataCompraDominio,
    this.dataFimDominio,
    this.dataRenovacao,
  });

  factory SiteDominioModel.empty() {
    return SiteDominioModel();
  }

  SiteDominioModel.fromMap(Map<String, dynamic> json) {
    valorDominio = _parseDouble(json['valor_dominio']);
    duracaoDominio = json['duracao_dominio'];
    dataCompraDominio = parseApiDateTime(json['data_compra_dominio']);
    dataFimDominio = parseApiDateTime(json['data_fim_dominio']);
    dataRenovacao = parseApiDateTime(json['data_renovacao']);
  }

  bool get hasPersistedData =>
      valorDominio != null ||
      dataCompraDominio != null ||
      dataFimDominio != null ||
      dataRenovacao != null;

  bool get dominioVencido => (duracaoDominio ?? 0) < 0;

  bool get dominioProximoVencimento =>
      duracaoDominio != null && duracaoDominio! >= 0 && duracaoDominio! <= 30;

  Map<String, dynamic> toJson() {
    return {
      if (valorDominio != null) 'valor_dominio': valorDominio,
      if (dataCompraDominio != null)
        'data_compra_dominio': formatApiDate(dataCompraDominio!),
      if (dataFimDominio != null)
        'data_fim_dominio': formatApiDate(dataFimDominio!),
      if (dataRenovacao != null)
        'data_renovacao': formatApiDate(dataRenovacao!),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
