import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/debounce.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class SitesPage extends StatefulWidget {
  final String? tipoFiltro;
  final String? tituloPagina;

  const SitesPage({
    super.key,
    this.tipoFiltro,
    this.tituloPagina,
  });

  @override
  State<SitesPage> createState() => _SitesPageState();
}

class _SitesPageState extends State<SitesPage> {
  final SitesBloc bloc = SitesBloc();

  late AppFormField _formSearch;
  late List<SiteModel> _pageItems;
  late ValueNotifier<List<SiteModel>> _sitesNotifier;
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);
  final ValueNotifier<int?> _clienteIdLogadoNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final ValueNotifier<String?> _filtroStatus = ValueNotifier(null);
  final ValueNotifier<String?> _filtroTipo = ValueNotifier(null);
  final ValueNotifier<String?> _filtroSituacaoAssinatura = ValueNotifier(null);
  final ValueNotifier<String?> _filtroDominio = ValueNotifier(null);
  final Debouncer _buscaDebouncer = Debouncer();
  String _busca = '';

  int _page = 0;
  int _totalElements = 0;
  int _totalPages = 0;
  static const _size = PageResponse.defaultSize;

  String get _titulo => widget.tituloPagina ?? 'Sites';
  bool get _tipoFixo =>
      widget.tipoFiltro != null && widget.tipoFiltro!.isNotEmpty;

  static const _filterWidth = 180.0;

  static const _idFlex = 0.25;
  static const _nomeFlex = 0.55;
  static const _clienteFlex = 0.65;
  static const _tipoFlex = 0.35;
  static const _subdominioFlex = 0.35;
  static const _dominioFlex = 0.45;
  static const _situacaoFlex = 0.4;
  static const _valorFlex = 0.35;
  static const _diasFlex = 0.3;
  static const _vencFlex = 0.4;
  static const _compraFlex = 0.4;
  static const _renovFlex = 0.4;
  static const _statusFlex = 0.32;
  static const _dataFlex = 0.45;

  @override
  void initState() {
    super.initState();
    _pageItems = [];
    _sitesNotifier = ValueNotifier<List<SiteModel>>([]);
    _initFormSearch();
    _carregarUsuario();
    _loadData();
  }

  @override
  void dispose() {
    _buscaDebouncer.dispose();
    _formSearch.controller.dispose();
    _sitesNotifier.dispose();
    _isAdminNotifier.dispose();
    _clienteIdLogadoNotifier.dispose();
    _isReloading.dispose();
    _filtroStatus.dispose();
    _filtroTipo.dispose();
    _filtroSituacaoAssinatura.dispose();
    _filtroDominio.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _titulo,
      centerTitle: false,
      hideBackIcon: true,
      appBarColor: ConvertixColors.surface,
      titleColor: ConvertixColors.textPrimary,
      background: ConvertixColors.background,
      actions: _scaffoldActions(),
      body: _bodyBuilder(),
    );
  }

  void _initFormSearch() {
    _formSearch = AppFormField(
      context: context,
      width: 300,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: ConvertixColors.inputFill,
      icon: const Icon(Icons.search, color: ConvertixColors.primary),
      hint: AppStrings.digiteAlgoParaPesquisar,
      onChange: _onBusca,
    );
  }

  List<SiteModel> _filtrarPorTipoPagina(List<SiteModel> sites) {
    final tipo = widget.tipoFiltro;
    if (tipo == null || tipo.isEmpty) return sites;
    return sites.where((s) => s.tipo == tipo).toList();
  }

  void _loadData({int? page}) {
    if (page != null) _page = page;
    bloc.add(SitesLoadEvent(
      query: _busca.isEmpty ? null : _busca,
      page: _page,
      size: _size,
    ));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(page: 0);
  }

  void _onBusca(String termo) {
    _buscaDebouncer.run(() {
      _busca = termo.trim();
      _loadData(page: 0);
    });
  }

  void _onPageChanged(int page) => _loadData(page: page);

  void _aplicarFiltros() {
    final status = _filtroStatus.value;
    final tipo = _filtroTipo.value;
    final situacao = _filtroSituacaoAssinatura.value;
    final dominioFiltro = _filtroDominio.value;

    _sitesNotifier.value = _pageItems.where((s) {
      if (status != null && s.status != status) return false;
      if (!_tipoFixo && tipo != null && s.tipo != tipo) return false;
      if (situacao != null &&
          (s.situacaoAssinatura ?? SituacaoAssinaturaSite.desativado) !=
              situacao) {
        return false;
      }
      if (dominioFiltro == 'COM' &&
          (s.dominio == null || s.dominio!.trim().isEmpty)) {
        return false;
      }
      if (dominioFiltro == 'SEM' &&
          s.dominio != null &&
          s.dominio!.trim().isNotEmpty) {
        return false;
      }
      return true;
    }).toList();
  }

  void _onChangeState(SitesState state) {
    if (state is SitesSuccessState) {
      _page = state.page.page;
      _totalElements = state.page.totalElements;
      _totalPages = state.page.totalPages;
      _pageItems = _filtrarPorTipoPagina(state.sites);
      _aplicarFiltros();
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is SitesErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is SitesDeleteSuccessState) {
      showToastSuccess(message: 'Site excluído com sucesso');
      _loadData();
    }
  }

  Future<void> _carregarUsuario() async {
    final usuario = await getUsuarioLogado();
    if (!mounted) return;
    _isAdminNotifier.value = usuario?.isAdmin ?? false;
    _clienteIdLogadoNotifier.value = usuario?.clienteId;
  }

  void _onCadastrarNovo() => _abrirCadastro();

  Future<void> _abrirCadastro({SiteModel? site}) async {
    if (site == null && !_isAdminNotifier.value) {
      showToastError(message: 'Apenas administradores podem cadastrar sites.');
      return;
    }
    final siteInicial = site ??
        SiteModel.empty(
          clienteId:
              _isAdminNotifier.value ? null : _clienteIdLogadoNotifier.value,
        );
    final salvo = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(siteInicial),
    );
    if (salvo == true) _loadData(page: 0);
  }

  String? _urlSite(SiteModel site) {
    return urlPublicaSite(dominio: site.dominio, subdominio: site.subdominio);
  }

  String _textoOuTraco(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value;
  }

  void _onEditar(SiteModel site) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _abrirCadastro(site: site);
    });
  }

  void _onAbrirSite(SiteModel site) {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final url = _urlSite(site);
      if (url == null) {
        showToastError(message: 'Site sem domínio ou subdomínio configurado');
        return;
      }
      await openExternalLink(url);
    });
  }

  void _onExcluir(SiteModel site) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confirmarExclusao(site);
    });
  }

  Future<void> _confirmarExclusao(SiteModel site) async {
    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Excluir site',
      message: 'Deseja excluir o site ${site.nome ?? '?'}?',
      icon: Icons.delete_outline,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmado == true && site.id != null) {
      bloc.add(SitesDeleteEvent(siteId: site.id!));
    }
  }

  Widget _cadastroDialog(SiteModel siteInicial) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: SitesCadastro(
        site: siteInicial,
        isDialog: true,
        isAdmin: _isAdminNotifier.value,
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<SitesBloc, SitesState>(
      bloc: bloc,
      listener: (_, state) => _onChangeState(state),
      buildWhen: (previous, current) =>
          current is SitesLoadingState ||
          current is SitesSuccessState ||
          current is SitesErrorState,
      builder: _buildBlocBody,
    );
  }

  Widget _buildBlocBody(BuildContext context, SitesState state) {
    if (state is SitesLoadingState) return appLoadingCovertix();
    if (state is SitesErrorState) {
      return appError(state.errorModel, function: () => _loadData());
    }
    return _sitesListBody();
  }

  Widget _sitesListBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isAdminNotifier,
      builder: (_, isAdmin, __) {
        return ValueListenableBuilder<List<SiteModel>>(
          valueListenable: _sitesNotifier,
          builder: (_, sites, ___) => _body(sites, isAdmin),
        );
      },
    );
  }

  List<Widget> _scaffoldActions() {
    return [
      ValueListenableBuilder<bool>(
        valueListenable: _isReloading,
        builder: (_, loading, __) => AppReloadButton(
          isLoading: loading,
          onPressed: _reload,
        ),
      ),
    ];
  }

  PopupMenuItem<void> _popupItemMenu({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
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

  List<PopupMenuEntry<void>> _popupMenuItems(SiteModel site) {
    final podeAbrir = _urlSite(site) != null;
    return [
      _popupItemMenu(
        icon: Icons.edit_outlined,
        title: 'Editar',
        onTap: () => _onEditar(site),
      ),
      _popupItemMenu(
        icon: Icons.open_in_new,
        title: 'Abrir site',
        color: podeAbrir ? ConvertixColors.primaryLight : AppColors.grey200,
        textColor:
            podeAbrir ? ConvertixColors.primaryDark : ConvertixColors.textMuted,
        onTap: () => _onAbrirSite(site),
      ),
      _popupItemMenu(
        icon: Icons.delete_outline,
        title: 'Excluir',
        color: AppColors.red,
        textColor: AppColors.white,
        onTap: () => _onExcluir(site),
      ),
    ];
  }

  Widget _popupMenu(SiteModel site) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: ConvertixColors.surface,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => _popupMenuItems(site),
    );
  }

  Widget _cadastrarButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: appElevatedButtonCovertix(
        title: AppStrings.cadastrarNovo,
        width: 220,
        height: 40,
        fontSize: AppFontSizes.verySmall,
        onTap: _onCadastrarNovo,
      ),
    );
  }

  Widget _filtroDropdown<T>({
    required ValueNotifier<T?> notifier,
    required String hint,
    required List<DropdownMenuItem<T?>> items,
  }) {
    return covertixFilterBarItem(
      width: _filterWidth,
      child: ValueListenableBuilder<T?>(
        valueListenable: notifier,
        builder: (_, value, __) => covertixDropdownFormField<T?>(
          value: value,
          hint: hint,
          withTopInset: false,
          items: items,
          onChanged: (v) {
            notifier.value = v;
            _aplicarFiltros();
          },
        ),
      ),
    );
  }

  Widget _filters(bool isAdmin) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.normal),
        child: Wrap(
          spacing: AppSpacing.normal,
          runSpacing: AppSpacing.normal,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _formSearch.formulario,
            _filtroDropdown<String>(
              notifier: _filtroStatus,
              hint: 'Status',
              items: [
                const DropdownMenuItem(value: null, child: Text('Todos status')),
                DropdownMenuItem(
                  value: StatusSite.ativo,
                  child: Text(SiteModel.labelStatus(StatusSite.ativo)),
                ),
                DropdownMenuItem(
                  value: StatusSite.inativo,
                  child: Text(SiteModel.labelStatus(StatusSite.inativo)),
                ),
                DropdownMenuItem(
                  value: StatusSite.emDesenvolvimento,
                  child: Text(
                    SiteModel.labelStatus(StatusSite.emDesenvolvimento),
                  ),
                ),
              ],
            ),
            if (!_tipoFixo)
              _filtroDropdown<String>(
                notifier: _filtroTipo,
                hint: 'Tipo',
                items: [
                  const DropdownMenuItem(value: null, child: Text('Todos tipos')),
                  DropdownMenuItem(
                    value: TipoSite.biolink,
                    child: Text(SiteModel.labelTipo(TipoSite.biolink)),
                  ),
                  DropdownMenuItem(
                    value: TipoSite.landingPage,
                    child: Text(SiteModel.labelTipo(TipoSite.landingPage)),
                  ),
                  DropdownMenuItem(
                    value: TipoSite.siteComercial,
                    child: Text(SiteModel.labelTipo(TipoSite.siteComercial)),
                  ),
                ],
              ),
            _filtroDropdown<String>(
              notifier: _filtroSituacaoAssinatura,
              hint: 'Assinatura',
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('Todas situações'),
                ),
                ...SituacaoAssinaturaSite.todos.map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(SiteModel.labelSituacaoAssinatura(s)),
                  ),
                ),
              ],
            ),
            _filtroDropdown<String>(
              notifier: _filtroDominio,
              hint: 'Domínio',
              items: const [
                DropdownMenuItem(value: null, child: Text('Todos domínios')),
                DropdownMenuItem(value: 'COM', child: Text('Com domínio')),
                DropdownMenuItem(value: 'SEM', child: Text('Sem domínio')),
              ],
            ),
            if (isAdmin) _cadastrarButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _tableHeaders(bool isAdmin) {
    return [
      cellHeaderAction(),
      if (isAdmin) cellHeader('ID', _idFlex),
      cellHeader('Nome', _nomeFlex),
      if (isAdmin) cellHeader('Cliente', _clienteFlex),
      cellHeader('Tipo', _tipoFlex),
      cellHeader('Subdomínio', _subdominioFlex),
      cellHeader('Domínio', _dominioFlex),
      cellHeader('Situação Assinatura', _situacaoFlex),
      cellHeader('Valor', _valorFlex),
      cellHeader('Dias', _diasFlex),
      cellHeader('Vencimento', _vencFlex),
      cellHeader('Compra', _compraFlex),
      cellHeader('Renovação', _renovFlex),
      cellHeader('Status', _statusFlex),
      cellHeader('Criado em', _dataFlex),
      cellHeader('Alterado em', _dataFlex),
    ];
  }

  Widget _tableRow(SiteModel site, bool isAdmin) {
    final info = site.dominioInfo;
    final url = _urlSite(site);
    return appTableRow(
      key: ValueKey(site.id ?? site.nome),
      columns: [
        cellAction(_popupMenu(site)),
        if (isAdmin) cellText(site.id?.toString() ?? '—', _idFlex),
        cellName(site.nome ?? '', flex: _nomeFlex),
        if (isAdmin) cellText(site.clienteNomeEmpresa ?? '—', _clienteFlex),
        cellText(SiteModel.labelTipo(site.tipo), _tipoFlex),
        cellText(_textoOuTraco(site.subdominio), _subdominioFlex),
        cellLink(site.dominio, _dominioFlex, href: url),
        cellSituacaoAssinatura(
          site.situacaoAssinatura ?? SituacaoAssinaturaSite.desativado,
          _situacaoFlex,
        ),
        cellMoney(info?.valorDominio, _valorFlex),
        cellDuracaoDominio(info?.duracaoDominio, _diasFlex),
        cellDate(info?.dataFimDominio, _vencFlex),
        cellDate(info?.dataCompraDominio, _compraFlex),
        cellDate(info?.dataRenovacao, _renovFlex),
        cellSiteStatus(site.status, _statusFlex),
        cellDateTime(site.createdAt, _dataFlex),
        cellDateTime(site.updatedAt, _dataFlex, showDivider: false),
      ],
    );
  }

  Widget _table(List<SiteModel> sites, bool isAdmin) {
    return AppTable(
      rowsPerPage: _size,
      headers: _tableHeaders(isAdmin),
      itemCount: sites.length,
      rowBuilder: (index) => _tableRow(sites[index], isAdmin),
      page: _page,
      totalElements: _totalElements,
      totalPages: _totalPages <= 0 ? 1 : _totalPages,
      onPageChanged: _onPageChanged,
    );
  }

  Widget _body(List<SiteModel> sites, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.normal,
        left: AppSpacing.normal,
        bottom: AppSpacing.normal,
      ),
      child: Column(
        children: [
          _filters(isAdmin),
          _table(sites, isAdmin),
        ],
      ),
    );
  }
}
