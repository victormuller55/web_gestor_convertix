import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/debounce.dart';
import 'package:web_gestor_site_covertix/function/financeiro_labels.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/assinatura_model.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/models/plano_assinatura.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinatura_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinatura_detalhe_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/assinaturas/assinaturas_state.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_input_decorations.dart';
import 'package:web_gestor_site_covertix/widgets/financeiro_status_chip.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class AssinaturasPage extends StatefulWidget {
  final bool hideBackIcon;

  const AssinaturasPage({super.key, this.hideBackIcon = false});

  @override
  State<AssinaturasPage> createState() => _AssinaturasPageState();
}

class _AssinaturasPageState extends State<AssinaturasPage> {
  final AssinaturasBloc bloc = AssinaturasBloc();
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);
  final ValueNotifier<List<AssinaturaModel>> _filtradasNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<ClienteModel>> _clientesNotifier =
      ValueNotifier(const []);
  final ValueNotifier<String?> _filtroStatus = ValueNotifier(null);
  final ValueNotifier<String?> _filtroCiclo = ValueNotifier(null);
  final ValueNotifier<String?> _filtroProduto = ValueNotifier(null);
  final ValueNotifier<int?> _filtroClienteId = ValueNotifier(null);

  final TextEditingController _buscaController = TextEditingController();
  final Debouncer _buscaDebouncer = Debouncer();
  List<AssinaturaModel> _allAssinaturas = [];
  String _busca = '';

  static const _filterHeight = 48.0;
  static const _filterWidth = 200.0;
  static const _searchWidth = 260.0;

  static const _clienteFlex = 0.55;
  static const _produtoFlex = 0.55;
  static const _siteFlex = 0.45;
  static const _valorFlex = 0.3;
  static const _cicloFlex = 0.3;
  static const _statusFlex = 0.3;
  static const _formaFlex = 0.35;
  static const _dataFlex = 0.4;

  @override
  void initState() {
    super.initState();
    _carregarPermissao();
    _loadData();
  }

  @override
  void dispose() {
    _buscaDebouncer.dispose();
    _buscaController.dispose();
    _isReloading.dispose();
    _isAdminNotifier.dispose();
    _filtradasNotifier.dispose();
    _clientesNotifier.dispose();
    _filtroStatus.dispose();
    _filtroCiclo.dispose();
    _filtroProduto.dispose();
    _filtroClienteId.dispose();
    bloc.close();
    super.dispose();
  }

  Widget _searchField() {
    return CovertixHoverInput(
      builder: (context, isHovered) {
        return TextField(
          controller: _buscaController,
          onChanged: _onBusca,
          style: TextStyle(
            fontFamily: 'lato',
            fontSize: AppFontSizes.verySmall,
            color: ConvertixColors.textPrimary,
            letterSpacing: 1,
            height: 1.2,
          ),
          decoration: covertixInputDecoration(
            hint: 'Buscar cliente, produto...',
            borderColor: ConvertixColors.border,
            isHovered: isHovered,
            fillColor: ConvertixColors.inputFill,
            prefixIcon: const Icon(
              Icons.search,
              color: ConvertixColors.primary,
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 48,
              maxHeight: 48,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
          ),
        );
      },
    );
  }

  Future<void> _carregarPermissao() async {
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    _isAdminNotifier.value = isAdmin;
    if (isAdmin) {
      try {
        final clientes = await listarClientes();
        if (!mounted) return;
        _clientesNotifier.value = clientes;
      } catch (_) {}
    }
  }

  void _onBusca(String termo) {
    _buscaDebouncer.run(() {
      _busca = termo.trim().toLowerCase();
      _aplicarFiltros();
    });
  }

  void _loadData({bool forceRefresh = false}) {
    bloc.add(AssinaturasLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _onState(AssinaturasState state) {
    if (state is AssinaturasSuccessState) {
      _allAssinaturas = state.assinaturas;
      _aplicarFiltros();
      _isReloading.value = false;
    }
    if (state is AssinaturasErrorState) {
      _isReloading.value = false;
    }
    if (state is AssinaturasActionSuccessState) {
      showToastSuccess(message: state.message);
      _loadData(forceRefresh: true);
    }
  }

  void _aplicarFiltros() {
    final status = _filtroStatus.value;
    final ciclo = _filtroCiclo.value;
    final produto = _filtroProduto.value;
    final clienteId = _filtroClienteId.value;

    _filtradasNotifier.value = _allAssinaturas.where((a) {
      if (status != null && a.status != status) return false;
      if (clienteId != null && a.clienteId != clienteId) return false;
      if (ciclo != null && a.ciclo != ciclo) return false;
      if (produto != null) {
        final label = labelProdutoAssinatura(a);
        if (produto == 'OUTRO') {
          final conhecido = PlanoAssinatura.todos.any(
            (p) => !p.manual && p.titulo == label,
          );
          if (conhecido) return false;
        } else {
          final esperado = PlanoAssinatura.porTipoSite(produto).titulo;
          if (label != esperado) return false;
        }
      }
      if (_busca.isNotEmpty) {
        final haystack = [
          a.clienteNomeEmpresa,
          labelProdutoAssinatura(a),
          a.siteNome,
          a.descricao,
        ].whereType<String>().join(' ').toLowerCase();
        if (!haystack.contains(_busca)) return false;
      }
      return true;
    }).toList();
  }

  Future<void> _abrirCadastro() async {
    if (!_isAdminNotifier.value) return;
    final criado = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: AssinaturaCadastro(),
      ),
    );
    if (criado == true) _loadData(forceRefresh: true);
  }

  Future<void> _abrirDetalhe(AssinaturaModel a) async {
    if (a.id == null) return;
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: AssinaturaDetalheDialog(assinaturaId: a.id!),
      ),
    );
    if (changed == true) _loadData(forceRefresh: true);
  }

  void _onCancelar(AssinaturaModel a) {
    if (!_isAdminNotifier.value) return;
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || a.id == null) return;
      final ok = await showAppConfirmDialog(
        context,
        title: 'Cancelar assinatura',
        message:
            'Deseja cancelar a assinatura de "${a.clienteNomeEmpresa ?? 'cliente'}"?',
        icon: Icons.cancel_outlined,
        confirmLabel: 'Cancelar assinatura',
        destructive: true,
      );
      if (ok == true) {
        bloc.add(AssinaturasCancelarEvent(assinaturaId: a.id!));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Assinaturas',
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
      body: BlocConsumer<AssinaturasBloc, AssinaturasState>(
        bloc: bloc,
        listener: (_, state) => _onState(state),
        buildWhen: (prev, curr) =>
            curr is AssinaturasLoadingState ||
            curr is AssinaturasSuccessState ||
            curr is AssinaturasErrorState,
        builder: _buildBody,
      ),
    );
  }

  Widget _buildBody(BuildContext context, AssinaturasState state) {
    if (state is AssinaturasLoadingState) return appLoadingCovertix();
    if (state is AssinaturasErrorState) {
      return appError(state.errorModel, function: _loadData);
    }
    return Padding(
      padding: EdgeInsets.all(AppSpacing.normal),
      child: Column(
        children: [
          _filters(),
          appSizedBox(height: AppSpacing.normal),
          Expanded(
            child: ValueListenableBuilder<List<AssinaturaModel>>(
              valueListenable: _filtradasNotifier,
              builder: (_, filtradas, __) => _table(filtradas),
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
          covertixFilterBarItem(
            width: _searchWidth,
            height: _filterHeight,
            child: _searchField(),
          ),
          covertixFilterBarItem(
            width: _filterWidth,
            height: _filterHeight,
            child: ValueListenableBuilder<String?>(
              valueListenable: _filtroStatus,
              builder: (_, value, __) => covertixDropdownFormField<String?>(
                value: value,
                hint: 'Status',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos status')),
                  ...StatusAssinatura.todos.map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(labelStatusAssinatura(s)),
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
          covertixFilterBarItem(
            width: _filterWidth,
            height: _filterHeight,
            child: ValueListenableBuilder<String?>(
              valueListenable: _filtroCiclo,
              builder: (_, value, __) => covertixDropdownFormField<String?>(
                value: value,
                hint: 'Ciclo',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos ciclos')),
                  ...CicloAssinatura.todos.map(
                    (c) => DropdownMenuItem(
                      value: c,
                      child: Text(labelCicloAssinatura(c)),
                    ),
                  ),
                ],
                onChanged: (v) {
                  _filtroCiclo.value = v;
                  _aplicarFiltros();
                },
              ),
            ),
          ),
          covertixFilterBarItem(
            width: _filterWidth,
            height: _filterHeight,
            child: ValueListenableBuilder<String?>(
              valueListenable: _filtroProduto,
              builder: (_, value, __) => covertixDropdownFormField<String?>(
                value: value,
                hint: 'Produto',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos produtos')),
                  ...PlanoAssinatura.todos.where((p) => !p.manual).map(
                        (p) => DropdownMenuItem(
                          value: p.tipoSite,
                          child: Text(p.titulo),
                        ),
                      ),
                  const DropdownMenuItem(value: 'OUTRO', child: Text('Outro')),
                ],
                onChanged: (v) {
                  _filtroProduto.value = v;
                  _aplicarFiltros();
                },
              ),
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: _isAdminNotifier,
            builder: (_, isAdmin, __) {
              if (!isAdmin) return const SizedBox.shrink();
              return covertixFilterBarItem(
                width: _filterWidth,
                height: _filterHeight,
                child: ValueListenableBuilder<List<ClienteModel>>(
                  valueListenable: _clientesNotifier,
                  builder: (_, clientes, __) {
                    return ValueListenableBuilder<int?>(
                      valueListenable: _filtroClienteId,
                      builder: (_, value, __) => covertixDropdownFormField<int?>(
                        value: value,
                        hint: 'Cliente',
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('Todos clientes'),
                          ),
                          ...clientes.where((c) => c.id != null).map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.nomeEmpresa ?? 'Cliente ${c.id}'),
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
              return covertixFilterBarItem(
                width: _filterWidth,
                height: _filterHeight,
                child: appElevatedButtonCovertix(
                  title: 'Nova assinatura',
                  width: _filterWidth,
                  height: _filterHeight,
                  fontSize: AppFontSizes.verySmall,
                  onTap: _abrirCadastro,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _table(List<AssinaturaModel> assinaturas) {
    return AppTable(
      expand: false,
      rowsPerPage: 20,
      headers: [
        cellHeaderAction(),
        cellHeader('Cliente', _clienteFlex),
        cellHeader('Produto', _produtoFlex),
        cellHeader('Site', _siteFlex),
        cellHeader('Valor', _valorFlex),
        cellHeader('Ciclo', _cicloFlex),
        cellHeader('Status', _statusFlex),
        cellHeader('Forma', _formaFlex),
        cellHeader('Próx. cobrança', _dataFlex),
      ],
      itemCount: assinaturas.length,
      rowBuilder: (index) => _row(assinaturas[index]),
    );
  }

  Widget _row(AssinaturaModel a) {
    return appTableRow(
      key: ValueKey(a.id),
      columns: [
        cellAction(_popup(a)),
        cellName(a.clienteNomeEmpresa ?? '—', flex: _clienteFlex),
        cellText(labelProdutoAssinatura(a), _produtoFlex),
        cellText(
          (a.siteNome == null || a.siteNome!.trim().isEmpty)
              ? '—'
              : a.siteNome!.trim(),
          _siteFlex,
        ),
        cellMoney(a.valor, _valorFlex),
        cellText(labelCicloAssinatura(a.ciclo), _cicloFlex),
        cell(
          flex: _statusFlex,
          child: financeiroStatusChip(a.status, assinatura: true),
        ),
        cellText(labelFormaPagamento(a.formaPagamento), _formaFlex),
        cellDate(a.proximaCobranca, _dataFlex, showDivider: false),
      ],
    );
  }

  Widget _popup(AssinaturaModel a) {
    final isAdmin = _isAdminNotifier.value;
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: ConvertixColors.surface,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => [
        PopupMenuItem(
          padding: EdgeInsets.zero,
          onTap: () => _abrirDetalhe(a),
          child: _menuRow(Icons.visibility_outlined, 'Detalhes'),
        ),
        if (isAdmin && a.status == StatusAssinatura.active)
          PopupMenuItem(
            padding: EdgeInsets.zero,
            onTap: () => _onCancelar(a),
            child: _menuRow(
              Icons.cancel_outlined,
              'Cancelar',
              color: AppColors.red,
              textColor: AppColors.white,
            ),
          ),
      ],
    );
  }

  Widget _menuRow(
    IconData icon,
    String title, {
    Color? color,
    Color? textColor,
  }) {
    return appContainer(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? AppColors.grey700),
          SizedBox(width: AppSpacing.normal),
          appText(title, color: textColor ?? AppColors.grey700),
        ],
      ),
    );
  }
}
