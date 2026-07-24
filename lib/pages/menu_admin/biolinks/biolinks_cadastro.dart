import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/validators.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';
import 'package:web_gestor_site_covertix/models/site_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_bloc.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_event.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_service.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolinks_state.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/sites/sites_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/covertix_dropdown_form_field.dart';
import 'package:web_gestor_site_covertix/widgets/foto_picker_field.dart';

class BiolinksCadastro extends StatefulWidget {
  final BioLinkModel biolink;
  final bool isDialog;
  final bool isAdmin;

  const BiolinksCadastro({
    super.key,
    required this.biolink,
    this.isDialog = false,
    this.isAdmin = true,
  });

  @override
  State<BiolinksCadastro> createState() => _BiolinksCadastroState();
}

class _BiolinksCadastroState extends State<BiolinksCadastro> {
  final BiolinksBloc bloc = BiolinksBloc();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool get _isEditMode => widget.biolink.id != null && widget.biolink.id! > 0;

  late final AppFormField nomeUsuarioForm;
  late final AppFormField descricaoForm;
  XFile? _novaFoto;

  List<SiteModel> _sitesDisponiveis = [];
  final ValueNotifier<bool> _carregandoSitesNotifier = ValueNotifier(true);
  int? _siteIdSelecionado;

  double get _fieldWidth => widget.isDialog ? double.infinity : 400;

  String get _formTitle => _isEditMode ? 'Editar BioLink' : 'Novo BioLink';

  @override
  void initState() {
    super.initState();
    _siteIdSelecionado = widget.biolink.siteId;
    _initForms();
    _carregarSites();
  }

  void _initForms() {
    nomeUsuarioForm = _buildField(
      hint: 'Nome de usuário (3–50: letras, números, . _ -)',
      icon: Icons.alternate_email_outlined,
      validator: validateNomeUsuarioBioLink,
    );
    descricaoForm = _buildField(
      hint: 'Descrição (opcional)',
      icon: Icons.notes_outlined,
    );

    nomeUsuarioForm.controller.text = widget.biolink.nomeUsuario ?? '';
    descricaoForm.controller.text = widget.biolink.descricao ?? '';
  }

  Future<void> _carregarSites() async {
    _carregandoSitesNotifier.value = true;
    try {
      final sites = await listarSitesLookup();
      final biolinks = await listarBioLinksLookup();
      final sitesComBioLink = biolinks
          .where((b) => b.id != widget.biolink.id)
          .map((b) => b.siteId)
          .whereType<int>()
          .toSet();

      final disponiveis = sites
          .where((s) =>
              s.tipo == TipoSite.biolink &&
              (s.id == widget.biolink.siteId ||
                  !sitesComBioLink.contains(s.id)))
          .toList();

      if (!mounted) return;
      _sitesDisponiveis = disponiveis;
      _siteIdSelecionado ??=
          disponiveis.isNotEmpty ? disponiveis.first.id : null;
      _carregandoSitesNotifier.value = false;
    } catch (_) {
      if (mounted) {
        showToastError(message: 'Erro ao carregar sites');
        _carregandoSitesNotifier.value = false;
      }
    }
  }

  AppFormField _buildField({
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return AppFormField(
      context: context,
      width: _fieldWidth,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: ConvertixColors.inputFill,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
    );
  }

  Widget _dropdownField({required String label, required Widget child}) {
    return appContainer(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          appText(label, color: ConvertixColors.textSecondary, fontSize: AppFontSizes.verySmall),
          appSizedBox(height: AppSpacing.small),
          child,
        ],
      ),
    );
  }

  Widget _siteDropdownLoading() {
    return _dropdownField(
      label: 'Site',
      child: appContainer(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: ConvertixColors.primary),
        ),
      ),
    );
  }

  Widget _siteDropdownEmpty() {
    return _dropdownField(
      label: 'Site',
      child: appText(
        'Nenhum site do tipo BioLink disponível',
        color: ConvertixColors.textMuted,
      ),
    );
  }

  Widget _siteDropdownField() {
    return StatefulBuilder(
      builder: (context, setDropdownState) {
        return _dropdownField(
          label: 'Site',
          child: CovertixDropdownFormField<int>(
            value: _siteIdSelecionado,
            hint: 'Selecione o site',
            items: _sitesDisponiveis.map((site) {
              return DropdownMenuItem(
                value: site.id,
                child: Text(site.nome ?? 'Site #${site.id}'),
              );
            }).toList(),
            onChanged: _isEditMode
                ? null
                : (value) => setDropdownState(() => _siteIdSelecionado = value),
            validator: (value) => value == null ? 'Site é obrigatório' : null,
          ),
        );
      },
    );
  }

  Widget _siteDropdown() {
    return ValueListenableBuilder<bool>(
      valueListenable: _carregandoSitesNotifier,
      builder: (_, loading, __) {
        if (loading) return _siteDropdownLoading();
        if (_sitesDisponiveis.isEmpty) return _siteDropdownEmpty();
        return _siteDropdownField();
      },
    );
  }

  void _save() {
    if (!_isEditMode && !widget.isAdmin) {
      showToastError(
        message: 'Apenas administradores podem cadastrar BioLinks.',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final biolink = BioLinkModel(
      id: widget.biolink.id,
      siteId: _siteIdSelecionado,
      nomeUsuario: normalizeNomeUsuarioBioLink(nomeUsuarioForm.value),
      descricao: descricaoForm.value.trim(),
      fotoPerfil: widget.biolink.fotoPerfil,
    );

    bloc.add(BiolinksSaveEvent(biolink: biolink, foto: _novaFoto));
  }

  void _onBlocState(BuildContext context, BiolinksState state) {
    if (state is BiolinksSaveSuccessState) {
      showToastSuccess(message: 'BioLink salvo com sucesso');
      Navigator.pop(context, true);
    }
    if (state is BiolinksSaveErrorState) {
      showToastError(
        message: state.errorModel.mensagem ?? 'Erro ao salvar',
      );
    }
  }

  Widget _loadingView() {
    return appContainer(
      height: 280,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _fotoPicker() {
    return FotoPickerField(
      fotoAtual: widget.biolink.fotoPerfil,
      onFotoChanged: (file) => _novaFoto = file,
    );
  }

  Widget _formFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _siteDropdown(),
          nomeUsuarioForm.formulario,
          descricaoForm.formulario,
          appSizedBox(height: AppSpacing.normal),
          _fotoPicker(),
        ],
      ),
    );
  }

  Widget _pageTitle() {
    return appText(
      _formTitle,
      fontSize: AppFontSizes.verySmall,
      bold: true,
      color: ConvertixColors.textPrimary,
    );
  }

  Widget _pageLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _pageTitle(),
        appSizedBox(height: AppSpacing.big),
        _formFields(),
        appSizedBox(height: AppSpacing.big),
        _actionButtons(),
      ],
    );
  }

  Widget _formContentBody(BiolinksState state) {
    if (state is BiolinksSaveLoadingState) return _loadingView();
    if (widget.isDialog) return _formFields();
    return _pageLayout();
  }

  Widget _formContent() {
    return BlocConsumer<BiolinksBloc, BiolinksState>(
      bloc: bloc,
      listener: _onBlocState,
      buildWhen: (previous, current) =>
          (current is BiolinksSaveLoadingState) !=
          (previous is BiolinksSaveLoadingState),
      builder: (context, state) => _formContentBody(state),
    );
  }

  Widget _actionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonWidth = (constraints.maxWidth - AppSpacing.normal) / 2;
        return Row(
          children: [
            Expanded(
              child: appElevatedButtonCovertix(
                title: AppStrings.salvar,
                height: 42,
                width: buttonWidth,
                onTap: _save,
              ),
            ),
            appSizedBox(width: AppSpacing.normal),
            Expanded(
              child: appElevatedButtonCovertix(
                title: AppStrings.cancelar,
                height: 42,
                width: buttonWidth,
                primary: false,
                onTap: () => Navigator.pop(context),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogHeader() {
    return appDialogHeader(
      title: _formTitle,
      icon: _isEditMode ? Icons.edit_outlined : Icons.link_outlined,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _dialogScrollArea() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 480),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: _formContent(),
      ),
    );
  }

  Widget _dialogActionsFooter() {
    return appContainer(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: _actionButtons(),
    );
  }

  Widget _dialogContent() {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogHeader(),
            _dialogScrollArea(),
            _dialogActionsFooter(),
          ],
        ),
      ),
    );
  }

  Widget _scaffoldContent() {
    return scaffold(
      title: _formTitle,
      background: ConvertixColors.background,
      body: appContainer(
        padding: const EdgeInsets.all(24),
        child: _formContent(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isDialog ? _dialogContent() : _scaffoldContent();
  }

  @override
  void dispose() {
    _carregandoSitesNotifier.dispose();
    nomeUsuarioForm.controller.dispose();
    descricaoForm.controller.dispose();
    bloc.close();
    super.dispose();
  }
}
