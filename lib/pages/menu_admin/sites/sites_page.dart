import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
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
  late List<SiteModel> _allSites;
  late ValueNotifier<List<SiteModel>> _sitesNotifier;
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);
  final ValueNotifier<int?> _clienteIdLogadoNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);

  String get _titulo => widget.tituloPagina ?? 'Sites';

  static const _idFlex = 0.25;
  static const _nomeFlex = 0.55;
  static const _clienteFlex = 0.65;
  static const _tipoFlex = 0.35;
  static const _subdominioFlex = 0.35;
  static const _dominioFlex = 0.45;
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
    _allSites = [];
    _sitesNotifier = ValueNotifier<List<SiteModel>>([]);
    _initFormSearch();
    _carregarUsuario();
    _loadData();
  }

  @override
  void dispose() {
    _formSearch.controller.dispose();
    _sitesNotifier.dispose();
    _isAdminNotifier.dispose();
    _clienteIdLogadoNotifier.dispose();
    _isReloading.dispose();
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
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.search, color: ConvertixColors.primary),
      hint: AppStrings.digiteAlgoParaPesquisar,
      onChange: _search,
    );
  }

  List<SiteModel> _filtrarPorTipo(List<SiteModel> sites) {
    final tipo = widget.tipoFiltro;
    if (tipo == null || tipo.isEmpty) return sites;
    return sites.where((s) => s.tipo == tipo).toList();
  }

  void _loadData({bool forceRefresh = false}) {
    bloc.add(SitesLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _search(String termo) {
    termo = termo.toLowerCase();
    final filtrados = _allSites.where((s) {
      final id = s.id?.toString() ?? '';
      final nome = s.nome?.toLowerCase() ?? '';
      final cliente = s.clienteNomeEmpresa?.toLowerCase() ?? '';
      final tipo = SiteModel.labelTipo(s.tipo).toLowerCase();
      final dominio = s.dominio?.toLowerCase() ?? '';
      final subdominio = s.subdominio?.toLowerCase() ?? '';
      final status = SiteModel.labelStatus(s.status).toLowerCase();
      return id.contains(termo) ||
          nome.contains(termo) ||
          cliente.contains(termo) ||
          tipo.contains(termo) ||
          dominio.contains(termo) ||
          subdominio.contains(termo) ||
          status.contains(termo);
    }).toList();
    _sitesNotifier.value = filtrados;
  }

  void _onChangeState(SitesState state) {
    if (state is SitesSuccessState) {
      _allSites = _filtrarPorTipo(state.sites);
      _sitesNotifier.value = List.from(_allSites);
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is SitesErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is SitesDeleteSuccessState) {
      showToastSuccess(message: 'Site excluído com sucesso');
      _loadData(forceRefresh: true);
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
          clienteId: _isAdminNotifier.value ? null : _clienteIdLogadoNotifier.value,
        );
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(siteInicial),
    );
    _loadData();
  }

  String? _urlSite(SiteModel site) {
    final dominio = site.dominio?.trim();
    if (dominio != null && dominio.isNotEmpty) return dominio;
    final subdominio = site.subdominio?.trim();
    if (subdominio != null && subdominio.isNotEmpty) return subdominio;
    return null;
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
      return appError(state.errorModel, function: _loadData);
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
        textColor: podeAbrir ? ConvertixColors.primaryDark : ConvertixColors.textMuted,
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
      color: AppColors.white,
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

  Widget _filters(bool isAdmin) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.normal),
        child: Wrap(
          spacing: AppSpacing.normal,
          runSpacing: AppSpacing.normal,
          children: [
            _formSearch.formulario,
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
    return appTableRow(
      columns: [
        cellAction(_popupMenu(site)),
        if (isAdmin) cellText(site.id?.toString() ?? '—', _idFlex),
        cellName(site.nome ?? '', flex: _nomeFlex),
        if (isAdmin) cellText(site.clienteNomeEmpresa ?? '—', _clienteFlex),
        cellText(SiteModel.labelTipo(site.tipo), _tipoFlex),
        cellText(_textoOuTraco(site.subdominio), _subdominioFlex),
        cellLink(site.dominio, _dominioFlex),
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

  List<Widget> _tableRows(List<SiteModel> sites, bool isAdmin) {
    return sites.map((s) => _tableRow(s, isAdmin)).toList();
  }

  Widget _table(List<SiteModel> sites, bool isAdmin) {
    return AppTable(
      rowsPerPage: 30,
      headers: _tableHeaders(isAdmin),
      rows: _tableRows(sites, isAdmin),
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
