import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/function/app_toast.dart';
import 'package:web_gestor_site_covertix/function/http_helper.dart';
import 'package:web_gestor_site_covertix/function/link_helper.dart';
import 'package:web_gestor_site_covertix/models/biolink_item_model.dart';
import 'package:web_gestor_site_covertix/models/biolink_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/biolinks/biolink_itens_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_dialog_header.dart';
import 'package:web_gestor_site_covertix/widgets/app_elevated_button.dart';
import 'package:web_gestor_site_covertix/widgets/app_loading.dart';
import 'package:web_gestor_site_covertix/widgets/biolink/biolink_item_icone_selector.dart';
import 'package:web_gestor_site_covertix/widgets/biolink/biolink_items_reorder_list.dart';
import 'package:web_gestor_site_covertix/widgets/dominio_url_form_field.dart';

class BiolinksItensDialog extends StatefulWidget {
  final BioLinkModel biolink;

  const BiolinksItensDialog({super.key, required this.biolink});

  @override
  State<BiolinksItensDialog> createState() => _BiolinksItensDialogState();
}

class _BiolinksItensDialogState extends State<BiolinksItensDialog> {
  final ValueNotifier<List<BioLinkItemModel>> _itensNotifier =
      ValueNotifier([]);
  final ValueNotifier<bool> _carregandoNotifier = ValueNotifier(true);
  final ValueNotifier<String?> _erroNotifier = ValueNotifier(null);
  final ValueNotifier<bool> _ordemAlteradaNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _salvandoOrdemNotifier = ValueNotifier(false);

  Map<int, int> _ordemOriginal = {};

  List<BioLinkItemModel> get _itens => _itensNotifier.value;

  int get _biolinkId => widget.biolink.id!;
  bool get _atingiuLimite => _itens.length >= BiolinkItemsReorderList.maxItens;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  @override
  void dispose() {
    _itensNotifier.dispose();
    _carregandoNotifier.dispose();
    _erroNotifier.dispose();
    _ordemAlteradaNotifier.dispose();
    _salvandoOrdemNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 520, maxHeight: maxHeight),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            _novoItemSection(),
            Expanded(child: _itemsArea()),
            _footer(),
          ],
        ),
      ),
    );
  }

  Future<void> _carregarItens() async {
    _carregandoNotifier.value = true;
    _erroNotifier.value = null;
    try {
      final itens = await listarBioLinkItens(_biolinkId);
      itens.sort((a, b) => (a.ordem ?? 0).compareTo(b.ordem ?? 0));
      if (!mounted) return;
      _itensNotifier.value = itens;
      _ordemOriginal = {
        for (final item in itens)
          if (item.id != null) item.id!: item.ordem ?? 0,
      };
      _ordemAlteradaNotifier.value = false;
      _carregandoNotifier.value = false;
    } catch (e) {
      if (!mounted) return;
      _erroNotifier.value =
          parseApiError(e).mensagem ?? 'Erro ao carregar itens';
      _carregandoNotifier.value = false;
    }
  }

  int _proximaOrdem() => _itens.length + 1;

  void _atualizarOrdensLocais(List<BioLinkItemModel> itens) {
    for (var i = 0; i < itens.length; i++) {
      itens[i].ordem = i + 1;
    }
    _ordemAlteradaNotifier.value = itens.any(
      (item) => item.id != null && _ordemOriginal[item.id!] != item.ordem,
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    final itens = List<BioLinkItemModel>.from(_itens);
    var destino = newIndex;
    if (destino > oldIndex) destino -= 1;
    final item = itens.removeAt(oldIndex);
    itens.insert(destino, item);
    _atualizarOrdensLocais(itens);
    _itensNotifier.value = itens;
  }

  Future<void> _salvarOrdem() async {
    if (!_ordemAlteradaNotifier.value || _salvandoOrdemNotifier.value) return;

    _salvandoOrdemNotifier.value = true;
    try {
      for (final item in _itens) {
        if (item.id == null) continue;
        if (_ordemOriginal[item.id!] == item.ordem) continue;
        await alterarBioLinkItem(item);
      }
      if (!mounted) return;
      _ordemOriginal = {
        for (final item in _itens)
          if (item.id != null) item.id!: item.ordem ?? 0,
      };
      _ordemAlteradaNotifier.value = false;
      showToastSuccess(message: 'Ordem salva com sucesso');
    } catch (e) {
      if (!mounted) return;
      showToastError(
        message: parseApiError(e).mensagem ?? 'Erro ao salvar ordem',
      );
    } finally {
      if (mounted) _salvandoOrdemNotifier.value = false;
    }
  }

  Future<void> _abrirCadastroItem({BioLinkItemModel? item}) async {
    if (item == null && _atingiuLimite) {
      showToastError(
        message: 'Limite de ${BiolinkItemsReorderList.maxItens} itens atingido',
      );
      return;
    }

    final itemInicial = item ??
        BioLinkItemModel.empty(
          biolinkId: _biolinkId,
          ordem: _proximaOrdem(),
        );

    final salvo = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _cadastroItemDialog(itemInicial),
    );

    if (salvo == true) _carregarItens();
  }

  Future<void> _excluirItem(BioLinkItemModel item) async {
    if (item.id == null) return;

    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Excluir item',
      message: 'Deseja excluir "${item.titulo ?? ''}"?',
      icon: Icons.delete_outline,
      confirmLabel: 'Excluir',
      destructive: true,
    );

    if (confirmado != true) return;

    try {
      await excluirBioLinkItem(biolinkId: _biolinkId, id: item.id!);
      showToastSuccess(message: 'Item excluído com sucesso');
      _carregarItens();
    } catch (e) {
      showToastError(
        message: parseApiError(e).mensagem ?? 'Erro ao excluir item',
      );
    }
  }

  Widget _cadastroItemDialog(BioLinkItemModel item) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: _ItemCadastroDialog(item: item),
    );
  }

  Widget _header() {
    final titulo =
        widget.biolink.nomeUsuario ?? widget.biolink.siteNome ?? 'BioLink';
    return appDialogHeader(
      title: 'Itens do BioLink',
      icon: Icons.view_list_outlined,
      subtitle: titulo,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _novoItemSection() {
    return ValueListenableBuilder<List<BioLinkItemModel>>(
      valueListenable: _itensNotifier,
      builder: (_, itens, _) {
        final atingiuLimite =
            itens.length >= BiolinkItemsReorderList.maxItens;
        return Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Opacity(
                opacity: atingiuLimite ? 0.45 : 1,
                child: appElevatedButtonCovertix(
                  title: 'Novo item',
                  width: 160,
                  height: 38,
                  fontSize: AppFontSizes.verySmall,
                  onTap: atingiuLimite ? () {} : () => _abrirCadastroItem(),
                ),
              ),
              if (atingiuLimite) ...[
                appSizedBox(height: AppSpacing.small),
                _hintText(
                  'Limite de ${BiolinkItemsReorderList.maxItens} itens atingido.',
                ),
              ] else if (itens.isNotEmpty) ...[
                appSizedBox(height: AppSpacing.small),
                _hintText('Arraste os itens para definir a ordem no site.'),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _hintText(String text) {
    return appText(
      text,
      color: ConvertixColors.textMuted,
      fontSize: AppFontSizes.verySmall,
    );
  }

  Widget _itemsArea() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ValueListenableBuilder<bool>(
        valueListenable: _carregandoNotifier,
        builder: (_, carregando, _) {
          if (carregando) {
            return Center(child: appLoadingCovertix());
          }
          return ValueListenableBuilder<String?>(
            valueListenable: _erroNotifier,
            builder: (_, erro, _) {
              if (erro != null) return _erroBody(erro);
              return ValueListenableBuilder<List<BioLinkItemModel>>(
                valueListenable: _itensNotifier,
                builder: (_, itens, _) => _listaItens(itens),
              );
            },
          );
        },
      ),
    );
  }

  Widget _listaItens(List<BioLinkItemModel> itens) {
    return BiolinkItemsReorderList(
      itens: itens,
      onReorder: _onReorder,
      onEdit: (item) => _abrirCadastroItem(item: item),
      onDelete: _excluirItem,
    );
  }

  Widget _erroBody(String erro) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        appText(erro, color: AppColors.red),
        appSizedBox(height: AppSpacing.normal),
        appElevatedButtonCovertix(
          title: 'Tentar novamente',
          width: 180,
          height: 38,
          onTap: _carregarItens,
        ),
      ],
    );
  }

  Widget _contadorItens(int total) {
    return appContainer(
      height: 30,
      radius: BorderRadius.circular(AppTheme.radiusInput),
      gradient: ConvertixColors.primaryGradient,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.normal),
      child: Center(
        child: Row(
          children: [
            appText(
              '$total/${BiolinkItemsReorderList.maxItens}',
              color: AppColors.white,
              bold: true,
            ),
            appSizedBox(width: AppSpacing.small),
            appText('ITENS', color: AppColors.white, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _salvarOrdemButton(bool salvando) {
    return appElevatedButtonCovertix(
      title: salvando ? 'Salvando...' : 'Salvar ordem',
      width: 160,
      height: 38,
      fontSize: AppFontSizes.verySmall,
      onTap: salvando ? () {} : _salvarOrdem,
    );
  }

  Widget _footer() {
    return ValueListenableBuilder<bool>(
      valueListenable: _carregandoNotifier,
      builder: (_, carregando, _) {
        if (carregando) return const SizedBox.shrink();
        return ValueListenableBuilder<String?>(
          valueListenable: _erroNotifier,
          builder: (_, erro, _) {
            if (erro != null) return const SizedBox.shrink();
            return ValueListenableBuilder<List<BioLinkItemModel>>(
              valueListenable: _itensNotifier,
              builder: (_, itens, _) {
                return ValueListenableBuilder<bool>(
                  valueListenable: _ordemAlteradaNotifier,
                  builder: (_, ordemAlterada, _) {
                    return ValueListenableBuilder<bool>(
                      valueListenable: _salvandoOrdemNotifier,
                      builder: (_, salvando, _) {
                        return appContainer(
                          backgroundColor: ConvertixColors.background,
                          border: const Border(
                            top: BorderSide(color: ConvertixColors.border),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpacing.normal,
                              vertical: AppSpacing.small + 2,
                            ),
                            child: Row(
                              children: [
                                _contadorItens(itens.length),
                                const Spacer(),
                                if (ordemAlterada) _salvarOrdemButton(salvando),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}

class _ItemCadastroDialog extends StatefulWidget {
  final BioLinkItemModel item;

  const _ItemCadastroDialog({required this.item});

  @override
  State<_ItemCadastroDialog> createState() => _ItemCadastroDialogState();
}

class _ItemCadastroDialogState extends State<_ItemCadastroDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final AppFormField tituloForm;
  late final TextEditingController _urlController;
  String? _iconeSelecionado;
  bool _ativo = true;
  final ValueNotifier<bool> _salvandoNotifier = ValueNotifier(false);

  bool get _isEditMode => widget.item.id != null && widget.item.id! > 0;

  @override
  void initState() {
    super.initState();
    _ativo = widget.item.ativo ?? true;
    _initForms();
  }

  @override
  void dispose() {
    tituloForm.controller.dispose();
    _urlController.dispose();
    _salvandoNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Material(
        color: ConvertixColors.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _header(),
            Padding(
              padding: const EdgeInsets.all(24),
              child: ValueListenableBuilder<bool>(
                valueListenable: _salvandoNotifier,
                builder: (_, salvando, _) {
                  if (salvando) return _loadingBody();
                  return _formFields();
                },
              ),
            ),
            ValueListenableBuilder<bool>(
              valueListenable: _salvandoNotifier,
              builder: (_, salvando, _) {
                if (salvando) return const SizedBox.shrink();
                return _actionButtons();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _initForms() {
    tituloForm = _buildField(
      hint: 'Título do link',
      icon: Icons.title_outlined,
      validator: (v) => validateNotEmpty(v, 'Título'),
    );
    _urlController = TextEditingController(
      text: dominioParaFormulario(widget.item.url),
    );
    _iconeSelecionado = widget.item.icone;

    tituloForm.controller.text = widget.item.titulo ?? '';
  }

  AppFormField _buildField({
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
  }) {
    return AppFormField(
      context: context,
      width: double.infinity,
      dense: true,
      radius: AppTheme.radiusInput,
      borderColor: ConvertixColors.border,
      hoverBorderColor: ConvertixColors.primary,
      backgroundColor: AppColors.grey100,
      icon: Icon(icon, color: ConvertixColors.primary),
      hint: hint,
      validator: validator,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    _salvandoNotifier.value = true;
    try {
      final item = BioLinkItemModel(
        id: widget.item.id,
        biolinkId: widget.item.biolinkId,
        titulo: tituloForm.value.trim(),
        url: normalizeUrl(_urlController.text),
        icone: _iconeSelecionado,
        ordem: widget.item.ordem ?? 1,
        ativo: _ativo,
      );

      if (_isEditMode) {
        await alterarBioLinkItem(item);
      } else {
        await criarBioLinkItem(item);
      }

      if (!mounted) return;
      showToastSuccess(message: 'Item salvo com sucesso');
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showToastError(
        message: parseApiError(e).mensagem ?? 'Erro ao salvar item',
      );
    } finally {
      if (mounted) _salvandoNotifier.value = false;
    }
  }

  Widget _header() {
    return appDialogHeader(
      title: _isEditMode ? 'Editar item' : 'Novo item',
      icon: _isEditMode ? Icons.edit_outlined : Icons.add_link_outlined,
      onClose: () => Navigator.pop(context),
    );
  }

  Widget _ativoSwitch() {
    return StatefulBuilder(
      builder: (context, setSwitchState) {
        return SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: appText('Ativo', color: ConvertixColors.textPrimary),
          value: _ativo,
          activeThumbColor: ConvertixColors.primary,
          onChanged: (value) => setSwitchState(() => _ativo = value),
        );
      },
    );
  }

  Widget _formFields() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          tituloForm.formulario,
          dominioUrlFormField(
            controller: _urlController,
            width: double.infinity,
          ),
          appSizedBox(height: 10),
          StatefulBuilder(
            builder: (context, setIconState) {
              return BiolinkItemIconeSelector(
                value: _iconeSelecionado,
                onChanged: (value) => setIconState(() => _iconeSelecionado = value),
              );
            },
          ),
          appSizedBox(height: 10),
          _ativoSwitch(),
        ],
      ),
    );
  }

  Widget _loadingBody() {
    return SizedBox(
      height: 200,
      child: Center(child: appLoadingCovertix()),
    );
  }

  Widget _actionButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Row(
        children: [
          Expanded(
            child: appElevatedButtonCovertix(
              title: AppStrings.salvar,
              height: 42,
              onTap: _save,
            ),
          ),
          appSizedBox(width: AppSpacing.normal),
          Expanded(
            child: appElevatedButtonCovertix(
              title: AppStrings.cancelar,
              height: 42,
              primary: false,
              onTap: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
