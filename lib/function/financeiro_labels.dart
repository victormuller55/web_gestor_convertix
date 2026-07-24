import 'package:flutter/material.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/plano_assinatura.dart';

String labelStatusPagamento(String? status) {
  switch (status) {
    case StatusPagamento.pending:
      return 'Pendente';
    case StatusPagamento.received:
      return 'Recebido';
    case StatusPagamento.confirmed:
      return 'Confirmado';
    case StatusPagamento.overdue:
      return 'Vencido';
    case StatusPagamento.refunded:
      return 'Estornado';
    case StatusPagamento.cancelled:
      return 'Cancelado';
    case StatusPagamento.failed:
      return 'Falhou';
    case StatusPagamento.deleted:
      return 'Excluído';
    default:
      return status ?? '—';
  }
}

String labelFormaPagamento(String? forma) {
  if (forma == null || forma.trim().isEmpty) {
    return 'Cliente escolhe';
  }
  switch (forma) {
    case FormaPagamento.pix:
      return 'PIX';
    case FormaPagamento.creditCard:
      return 'Cartão';
    case FormaPagamento.boleto:
      return 'Boleto';
    default:
      return forma;
  }
}

String labelCicloAssinatura(String? ciclo) {
  switch (ciclo) {
    case CicloAssinatura.weekly:
      return 'Semanal';
    case CicloAssinatura.biweekly:
      return 'Quinzenal';
    case CicloAssinatura.monthly:
      return 'Mensal';
    case CicloAssinatura.bimonthly:
      return 'Bimestral';
    case CicloAssinatura.quarterly:
      return 'Trimestral';
    case CicloAssinatura.semiannually:
      return 'Semestral';
    case CicloAssinatura.yearly:
      return 'Anual';
    default:
      return ciclo ?? '—';
  }
}

String labelStatusAssinatura(String? status) {
  switch (status) {
    case StatusAssinatura.active:
      return 'Ativa';
    case StatusAssinatura.inactive:
      return 'Inativa';
    case StatusAssinatura.expired:
      return 'Expirada';
    default:
      return status ?? '—';
  }
}

String labelProdutoAssinatura(AssinaturaModel a) {
  if (a.siteTipo != null && a.siteTipo!.isNotEmpty) {
    final plano = PlanoAssinatura.porTipoSite(a.siteTipo);
    if (!plano.manual) return plano.titulo;
  }
  for (final plano in PlanoAssinatura.todos.where((p) => !p.manual)) {
    if ((a.descricao ?? '').trim() == plano.descricaoPadrao) {
      return plano.titulo;
    }
  }
  if (a.siteNome != null && a.siteNome!.trim().isNotEmpty) {
    return a.siteNome!.trim();
  }
  final desc = (a.descricao ?? '').trim();
  return desc.isEmpty ? '—' : desc;
}

Color corStatusPagamento(String? status) {
  switch (status) {
    case StatusPagamento.received:
    case StatusPagamento.confirmed:
      return const Color(0xFF059669);
    case StatusPagamento.pending:
      return const Color(0xFFD97706);
    case StatusPagamento.overdue:
    case StatusPagamento.failed:
      return ConvertixColors.error;
    case StatusPagamento.refunded:
    case StatusPagamento.cancelled:
    case StatusPagamento.deleted:
      return ConvertixColors.textMuted;
    default:
      return ConvertixColors.textSecondary;
  }
}

/// Mensagem técnica (Asaas/backend) → texto amigável para o usuário.
String labelMensagemPagamento(String? mensagem, {String? status}) {
  final raw = (mensagem ?? '').trim();
  if (raw.isEmpty) {
    return _mensagemPadraoPorStatus(status);
  }

  final lower = raw.toLowerCase();

  if (lower.contains('pago manualmente')) {
    return 'Pagamento confirmado';
  }
  if (lower.contains('forma de pagamento a escolher') || lower.contains('cliente escolhe')) {
    return 'Aguardando o cliente escolher a forma de pagamento';
  }
  if (lower.contains('cobrança da assinatura gerada') ||
      lower.contains('proxima cobrança') ||
      lower.contains('próxima cobrança')) {
    return 'Cobrança da assinatura gerada';
  }
  if (lower.contains('sincronização de cobrança') || lower.contains('sincronização manual')) {
    return 'Dados atualizados com o gateway de pagamento';
  }
  if (lower.contains('criado via webhook') || lower.contains('atualização via webhook')) {
    return 'Atualizado pelo gateway de pagamento';
  }
  if (lower.contains('pagamento pix criado')) {
    return 'Cobrança PIX criada';
  }
  if (lower.contains('pagamento cartão criado')) {
    return 'Cobrança no cartão criada';
  }
  if (lower.contains('pagamento cancelado') || lower.contains('cancelamento')) {
    return 'Pagamento cancelado';
  }
  if (lower.contains('estorno')) {
    return 'Pagamento estornado';
  }
  if (lower == 'pending' || lower == 'awaiting_risk_analysis') {
    return 'Aguardando pagamento';
  }
  if (lower == 'received' || lower == 'received_in_cash') {
    return 'Pagamento recebido';
  }
  if (lower == 'confirmed') {
    return 'Pagamento confirmado';
  }
  if (lower == 'overdue') {
    return 'Pagamento vencido';
  }
  if (lower == 'refunded' || lower.contains('refund')) {
    return 'Pagamento estornado';
  }
  if (lower == 'cancelled' || lower == 'canceled' || lower == 'deleted') {
    return 'Pagamento cancelado';
  }

  // Evita exibir códigos técnicos crus demais.
  if (RegExp(r'^[A-Z_]+$').hasMatch(raw)) {
    return _mensagemPadraoPorStatus(status);
  }

  return raw;
}

String _mensagemPadraoPorStatus(String? status) {
  switch (status) {
    case StatusPagamento.pending:
      return 'Aguardando pagamento';
    case StatusPagamento.received:
      return 'Pagamento recebido';
    case StatusPagamento.confirmed:
      return 'Pagamento confirmado';
    case StatusPagamento.overdue:
      return 'Pagamento em atraso';
    case StatusPagamento.refunded:
      return 'Pagamento estornado';
    case StatusPagamento.cancelled:
    case StatusPagamento.deleted:
      return 'Pagamento cancelado';
    case StatusPagamento.failed:
      return 'Falha no pagamento';
    default:
      return '—';
  }
}

Color corStatusAssinatura(String? status) {
  switch (status) {
    case StatusAssinatura.active:
      return const Color(0xFF059669);
    case StatusAssinatura.expired:
      return ConvertixColors.error;
    case StatusAssinatura.inactive:
      return ConvertixColors.textMuted;
    default:
      return ConvertixColors.textSecondary;
  }
}
