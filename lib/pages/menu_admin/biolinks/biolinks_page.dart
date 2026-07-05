import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_itens_dialog.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class BioLinksPage extends StatefulWidget {
  final String? tituloPagina;

  const BioLinksPage({super.key, this.tituloPagina});

  @override
  State<BioLinksPage> createState() => _BioLinksPageState();
}

class _BioLinksPageState extends State<BioLinksPage> {
  final BiolinksBloc bloc = BiolinksBloc();

  late AppFormField _formSearch;
  late List<BioLinkModel> _allBioLinks;
  late ValueNotifier<List<BioLinkModel>> _biolinksNotifier;
  final ValueNotifier<bool> _isAdminNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);

  String get _titulo => widget.tituloPagina ?? 'BioLinks';

  static const _siteFlex = 0.55;
  static const _usuarioFlex = 0.45;
  static const _descFlex = 0.65;
  static const _fotoFlex = 0.45;
  static const _dataFlex = 0.45;

  @override
  void initState() {
    super.initState();
    _allBioLinks = [];
    _biolinksNotifier = ValueNotifier<List<BioLinkModel>>([]);
    _initFormSearch();
    _carregarUsuario();
    _loadData();
  }

  @override
  void dispose() {
    _formSearch.controller.dispose();
    _biolinksNotifier.dispose();
    _isAdminNotifier.dispose();
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
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: const Icon(Icons.search, color: ConvertixColors.primary),
      hint: AppStrings.digiteAlgoParaPesquisar,
      onChange: _search,
    );
  }

  void _loadData({bool forceRefresh = false}) {
    bloc.add(BiolinksLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _search(String termo) {
    termo = termo.toLowerCase();
    final filtrados = _allBioLinks.where((b) {
      final id = b.id?.toString() ?? '';
      final site = b.siteNome?.toLowerCase() ?? '';
      final usuario = b.nomeUsuario?.toLowerCase() ?? '';
      final descricao = b.descricao?.toLowerCase() ?? '';
      return id.contains(termo) ||
          site.contains(termo) ||
          usuario.contains(termo) ||
          descricao.contains(termo);
    }).toList();
    _biolinksNotifier.value = filtrados;
  }

  void _onChangeState(BiolinksState state) {
    if (state is BiolinksSuccessState) {
      _allBioLinks = state.biolinks;
      _biolinksNotifier.value = List.from(_allBioLinks);
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is BiolinksErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is BiolinksDeleteSuccessState) {
      showToastSuccess(message: 'BioLink excluído com sucesso');
      _loadData(forceRefresh: true);
    }
  }

  Future<void> _carregarUsuario() async {
    final usuario = await getUsuarioLogado();
    if (!mounted) return;
    _isAdminNotifier.value = usuario?.isAdmin ?? false;
  }

  void _onCadastrarNovo() => _abrirCadastro();

  Future<void> _abrirCadastro({BioLinkModel? biolink}) async {
    if (biolink == null && !_isAdminNotifier.value) {
      showToastError(message: 'Apenas administradores podem cadastrar BioLinks.');
      return;
    }
    await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(biolink),
    );
    _loadData(forceRefresh: true);
  }

  Future<void> _abrirItens(BioLinkModel biolink) async {
    if (biolink.id == null) return;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _itensDialog(biolink),
    );
  }

  String _textoOuTraco(String? value) {
    if (value == null || value.trim().isEmpty) return '—';
    return value;
  }

  void _onEditar(BioLinkModel biolink) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _abrirCadastro(biolink: biolink);
    });
  }

  void _onGerenciarItens(BioLinkModel biolink) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _abrirItens(biolink);
    });
  }

  void _onExcluir(BioLinkModel biolink) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confirmarExclusao(biolink);
    });
  }

  Future<void> _confirmarExclusao(BioLinkModel biolink) async {
    if (!_isAdminNotifier.value) {
      showToastError(message: 'Apenas administradores podem excluir BioLinks.');
      return;
    }
    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Excluir BioLink',
      message: 'Deseja excluir o BioLink de ${biolink.nomeUsuario ?? '?'}?',
      icon: Icons.delete_outline,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmado == true && biolink.id != null) {
      bloc.add(BiolinksDeleteEvent(biolinkId: biolink.id!));
    }
  }

  Widget _cadastroDialog(BioLinkModel? biolink) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BiolinksCadastro(
        biolink: biolink ?? BioLinkModel.empty(),
        isDialog: true,
        isAdmin: _isAdminNotifier.value,
      ),
    );
  }

  Widget _itensDialog(BioLinkModel biolink) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: BiolinksItensDialog(biolink: biolink),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<BiolinksBloc, BiolinksState>(
      bloc: bloc,
      listener: (_, state) => _onChangeState(state),
      buildWhen: (previous, current) =>
          current is BiolinksLoadingState ||
          current is BiolinksSuccessState ||
          current is BiolinksErrorState,
      builder: _buildBlocBody,
    );
  }

  Widget _buildBlocBody(BuildContext context, BiolinksState state) {
    if (state is BiolinksLoadingState) return appLoadingCovertix();
    if (state is BiolinksErrorState) {
      return appError(state.errorModel, function: _loadData);
    }
    return _biolinksListBody();
  }

  Widget _biolinksListBody() {
    return ValueListenableBuilder<bool>(
      valueListenable: _isAdminNotifier,
      builder: (_, isAdmin, __) {
        return ValueListenableBuilder<List<BioLinkModel>>(
          valueListenable: _biolinksNotifier,
          builder: (_, biolinks, ___) => _body(biolinks, isAdmin),
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

  List<PopupMenuEntry<void>> _popupMenuItems(BioLinkModel biolink, bool isAdmin) {
    return [
      _popupItemMenu(
        icon: Icons.edit_outlined,
        title: 'Editar',
        onTap: () => _onEditar(biolink),
      ),
      _popupItemMenu(
        icon: Icons.list_alt_outlined,
        title: 'Gerenciar itens',
        color: ConvertixColors.primaryLight,
        textColor: ConvertixColors.primaryDark,
        onTap: () => _onGerenciarItens(biolink),
      ),
      if (isAdmin)
        _popupItemMenu(
          icon: Icons.delete_outline,
          title: 'Excluir',
          color: AppColors.red,
          textColor: AppColors.white,
          onTap: () => _onExcluir(biolink),
        ),
    ];
  }

  Widget _popupMenu(BioLinkModel biolink, bool isAdmin) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: AppColors.white,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => _popupMenuItems(biolink, isAdmin),
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

  List<Widget> _tableHeaders() {
    return [
      cellHeaderAction(),
      cellHeader('Site', _siteFlex),
      cellHeader('Usuário', _usuarioFlex),
      cellHeader('Descrição', _descFlex),
      cellHeader('Foto', _fotoFlex),
      cellHeader('Criado em', _dataFlex),
      cellHeader('Alterado em', _dataFlex),
    ];
  }

  Widget _tableRow(BioLinkModel biolink, bool isAdmin) {
    return appTableRow(
      columns: [
        cellAction(_popupMenu(biolink, isAdmin)),
        cellName(biolink.siteNome ?? '—', flex: _siteFlex),
        cellText(_textoOuTraco(biolink.nomeUsuario), _usuarioFlex),
        cellText(_textoOuTraco(biolink.descricao), _descFlex),
        cellFoto(biolink.fotoPerfil, _fotoFlex),
        cellDateTime(biolink.createdAt, _dataFlex),
        cellDateTime(biolink.updatedAt, _dataFlex, showDivider: false),
      ],
    );
  }

  List<Widget> _tableRows(List<BioLinkModel> biolinks, bool isAdmin) {
    return biolinks.map((b) => _tableRow(b, isAdmin)).toList();
  }

  Widget _table(List<BioLinkModel> biolinks, bool isAdmin) {
    return AppTable(
      rowsPerPage: 30,
      headers: _tableHeaders(),
      rows: _tableRows(biolinks, isAdmin),
    );
  }

  Widget _body(List<BioLinkModel> biolinks, bool isAdmin) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.normal,
        left: AppSpacing.normal,
        bottom: AppSpacing.normal,
      ),
      child: Column(
        children: [
          _filters(isAdmin),
          _table(biolinks, isAdmin),
        ],
      ),
    );
  }
}
