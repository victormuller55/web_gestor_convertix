import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/debounce.dart';
import 'package:web_gestor_site_covertix/models/page_response.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/usuarios/usuarios_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final UsuariosBloc bloc = UsuariosBloc();

  late AppFormField _formSearch;
  late ValueNotifier<List<UsuarioModel>> _usuariosNotifier;
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final Debouncer _buscaDebouncer = Debouncer();

  int _page = 0;
  int _totalElements = 0;
  int _totalPages = 0;
  String _query = '';
  static const _size = PageResponse.defaultSize;

  static const _fotoFlex = 0.25;
  static const _emailFlex = 0.7;
  static const _tipoFlex = 0.35;
  static const _statusFlex = 0.3;
  static const _dataFlex = 0.5;

  @override
  void initState() {
    super.initState();
    _usuariosNotifier = ValueNotifier<List<UsuarioModel>>([]);
    _initFormSearch();
    _loadData();
  }

  @override
  void dispose() {
    _buscaDebouncer.dispose();
    _formSearch.controller.dispose();
    _usuariosNotifier.dispose();
    _isReloading.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Usuários',
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
      onChange: _search,
    );
  }

  void _loadData({int? page}) {
    if (page != null) _page = page;
    bloc.add(UsuariosLoadEvent(
      query: _query.isEmpty ? null : _query,
      page: _page,
      size: _size,
    ));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(page: 0);
  }

  void _search(String termo) {
    _buscaDebouncer.run(() {
      _query = termo.trim();
      _loadData(page: 0);
    });
  }

  void _onPageChanged(int page) => _loadData(page: page);

  void _onChangeState(UsuariosState state) {
    if (state is UsuariosSuccessState) {
      _page = state.page.page;
      _totalElements = state.page.totalElements;
      _totalPages = state.page.totalPages;
      _usuariosNotifier.value = List.from(state.usuarios);
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is UsuariosErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is UsuariosDeleteSuccessState) {
      showToastSuccess(message: 'Usuário excluído com sucesso');
      _loadData();
    }
  }

  void _onCadastrarNovo() => _abrirCadastro();

  Future<void> _abrirCadastro({UsuarioModel? usuario}) async {
    final salvo = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(usuario),
    );
    if (salvo == true) _loadData(page: 0);
  }

  void _onEditarUsuario(UsuarioModel usuario) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _abrirCadastro(usuario: usuario);
    });
  }

  void _onExcluirUsuario(UsuarioModel usuario) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confirmarExclusao(usuario);
    });
  }

  Future<void> _confirmarExclusao(UsuarioModel usuario) async {
    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Excluir usuário',
      message: 'Deseja excluir o usuário ${usuario.nome ?? '?'}?',
      icon: Icons.delete_outline,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmado == true && usuario.id != null) {
      bloc.add(UsuariosDeleteEvent(usuarioId: usuario.id!));
    }
  }

  Widget _cadastroDialog(UsuarioModel? usuario) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: UsuariosCadastro(
        usuario: usuario ?? UsuarioModel.empty(),
        isDialog: true,
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<UsuariosBloc, UsuariosState>(
      bloc: bloc,
      listener: (_, state) => _onChangeState(state),
      buildWhen: (previous, current) =>
          current is UsuariosLoadingState ||
          current is UsuariosSuccessState ||
          current is UsuariosErrorState,
      builder: _buildBlocBody,
    );
  }

  Widget _buildBlocBody(BuildContext context, UsuariosState state) {
    if (state is UsuariosLoadingState) return appLoadingCovertix();
    if (state is UsuariosErrorState) {
      return appError(state.errorModel, function: () => _loadData());
    }
    return _usuariosListBody();
  }

  Widget _usuariosListBody() {
    return ValueListenableBuilder<List<UsuarioModel>>(
      valueListenable: _usuariosNotifier,
      builder: (_, usuarios, _) => _body(usuarios),
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

  List<PopupMenuEntry<void>> _popupMenuItems(UsuarioModel usuario) {
    return [
      _popupItemMenu(
        icon: Icons.edit_outlined,
        title: 'Editar',
        onTap: () => _onEditarUsuario(usuario),
      ),
      _popupItemMenu(
        icon: Icons.delete_outline,
        title: 'Excluir',
        color: AppColors.red,
        textColor: AppColors.white,
        onTap: () => _onExcluirUsuario(usuario),
      ),
    ];
  }

  Widget _popupMenu(UsuarioModel usuario) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: ConvertixColors.surface,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => _popupMenuItems(usuario),
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

  Widget _filters() {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.normal),
        child: Wrap(
          spacing: AppSpacing.normal,
          runSpacing: AppSpacing.normal,
          children: [
            _formSearch.formulario,
            _cadastrarButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _tableHeaders() {
    return [
      cellHeaderAction(),
      cellHeader('Foto', _fotoFlex),
      cellHeaderName(),
      cellHeader('E-mail', _emailFlex),
      cellHeader('Tipo', _tipoFlex),
      cellHeader('Status', _statusFlex),
      cellHeader('Criado em', _dataFlex),
      cellHeader('Alterado em', _dataFlex),
    ];
  }

  Widget _tableRow(UsuarioModel usuario) {
    return appTableRow(
      columns: [
        cellAction(_popupMenu(usuario)),
        cellFoto(usuario.foto, _fotoFlex),
        cellName(usuario.nome ?? ''),
        cellText(usuario.email ?? '', _emailFlex),
        cellText(usuario.tipo ?? '', _tipoFlex),
        cellAtivo(usuario.ativo ?? false),
        cellDateTime(usuario.createdAt, _dataFlex),
        cellDateTime(usuario.updatedAt, _dataFlex, showDivider: false),
      ],
    );
  }

  Widget _table(List<UsuarioModel> usuarios) {
    return AppTable(
      rowsPerPage: _size,
      headers: _tableHeaders(),
      itemCount: usuarios.length,
      rowBuilder: (index) => _tableRow(usuarios[index]),
      page: _page,
      totalElements: _totalElements,
      totalPages: _totalPages <= 0 ? 1 : _totalPages,
      onPageChanged: _onPageChanged,
    );
  }

  Widget _body(List<UsuarioModel> usuarios) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.normal,
        left: AppSpacing.normal,
        bottom: AppSpacing.normal,
      ),
      child: Column(
        children: [
          _filters(),
          _table(usuarios),
        ],
      ),
    );
  }
}
