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
    dataCompraDominio = _parseDate(json['data_compra_dominio']);
    dataFimDominio = _parseDate(json['data_fim_dominio']);
    dataRenovacao = _parseDate(json['data_renovacao']);
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
        'data_compra_dominio': _formatApiDate(dataCompraDominio!),
      if (dataFimDominio != null)
        'data_fim_dominio': _formatApiDate(dataFimDominio!),
      if (dataRenovacao != null)
        'data_renovacao': _formatApiDate(dataRenovacao!),
    };
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return DateTime.tryParse(value.toString());
  }

  static String _formatApiDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
