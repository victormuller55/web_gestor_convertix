class TipoUsuario {
  static const admin = 'ADMIN';
  static const cliente = 'CLIENTE';
}

class TipoSite {
  static const biolink = 'BIOLINK';
  static const landingPage = 'LANDING_PAGE';
  static const siteComercial = 'SITE_COMERCIAL';
}

class StatusSite {
  static const ativo = 'ATIVO';
  static const inativo = 'INATIVO';
  static const emDesenvolvimento = 'EM_DESENVOLVIMENTO';
}

class StatusPagamento {
  static const pending = 'PENDING';
  static const received = 'RECEIVED';
  static const confirmed = 'CONFIRMED';
  static const overdue = 'OVERDUE';
  static const refunded = 'REFUNDED';
  static const cancelled = 'CANCELLED';
  static const failed = 'FAILED';
  static const deleted = 'DELETED';

  static const List<String> todos = [
    pending,
    received,
    confirmed,
    overdue,
    refunded,
    cancelled,
    failed,
    deleted,
  ];

  static bool isPago(String? status) =>
      status == received || status == confirmed;

  static bool podeCancelar(String? status) => status == pending;

  static bool podeEstornar(String? status) => isPago(status);
}

class FormaPagamento {
  static const pix = 'PIX';
  static const creditCard = 'CREDIT_CARD';
  static const boleto = 'BOLETO';

  static const List<String> todos = [pix, creditCard, boleto];
}

class CicloAssinatura {
  static const weekly = 'WEEKLY';
  static const biweekly = 'BIWEEKLY';
  static const monthly = 'MONTHLY';
  static const bimonthly = 'BIMONTHLY';
  static const quarterly = 'QUARTERLY';
  static const semiannually = 'SEMIANNUALLY';
  static const yearly = 'YEARLY';

  static const List<String> todos = [
    weekly,
    biweekly,
    monthly,
    bimonthly,
    quarterly,
    semiannually,
    yearly,
  ];
}

class StatusAssinatura {
  static const active = 'ACTIVE';
  static const inactive = 'INACTIVE';
  static const expired = 'EXPIRED';

  static const List<String> todos = [active, inactive, expired];
}

class SituacaoAssinaturaSite {
  static const emDia = 'EM_DIA';
  static const vencido = 'VENCIDO';
  static const desativado = 'DESATIVADO';

  static const List<String> todos = [emDia, vencido, desativado];
}
