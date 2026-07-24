import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/debounce.dart';
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
  late List<UsuarioModel> _allUsuarios;
  late ValueNotifier<List<UsuarioModel>> _usuariosNotifier;
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final Debouncer _buscaDebouncer = Debouncer();

  static const _fotoFlex = 0.25;
  static const _emailFlex = 0.7;
  static const _tipoFlex = 0.35;
  static const _statusFlex = 0.3;
  static const _dataFlex = 0.5;

  @override
  void initState() {
    super.initState();
    _allUsuarios = [];
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

  void _loadData({bool forceRefresh = false}) {
    bloc.add(UsuariosLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _search(String termo) {
    _buscaDebouncer.run(() {
      final q = termo.toLowerCase();
      final filtrados = _allUsuarios.where((u) {
        final nome = u.nome?.toLowerCase() ?? '';
        final email = u.email?.toLowerCase() ?? '';
        final tipo = u.tipo?.toLowerCase() ?? '';
        return nome.contains(q) || email.contains(q) || tipo.contains(q);
      }).toList();
      _usuariosNotifier.value = filtrados;
    });
  }

  void _onChangeState(UsuariosState state) {
    if (state is UsuariosSuccessState) {
      _allUsuarios = state.usuarios;
      _usuariosNotifier.value = List.from(_allUsuarios);
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is UsuariosErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is UsuariosDeleteSuccessState) {
      showToastSuccess(message: 'Usuário excluído com sucesso');
      _loadData(forceRefresh: true);
    }
  }

  void _onCadastrarNovo() => _abrirCadastro();

  Future<void> _abrirCadastro({UsuarioModel? usuario}) async {
    final salvo = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(usuario),
    );
    if (salvo == true) _loadData(forceRefresh: true);
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
      return appError(state.errorModel, function: _loadData);
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
      rowsPerPage: 30,
      headers: _tableHeaders(),
      itemCount: usuarios.length,
      rowBuilder: (index) => _tableRow(usuarios[index]),
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
