import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/pagamento_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamento_detalhe_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamento_novo_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/pagamentos/pagamentos_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class PagamentosPage extends StatefulWidget {
  final bool hideBackIcon;

  const PagamentosPage({super.key, this.hideBackIcon = false});

  @override
  State<PagamentosPage> createState() => _PagamentosPageState();
}

class _PagamentosPageState extends State<PagamentosPage> {
  final PagamentosBloc bloc = PagamentosBloc();
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);
  final ValueNotifier<List<PagamentoModel>> _pagamentosNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<ClienteModel>> _clientesNotifier =
      ValueNotifier(const []);
  final ValueNotifier<String?> _filtroStatus = ValueNotifier(null);
  final ValueNotifier<String?> _filtroForma = ValueNotifier(null);
  final ValueNotifier<int?> _filtroClienteId = ValueNotifier(null);

  List<PagamentoModel> _pageItems = [];

  int _page = 0;
  int _totalElements = 0;
  int _totalPages = 0;
  static const _size = PageResponse.defaultSize;

  static const _clienteFlex = 0.7;
  static const _descFlex = 0.9;
  static const _valorFlex = 0.35;
  static const _statusFlex = 0.4;
  static const _vencimentoFlex = 0.45;
  static const _pagamentoFlex = 0.55;

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
    _pagamentosNotifier.dispose();
    _clientesNotifier.dispose();
    _filtroStatus.dispose();
    _filtroForma.dispose();
    _filtroClienteId.dispose();
    bloc.close();
    super.dispose();
  }

  Future<void> _carregarPermissao() async {
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    _isAdminNotifier.value = isAdmin;
    if (isAdmin) {
      try {
        final clientes = await listarClientesLookup();
        if (!mounted) return;
        _clientesNotifier.value = clientes;
      } catch (_) {}
    }
  }

  void _loadData({int? page}) {
    if (page != null) _page = page;
    bloc.add(PagamentosLoadEvent(
      page: _page,
      size: _size,
    ));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(page: 0);
  }

  void _onPageChanged(int page) => _loadData(page: page);

  void _onState(PagamentosState state) {
    if (state is PagamentosSuccessState) {
      _page = state.page.page;
      _totalElements = state.page.totalElements;
      _totalPages = state.page.totalPages;
      _pageItems = List.from(state.pagamentos);
      _aplicarFiltros();
      _isReloading.value = false;
    }
    if (state is PagamentosErrorState) {
      _isReloading.value = false;
    }
    if (state is PagamentosActionSuccessState) {
      showToastSuccess(message: state.message);
      _loadData();
    }
  }

  void _aplicarFiltros() {
    final status = _filtroStatus.value;
    final forma = _filtroForma.value;
    final clienteId = _filtroClienteId.value;
    var filtrados = _pageItems;
    if (clienteId != null) {
      filtrados = filtrados.where((p) => p.clienteId == clienteId).toList();
    }
    if (status != null && status.isNotEmpty) {
      filtrados = filtrados.where((p) => p.status == status).toList();
    }
    if (forma != null && forma.isNotEmpty) {
      filtrados = filtrados.where((p) => p.formaPagamento == forma).toList();
    }
    _pagamentosNotifier.value = filtrados;
  }

  Future<void> _abrirNovo() async {
    if (!_isAdminNotifier.value) return;
    final criado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PagamentoNovoDialog(),
      ),
    );
    if (criado == true) _loadData(page: 0);
  }

  Future<void> _abrirDetalhe(PagamentoModel pagamento) async {
    if (pagamento.id == null) return;
    final alterado = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: PagamentoDetalheDialog(pagamentoId: pagamento.id!),
      ),
    );
    if (alterado == true) _loadData();
  }

  void _onCancelar(PagamentoModel pagamento) {
    if (!_isAdminNotifier.value) return;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || pagamento.id == null) return;
      final ok = await showAppConfirmDialog(
        context,
        title: 'Cancelar pagamento',
        message: 'Deseja cancelar o pagamento "${pagamento.descricao ?? ''}"?',
        icon: Icons.cancel_outlined,
        confirmLabel: 'Cancelar pagamento',
        destructive: true,
      );
      if (ok == true) {
        bloc.add(PagamentosCancelarEvent(pagamentoId: pagamento.id!));
      }
    });
  }

  void _onEstornar(PagamentoModel pagamento) {
    if (!_isAdminNotifier.value) return;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || pagamento.id == null) return;
      final ok = await showAppConfirmDialog(
        context,
        title: 'Estornar pagamento',
        message: 'Deseja estornar o pagamento "${pagamento.descricao ?? ''}"?',
        icon: Icons.undo_outlined,
        confirmLabel: 'Estornar',
        destructive: true,
      );
      if (ok == true) {
        bloc.add(PagamentosEstornarEvent(pagamentoId: pagamento.id!));
      }
    });
  }

  bool _temLinkPagamento(PagamentoModel p) {
    return p.invoiceUrl != null && p.invoiceUrl!.trim().isNotEmpty;
  }

  Future<void> _copiarLinkPagamento(PagamentoModel p) async {
    final url = p.invoiceUrl?.trim();
    if (url == null || url.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: url));
    showToastSuccess(message: 'Link de pagamento copiado');
  }

  void _abrirLinkPagamento(PagamentoModel p) {
    final url = p.invoiceUrl?.trim();
    if (url == null || url.isEmpty) return;
    openExternalLink(url);
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Pagamentos e Faturas',
      centerTitle: false,
      hideBackIcon: widget.hideBackIcon,
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
      body: BlocConsumer<PagamentosBloc, PagamentosState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        buildWhen: (prev, curr) =>
            curr is PagamentosLoadingState ||
            curr is PagamentosSuccessState ||
            curr is PagamentosErrorState,
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context, PagamentosState state) {
    if (state is PagamentosLoadingState) return appLoadingCovertix();
    if (state is PagamentosErrorState) {
      return appError(state.errorModel, function: () => _loadData());
    }
    return Padding(
      padding: EdgeInsets.all(AppSpacing.normal),
      child: Column(
        children: [
          _filters(),
          appSizedBox(height: AppSpacing.normal),
          Expanded(
            child: ValueListenableBuilder<List<PagamentoModel>>(
              valueListenable: _pagamentosNotifier,
              builder: (_, pagamentos, __) => _table(pagamentos),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters() {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: AppSpacing.normal,
        runSpacing: AppSpacing.normal,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: ValueListenableBuilder<String?>(
              valueListenable: _filtroStatus,
              builder: (_, value, __) => covertixDropdownFormField<String?>(
                value: value,
                hint: 'Status',
                withTopInset: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos status')),
                  ...StatusPagamento.todos.map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(labelStatusPagamento(s)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  _filtroStatus.value = v;
                  _aplicarFiltros();
                },
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: ValueListenableBuilder<String?>(
              valueListenable: _filtroForma,
              builder: (_, value, __) => covertixDropdownFormField<String?>(
                value: value,
                hint: 'Forma',
                withTopInset: true,
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todas formas')),
                  ...FormaPagamento.todos.map(
                    (f) => DropdownMenuItem(
                      value: f,
                      child: Text(labelFormaPagamento(f)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  _filtroForma.value = v;
                  _aplicarFiltros();
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isAdminNotifier,
            builder: (_, isAdmin, __) {
              if (!isAdmin) return const SizedBox.shrink();
              return SizedBox(
                width: 220,
                child: ValueListenableBuilder<List<ClienteModel>>(
                  valueListenable: _clientesNotifier,
                  builder: (_, clientes, __) {
                    return ValueListenableBuilder<int?>(
                      valueListenable: _filtroClienteId,
                      builder: (_, value, __) => covertixDropdownFormField<int?>(
                        value: value,
                        hint: 'Cliente',
                        withTopInset: true,
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos clientes'),
                          ),
                          ...clientes.where((c) => c.id != null).map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(
                                    c.nomeEmpresa ?? 'Cliente ${c.id}',
                                  ),
                                ),
                              ),
                        ],
                        onChanged: (v) {
                          _filtroClienteId.value = v;
                          _aplicarFiltros();
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isAdminNotifier,
            builder: (_, isAdmin, __) {
              if (!isAdmin) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 10),
                child: appElevatedButtonCovertix(
                  title: 'Novo pagamento',
                  width: 200,
                  height: 40,
                  fontSize: AppFontSizes.verySmall,
                  onTap: _abrirNovo,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _table(List<PagamentoModel> pagamentos) {
    return AppTable(
      expand: false,
      rowsPerPage: _size,
      headers: [
        cellHeaderAction(),
        cellHeader('Cliente', _clienteFlex),
        cellHeader('Descrição', _descFlex),
        cellHeader('Valor', _valorFlex),
        cellHeader('Status', _statusFlex),
        cellHeader('Data de vencimento', _vencimentoFlex),
        cellHeader('Data do pagamento', _pagamentoFlex),
      ],
      itemCount: pagamentos.length,
      rowBuilder: (index) => _row(pagamentos[index]),
      page: _page,
      totalElements: _totalElements,
      totalPages: _totalPages <= 0 ? 1 : _totalPages,
      onPageChanged: _onPageChanged,
    );
  }

  Widget _row(PagamentoModel p) {
    return appTableRow(
      key: ValueKey(p.id),
      columns: [
        cellAction(_popup(p)),
        cellName(p.clienteNomeEmpresa ?? '—', flex: _clienteFlex),
        cellText(p.descricao ?? '—', _descFlex),
        cellMoney(p.valor, _valorFlex),
        cell(
          flex: _statusFlex,
          child: financeiroStatusChip(p.status),
        ),
        cellDate(p.dataVencimento, _vencimentoFlex),
        cellDateTime(p.dataConfirmacao, _pagamentoFlex, showDivider: false),
      ],
    );
  }

  Widget _popup(PagamentoModel p) {
    final isAdmin = _isAdminNotifier.value;
    final temLink = _temLinkPagamento(p);
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: ConvertixColors.surface,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => [
        _menuItem(Icons.visibility_outlined, 'Detalhes', () => _abrirDetalhe(p)),
        if (temLink)
          _menuItem(
            Icons.link_outlined,
            'Ir para pagamento',
            () => _abrirLinkPagamento(p),
          ),
        if (temLink)
          _menuItem(
            Icons.copy_outlined,
            'Copiar link',
            () => _copiarLinkPagamento(p),
          ),
        if (isAdmin && StatusPagamento.podeCancelar(p.status))
          _menuItem(Icons.cancel_outlined, 'Cancelar', () => _onCancelar(p)),
        if (isAdmin && StatusPagamento.podeEstornar(p.status))
          _menuItem(
            Icons.undo_outlined,
            'Estornar',
            () => _onEstornar(p),
            color: AppColors.red,
            textColor: AppColors.white,
          ),
      ],
    );
  }

  PopupMenuItem<void> _menuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
    Color? textColor,
  }) {
    return PopupMenuItem(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: appContainer(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Row(
          children: [
            Icon(icon, color: textColor ?? AppColors.grey700),
            SizedBox(width: AppSpacing.normal),
            appText(title, color: textColor ?? AppColors.grey700),
          ],
        ),
      ),
    );
  }
}
