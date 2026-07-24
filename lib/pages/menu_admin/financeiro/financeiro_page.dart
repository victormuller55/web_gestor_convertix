import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/date_format.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';
import 'package:web_gestor_site_covertix/models/financeiro_dashboard_model.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_page.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/financeiro/financeiro_state.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamento_detalhe_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamento_novo_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_page.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';

class FinanceiroPage extends StatefulWidget {
  const FinanceiroPage({super.key});

  @override
  State<FinanceiroPage> createState() => _FinanceiroPageState();
}

class _FinanceiroPageState extends State<FinanceiroPage> {
  final FinanceiroBloc bloc = FinanceiroBloc();
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _carregarPermissao();
    _loadData();
  }

  @override
  void dispose() {
    _isReloading.dispose();
    _isAdminNotifier.dispose();
    bloc.close();
    super.dispose();
  }

  Future<void> _carregarPermissao() async {
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    _isAdminNotifier.value = isAdmin;
  }

  void _loadData({bool forceRefresh = false}) {
    bloc.add(FinanceiroLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _onState(FinanceiroState state) {
    if (state is FinanceiroSuccessState || state is FinanceiroErrorState) {
      _isReloading.value = false;
    }
  }

  Future<void> _abrirNovoPagamento() async {
    final criado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PagamentoNovoDialog(),
      ),
    );
    if (criado == true) _loadData(forceRefresh: true);
  }

  void _abrirHistorico() => open(screen: const PagamentosPage());

  void _abrirAssinaturas() => open(screen: const AssinaturasPage());

  Future<void> _abrirDetalhe(int? id) async {
    if (id == null) return;
    final alterado = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PagamentoDetalheDialog(pagamentoId: id),
      ),
    );
    if (alterado == true) _loadData(forceRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Financeiro',
      centerTitle: false,
      hideBackIcon: true,
      appBarColor: ConvertixColors.surface,
      titleColor: ConvertixColors.textPrimary,
      background: ConvertixColors.background,
      actions: [
        ValueListenableBuilder<bool>(
          valueListenable: _isReloading,
          builder: (_, loading, __) => AppReloadButton(
            isLoading: loading,
            onPressed: _reload,
          ),
        ),
      ],
      body: BlocConsumer<FinanceiroBloc, FinanceiroState>(
        bloc: bloc,
        listenWhen: (prev, curr) =>
            curr is FinanceiroSuccessState || curr is FinanceiroErrorState,
        buildWhen: (prev, curr) =>
            curr is FinanceiroLoadingState ||
            curr is FinanceiroSuccessState ||
            curr is FinanceiroErrorState,
        listener: (_, state) => _onState(state),
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context, FinanceiroState state) {
    if (state is FinanceiroLoadingState) return appLoadingCovertix();
    if (state is FinanceiroErrorState) {
      return appError(state.errorModel, function: _loadData);
    }
    if (state is FinanceiroSuccessState) {
      return _content(state.dashboard, state.ultimos);
    }
    return appLoadingCovertix();
  }

  Widget _content(
    FinanceiroDashboardModel dashboard,
    List<PagamentoResumoModel> ultimos,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpacing.normal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _actionsBar(),
          appSizedBox(height: AppSpacing.medium),
          _statsGrid(dashboard),
          appSizedBox(height: AppSpacing.medium),
          _assinaturaCard(dashboard),
          appSizedBox(height: AppSpacing.medium),
          _ultimosCard(ultimos),
        ],
      ),
    );
  }

  Widget _actionsBar() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isAdminNotifier,
      builder: (_, isAdmin, __) {
        return Wrap(
          spacing: AppSpacing.normal,
          runSpacing: AppSpacing.normal,
          children: [
            if (isAdmin)
              appElevatedButtonCovertix(
                title: 'Novo pagamento',
                width: 200,
                height: 40,
                fontSize: AppFontSizes.verySmall,
                onTap: _abrirNovoPagamento,
              ),
            appElevatedButtonCovertixTransparent(
              title: 'Pagamentos e Faturas',
              width: 220,
              height: 40,
              onTap: _abrirHistorico,
            ),
            appElevatedButtonCovertixTransparent(
              title: 'Assinaturas',
              width: 160,
              height: 40,
              onTap: _abrirAssinaturas,
            ),
          ],
        );
      },
    );
  }

  int _crossAxisCount(double maxWidth) {
    if (maxWidth < 520) return 1;
    if (maxWidth < 900) return 2;
    return 4;
  }

  Widget _statsGrid(FinanceiroDashboardModel dashboard) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = _crossAxisCount(constraints.maxWidth);
        return GridView.count(
          crossAxisCount: count,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: AppSpacing.normal,
          mainAxisSpacing: AppSpacing.normal,
          childAspectRatio: count == 1 ? 3.2 : 2.2,
          children: [
            _statCard(
              'Total pago',
              formataDinheiro(dashboard.totalPago),
              Icons.check_circle_outline,
            ),
            _statCard(
              'Pendente',
              formataDinheiro(dashboard.totalPendente),
              Icons.schedule_outlined,
            ),
            _statCard(
              'Pagamentos',
              '${dashboard.quantidadePagamentos}',
              Icons.receipt_long_outlined,
            ),
            _statCard(
              'Pendentes',
              '${dashboard.quantidadePendentes}',
              Icons.pending_actions_outlined,
            ),
          ],
        );
      },
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return appContainer(
      padding: const EdgeInsets.all(20),
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusCard),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: ConvertixColors.primary, size: 22),
          appSizedBox(height: AppSpacing.normal),
          appText(
            value,
            fontSize: AppFontSizes.verySmall,
            bold: true,
            color: ConvertixColors.textPrimary,
          ),
          appText(label, color: ConvertixColors.textSecondary),
        ],
      ),
    );
  }

  Widget _assinaturaCard(FinanceiroDashboardModel dashboard) {
    return appContainer(
      padding: const EdgeInsets.all(20),
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusCard),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: appText(
                  'Assinatura',
                  bold: true,
                  color: ConvertixColors.textPrimary,
                ),
              ),
              financeiroStatusChip(
                dashboard.assinaturaAtiva ? 'ACTIVE' : 'INACTIVE',
                assinatura: true,
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.normal),
          if (dashboard.assinaturaAtiva) ...[
            appText(
              dashboard.descricaoAssinatura ?? 'Assinatura ativa',
              color: ConvertixColors.textSecondary,
            ),
            appSizedBox(height: AppSpacing.small),
            Wrap(
              spacing: AppSpacing.medium,
              runSpacing: AppSpacing.small,
              children: [
                _infoChip(
                  Icons.payments_outlined,
                  dashboard.valorAssinatura == null
                      ? '—'
                      : formataDinheiro(dashboard.valorAssinatura!),
                ),
                _infoChip(
                  Icons.credit_card_outlined,
                  labelFormaPagamento(dashboard.metodoPagamentoAssinatura),
                ),
                _infoChip(
                  Icons.event_outlined,
                  'Próx.: ${formatDateTable(dashboard.proximaCobranca)}',
                ),
              ],
            ),
          ] else
            appText(
              'Nenhuma assinatura ativa no momento.',
              color: ConvertixColors.textMuted,
            ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: ConvertixColors.primary),
        appSizedBox(width: 6),
        appText(text, color: ConvertixColors.textPrimary, fontSize: AppFontSizes.verySmall),
      ],
    );
  }

  Widget _ultimosCard(List<PagamentoResumoModel> ultimos) {
    return appContainer(
      padding: const EdgeInsets.all(20),
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusCard),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: appText(
                  'Últimos pagamentos',
                  bold: true,
                  color: ConvertixColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: _abrirHistorico,
                child: appText(
                  'Ver pagamentos e faturas',
                  color: ConvertixColors.primary,
                  fontSize: AppFontSizes.verySmall,
                  bold: true,
                ),
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.normal),
          if (ultimos.isEmpty)
            appText(
              'Nenhum pagamento encontrado.',
              color: ConvertixColors.textMuted,
            )
          else
            ...ultimos.map(_ultimoItem),
        ],
      ),
    );
  }

  Widget _ultimoItem(PagamentoResumoModel item) {
    return InkWell(
      onTap: () => _abrirDetalhe(item.id),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appText(
                    item.descricao ?? 'Pagamento',
                    bold: true,
                    color: ConvertixColors.textPrimary,
                    overflow: true,
                  ),
                  appText(
                    '${formatDateTable(item.createdAt)} · ${labelFormaPagamento(item.formaPagamento)}',
                    color: ConvertixColors.textMuted,
                    fontSize: AppFontSizes.verySmall,
                  ),
                ],
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                appText(
                  item.valor == null ? '—' : formataDinheiro(item.valor!),
                  bold: true,
                  color: ConvertixColors.textPrimary,
                ),
                appSizedBox(height: 4),
                financeiroStatusChip(item.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
