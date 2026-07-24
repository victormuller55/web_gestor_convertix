import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/debounce.dart';
import 'package:web_gestor_site_covertix/models/cliente_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_cadastro.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/clientes/clientes_state.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';
import 'package:web_gestor_site_covertix/widgets/table/table.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_cell.dart';
import 'package:web_gestor_site_covertix/widgets/table/table_header.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({super.key});

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ClientesBloc bloc = ClientesBloc();

  late AppFormField _formSearch;
  late List<ClienteModel> _allClientes;
  late ValueNotifier<List<ClienteModel>> _clientesNotifier;
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);
  final Debouncer _buscaDebouncer = Debouncer();

  static const _fotoFlex = 0.25;
  static const _empresaFlex = 0.7;
  static const _documentoFlex = 0.4;
  static const _emailFlex = 0.7;
  static const _telefoneFlex = 0.35;
  static const _dataFlex = 0.5;

  @override
  void initState() {
    super.initState();
    _allClientes = [];
    _clientesNotifier = ValueNotifier<List<ClienteModel>>([]);
    _initFormSearch();
    _loadData();
  }

  @override
  void dispose() {
    _buscaDebouncer.dispose();
    _formSearch.controller.dispose();
    _clientesNotifier.dispose();
    _isReloading.dispose();
    bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Clientes',
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
    bloc.add(ClientesLoadEvent(forceRefresh: forceRefresh));
  }

  void _reload() {
    _isReloading.value = true;
    _loadData(forceRefresh: true);
  }

  void _search(String termo) {
    _buscaDebouncer.run(() {
      final q = termo.toLowerCase();
      final filtrados = _allClientes.where((c) {
        final empresa = c.nomeEmpresa?.toLowerCase() ?? '';
        final documento = c.documento?.toLowerCase() ?? '';
        final email = c.email?.toLowerCase() ?? '';
        final telefone = c.telefone?.toLowerCase() ?? '';
        return empresa.contains(q) ||
            documento.contains(q) ||
            email.contains(q) ||
            telefone.contains(q);
      }).toList();
      _clientesNotifier.value = filtrados;
    });
  }

  void _onChangeState(ClientesState state) {
    if (state is ClientesSuccessState) {
      _allClientes = state.clientes;
      _clientesNotifier.value = List.from(_allClientes);
      if (_isReloading.value) _isReloading.value = false;
    }
    if (state is ClientesErrorState && _isReloading.value) {
      _isReloading.value = false;
    }
    if (state is ClientesDeleteSuccessState) {
      showToastSuccess(message: 'Cliente excluído com sucesso');
      _loadData(forceRefresh: true);
    }
  }

  String _formatTelefone(String? telefone) {
    if (telefone == null || telefone.isEmpty) return '—';
    final digits = telefone.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return telefone;
    return formataCelular(digits);
  }

  void _onCadastrarNovo() => _abrirCadastro();

  Future<void> _abrirCadastro({ClienteModel? cliente}) async {
    final salvo = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroDialog(cliente),
    );
    if (salvo == true) _loadData(forceRefresh: true);
  }

  void _onEditarCliente(ClienteModel cliente) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _abrirCadastro(cliente: cliente);
    });
  }

  void _onExcluirCliente(ClienteModel cliente) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _confirmarExclusao(cliente);
    });
  }

  Future<void> _confirmarExclusao(ClienteModel cliente) async {
    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Excluir cliente',
      message: 'Deseja excluir o cliente ${cliente.nomeEmpresa ?? '?'}?',
      icon: Icons.delete_outline,
      confirmLabel: 'Excluir',
      destructive: true,
    );
    if (confirmado == true && cliente.id != null) {
      bloc.add(ClientesDeleteEvent(clienteId: cliente.id!));
    }
  }

  Widget _cadastroDialog(ClienteModel? cliente) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ClientesCadastro(
        cliente: cliente ?? ClienteModel.empty(),
        isDialog: true,
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocConsumer<ClientesBloc, ClientesState>(
      bloc: bloc,
      listener: (_, state) => _onChangeState(state),
      buildWhen: (previous, current) =>
          current is ClientesLoadingState ||
          current is ClientesSuccessState ||
          current is ClientesErrorState,
      builder: _buildBlocBody,
    );
  }

  Widget _buildBlocBody(BuildContext context, ClientesState state) {
    if (state is ClientesLoadingState) return appLoadingCovertix();
    if (state is ClientesErrorState) {
      return appError(state.errorModel, function: _loadData);
    }
    return _clientesListBody();
  }

  Widget _clientesListBody() {
    return ValueListenableBuilder<List<ClienteModel>>(
      valueListenable: _clientesNotifier,
      builder: (_, clientes, _) => _body(clientes),
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

  List<PopupMenuEntry<void>> _popupMenuItems(ClienteModel cliente) {
    return [
      _popupItemMenu(
        icon: Icons.edit_outlined,
        title: 'Editar',
        onTap: () => _onEditarCliente(cliente),
      ),
      _popupItemMenu(
        icon: Icons.delete_outline,
        title: 'Excluir',
        color: AppColors.red,
        textColor: AppColors.white,
        onTap: () => _onExcluirCliente(cliente),
      ),
    ];
  }

  Widget _popupMenu(ClienteModel cliente) {
    return PopupMenuButton(
      icon: Icon(Icons.more_vert, color: ConvertixColors.textSecondary, size: 20),
      iconSize: 20,
      color: ConvertixColors.surface,
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      itemBuilder: (_) => _popupMenuItems(cliente),
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
      cellHeader('Empresa', _empresaFlex),
      cellHeader('Documento', _documentoFlex),
      cellHeader('E-mail', _emailFlex),
      cellHeader('Telefone', _telefoneFlex),
      cellHeader('Criado em', _dataFlex),
      cellHeader('Alterado em', _dataFlex),
    ];
  }

  Widget _tableRow(ClienteModel cliente) {
    return appTableRow(
      columns: [
        cellAction(_popupMenu(cliente)),
        cellFoto(cliente.foto, _fotoFlex),
        cellName(cliente.nomeEmpresa ?? ''),
        cellDocumento(cliente.documento ?? ''),
        cellText(cliente.email ?? '', _emailFlex),
        cellText(_formatTelefone(cliente.telefone), _telefoneFlex),
        cellDateTime(cliente.createdAt, _dataFlex),
        cellDateTime(cliente.updatedAt, _dataFlex, showDivider: false),
      ],
    );
  }

  Widget _table(List<ClienteModel> clientes) {
    return AppTable(
      rowsPerPage: 30,
      headers: _tableHeaders(),
      itemCount: clientes.length,
      rowBuilder: (index) => _tableRow(clientes[index]),
    );
  }

  Widget _body(List<ClienteModel> clientes) {
    return Padding(
      padding: EdgeInsets.only(
        right: AppSpacing.normal,
        left: AppSpacing.normal,
        bottom: AppSpacing.normal,
      ),
      child: Column(
        children: [
          _filters(),
          _table(clientes),
        ],
      ),
    );
  }
}
