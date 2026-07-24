import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/cliente_site_access.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_endpoints.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/app_config/menu_config.dart';
import 'package:web_gestor_site_covertix/models/app_enums.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/login_page/entrar_page.dart';
import 'package:web_gestor_site_covertix/pages/perfil/perfil_page.dart';
import 'package:web_gestor_site_covertix/widgets/app_confirm_dialog.dart';
import 'package:web_gestor_site_covertix/widgets/app_logo.dart';

const double _menuBreakpoint = 900;
const double _menuWidth = 300;

class _MenuItemStyle {
  const _MenuItemStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.indicatorColor,
    required this.borderColor,
  });

  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color indicatorColor;
  final Color borderColor;
}

_MenuItemStyle _resolveMenuItemStyle({
  required bool hover,
  required bool isSelected,
  required bool isLogout,
}) {
  if (isLogout) {
    return _MenuItemStyle(
      backgroundColor: hover ? ConvertixColors.primary.withValues(alpha: 0.15) : Colors.transparent,
      textColor: hover ? ConvertixColors.primary : Colors.red,
      iconColor: hover ? ConvertixColors.primary : Colors.red,
      indicatorColor: Colors.transparent,
      borderColor: Colors.transparent,
    );
  }

  if (isSelected) {
    return _MenuItemStyle(
      backgroundColor: ConvertixColors.primaryDark,
      textColor: ConvertixColors.white,
      iconColor: ConvertixColors.white,
      indicatorColor: ConvertixColors.white,
      borderColor: ConvertixColors.white,
    );
  }

  if (hover) {
    return _MenuItemStyle(
      backgroundColor: ConvertixColors.primary.withValues(alpha: 0.14),
      textColor: ConvertixColors.primary,
      iconColor: ConvertixColors.primary,
      indicatorColor: Colors.transparent,
      borderColor: Colors.transparent,
    );
  }

  return _MenuItemStyle(
    backgroundColor: Colors.transparent,
    textColor: ConvertixColors.textMuted,
    iconColor: ConvertixColors.textMuted,
    indicatorColor: Colors.transparent,
    borderColor: Colors.transparent,
  );
}

class _MenuItemSeparator extends StatelessWidget {
  const _MenuItemSeparator();

  @override
  Widget build(BuildContext context) {
    return _menuItemSeparator();
  }
}

Widget _menuItemSeparator() {
  return appContainer(
    height: 0.5,
    width: double.infinity,
    backgroundColor: ConvertixColors.border,
  );
}

Widget _menuItemIndicator(Color color) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 7, top: 7, left: 10, right: 10),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 4,
      height: 30,
      margin: const EdgeInsets.only(left: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
    ),
  );
}

class _MenuItemBody extends StatelessWidget {
  const _MenuItemBody({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.style,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final _MenuItemStyle style;

  @override
  Widget build(BuildContext context) {
    return _menuItemBody(
      title: title,
      icon: icon,
      isSelected: isSelected,
      style: style,
    );
  }
}

Widget _menuItemBody({
  required String title,
  required IconData icon,
  required bool isSelected,
  required _MenuItemStyle style,
}) {
  return appContainer(
    backgroundColor: style.backgroundColor,
    border: Border.all(color: style.borderColor),
    child: Row(
      children: [
        _menuItemIndicator(style.indicatorColor),
        _menuItemLeadingIcon(style.iconColor, icon),
        appSizedBox(width: AppSpacing.normal),
        Expanded(child: _menuItemTitle(title, style.textColor, isSelected)),
        _menuItemTrailingIcon(style.iconColor),
        appSizedBox(width: AppSpacing.normal),
      ],
    ),
  );
}

Widget _menuItemLeadingIcon(Color color, IconData icon) {
  return Icon(icon, color: color, size: 20);
}

Widget _menuItemTitle(String title, Color color, bool isSelected) {
  return appText(
    title.toUpperCase(),
    color: color,
    fontSize: AppFontSizes.verySmall,
    letterSpacing: 0.15,
    bold: isSelected,
  );
}

Widget _menuItemTrailingIcon(Color color) {
  return Icon(Icons.arrow_forward_ios_outlined, color: color, size: 20);
}

class _MenuSidebarItem extends StatefulWidget {
  const _MenuSidebarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.isLogout,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final bool isSelected;
  final bool isLogout;
  final VoidCallback onTap;

  @override
  State<_MenuSidebarItem> createState() => _MenuSidebarItemState();
}

class _MenuSidebarItemState extends State<_MenuSidebarItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final style = _resolveMenuItemStyle(
      hover: _hover,
      isSelected: widget.isSelected,
      isLogout: widget.isLogout,
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Column(
          children: [
            const _MenuItemSeparator(),
            _MenuItemBody(
              title: widget.title,
              icon: widget.icon,
              isSelected: widget.isSelected,
              style: style,
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatefulWidget {
  const _UserCard({
    required this.label,
    required this.onTap,
    this.fotoUrl,
  });

  final String label;
  final VoidCallback onTap;
  final String? fotoUrl;

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: _userCardContainer(
          hover: _hover,
          child: _userCardRow(
            label: widget.label,
            fotoUrl: widget.fotoUrl,
          ),
        ),
      ),
    );
  }
}

Widget _userCardContainer({required bool hover, required Widget child}) {
  return appContainer(
    padding: EdgeInsets.all(AppSpacing.normal),
    border: Border(bottom: BorderSide(color: ConvertixColors.border)),
    backgroundColor: hover
        ? ConvertixColors.primary.withValues(alpha: 0.08)
        : ConvertixColors.surface,
    child: child,
  );
}

Widget _userCardRow({required String label, String? fotoUrl}) {
  return Row(
    children: [
      _userCardAvatar(fotoUrl),
      appSizedBox(width: AppSpacing.normal),
      Expanded(child: _userCardLabel(label)),
      _userCardArrow(),
    ],
  );
}

Widget _userCardAvatar(String? fotoUrl) {
  if (fotoUrl == null || fotoUrl.isEmpty) {
    return _userCardAvatarFallback();
  }

  return ClipOval(
    child: Image.network(
      fotoUrl,
      width: 34,
      height: 34,
      cacheWidth: 68,
      cacheHeight: 68,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _userCardAvatarFallback(),
    ),
  );
}

Widget _userCardAvatarFallback() {
  return appContainer(
    width: 34,
    height: 34,
    shape: BoxShape.circle,
    backgroundColor: ConvertixColors.primaryLight,
    child: Icon(Icons.person, color: ConvertixColors.primary, size: 20),
  );
}

Widget _userCardLabel(String label) {
  return appText(
    label,
    bold: true,
    color: ConvertixColors.primaryDarker,
    overflow: true,
    fontSize: AppFontSizes.verySmall,
  );
}

Widget _userCardArrow() {
  return Icon(Icons.arrow_forward_ios_outlined, size: 15, color: ConvertixColors.textMuted);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<int> _selectedIndex = ValueNotifier(0);
  final ValueNotifier<UsuarioModel?> _usuarioLogado = ValueNotifier(null);
  final ValueNotifier<bool> _carregando = ValueNotifier(true);
  final ValueNotifier<List<MenuItem>> _menuItems = ValueNotifier(const []);
  final Map<String, Widget> _pageCache = {};

  @override
  void dispose() {
    _selectedIndex.dispose();
    _usuarioLogado.dispose();
    _carregando.dispose();
    _menuItems.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final usuario = await getUsuarioLogado();
    final tipo = await getTipoUsuarioLogado();

    Set<String> tiposSiteCliente = {};
    if (tipo == TipoUsuario.cliente) {
      tiposSiteCliente = await obterTiposSiteDoCliente();
    }

    final itens = MenuConfig.getItensParaUsuario(
      tipo,
      tiposSiteCliente: tiposSiteCliente,
    );

    if (!mounted) return;
    _usuarioLogado.value = usuario;
    _pageCache.clear();
    _menuItems.value = itens;
    _selectedIndex.value = 0;
    _carregando.value = false;
  }

  Future<void> _exitAccount() async {
    final confirmado = await showAppConfirmDialog(
      context,
      title: 'Sair da conta',
      message: 'Deseja realmente sair da sua conta?',
      icon: Icons.logout_rounded,
      confirmLabel: 'Sair',
      destructive: true,
    );
    if (confirmado != true || !mounted) return;

    await clearToken();
    open(screen: const LoginPage(), closePrevious: true);
  }

  Widget _conteudoPaginas() {
    return ValueListenableBuilder<List<MenuItem>>(
      valueListenable: _menuItems,
      builder: (context, items, _) {
        if (items.isEmpty) return const SizedBox.shrink();
        return ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, index, _) {
            if (index < 0 || index >= items.length) {
              return const SizedBox.shrink();
            }
            final item = items[index];
            _pageCache.putIfAbsent(item.id, item.pageBuilder);

            // Mantém só páginas já visitadas (lazy) e preserva o State delas.
            return Stack(
              children: [
                for (final entry in _pageCache.entries)
                  Offstage(
                    offstage: entry.key != item.id,
                    child: TickerMode(
                      enabled: entry.key == item.id,
                      child: entry.value,
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _telaAtual() => _conteudoPaginas();

  bool _useDrawer(BuildContext context) {
    return MediaQuery.of(context).size.width < _menuBreakpoint;
  }

  void _onMenuItemTap({
    required int indexMenu,
    required bool closeDrawerOnTap,
    VoidCallback? onTapOverride,
  }) {
    if (onTapOverride != null) {
      onTapOverride();
    } else {
      _selectedIndex.value = indexMenu;
    }

    if (closeDrawerOnTap && mounted) {
      Navigator.of(context).pop();
    }
  }

  String _userCardLabel(UsuarioModel? usuario) {
    final nome = usuario?.nome ?? 'Usuário';
    final tipo = usuario?.tipo;
    if (tipo == null || tipo.isEmpty) return nome;
    return '$nome ( $tipo )';
  }

  Widget _menuItem({
    required String title,
    required IconData icon,
    required int indexMenu,
    required bool isSelected,
    bool closeDrawerOnTap = false,
    VoidCallback? onTapOverride,
    bool isLogout = false,
  }) {
    return _MenuSidebarItem(
      title: title,
      icon: icon,
      isSelected: isSelected,
      isLogout: isLogout,
      onTap: () => _onMenuItemTap(
        indexMenu: indexMenu,
        closeDrawerOnTap: closeDrawerOnTap,
        onTapOverride: onTapOverride,
      ),
    );
  }

  Future<void> _abrirPerfil() async {
    final usuario = _usuarioLogado.value;
    if (usuario == null) return;

    final atualizado = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _perfilDialog(usuario),
    );

    if (atualizado == true) {
      await _carregarPerfil();
    }
  }

  Widget _userCard() {
    return ValueListenableBuilder<UsuarioModel?>(
      valueListenable: _usuarioLogado,
      builder: (context, usuario, _) {
        if (usuario == null) return const SizedBox.shrink();

        return _UserCard(
          label: _userCardLabel(usuario),
          fotoUrl: fotoUrl(usuario.foto),
          onTap: _abrirPerfil,
        );
      },
    );
  }

  Widget _logoHeader() {
    return appContainer(
      width: double.infinity,
      backgroundColor: ConvertixColors.surface,
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.medium, vertical: AppSpacing.big),
      border: Border(bottom: BorderSide(color: ConvertixColors.border)),
      child: appLogoConvertix(height: 60, alignment: Alignment.center),
    );
  }

  Widget _menuDivider() {
    return appContainer(
      height: 1,
      width: double.infinity,
      backgroundColor: ConvertixColors.border,
    );
  }

  Widget _menuItemsList({required bool closeDrawerOnTap}) {
    return ValueListenableBuilder<List<MenuItem>>(
      valueListenable: _menuItems,
      builder: (context, items, _) {
        return ValueListenableBuilder<int>(
          valueListenable: _selectedIndex,
          builder: (context, selectedIndex, _) {
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                for (var i = 0; i < items.length; i++)
                  _menuItem(
                    title: items[i].title,
                    icon: items[i].icon,
                    indexMenu: i,
                    isSelected: selectedIndex == i,
                    closeDrawerOnTap: closeDrawerOnTap,
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _menuContent({bool closeDrawerOnTap = false}) {
    return appContainer(
      width: _menuWidth,
      backgroundColor: ConvertixColors.menuPanel,
      border: Border(right: BorderSide(color: ConvertixColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _logoHeader(),
          _userCard(),
          appSizedBox(height: AppSpacing.small),
          Expanded(child: _menuItemsList(closeDrawerOnTap: closeDrawerOnTap)),
          _menuDivider(),
          _menuLogoutItem(closeDrawerOnTap: closeDrawerOnTap),
          appSizedBox(height: AppSpacing.normal),
        ],
      ),
    );
  }

  Widget _menuLogoutItem({required bool closeDrawerOnTap}) {
    return _menuItem(
      title: 'Sair da conta',
      icon: Icons.logout_rounded,
      indexMenu: -1,
      isSelected: false,
      isLogout: true,
      closeDrawerOnTap: closeDrawerOnTap,
      onTapOverride: _exitAccount,
    );
  }

  Widget _loadingBody() {
    return appLoading(
      child: CircularProgressIndicator(color: ConvertixColors.primary),
    );
  }

  Widget _desktopBody() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _menuContent(),
        Expanded(child: _conteudoPaginas()),
      ],
    );
  }

  Widget _drawer() {
    return Drawer(
      backgroundColor: ConvertixColors.menuPanel,
      child: _menuContent(closeDrawerOnTap: true),
    );
  }

  Widget _loadingScaffold() {
    return scaffold(
      title: AppStrings.vazio,
      showAppBar: false,
      background: ConvertixColors.background,
      body: _loadingBody(),
    );
  }

  Widget _mainScaffold({required bool useDrawer}) {
    return scaffold(
      title: 'Convertix Gestor',
      showAppBar: useDrawer,
      appBarColor: ConvertixColors.sidebarBackground,
      titleColor: AppColors.white,
      drawerColor: AppColors.white,
      background: ConvertixColors.background,
      drawer: useDrawer ? _drawer() : null,
      body: useDrawer ? _telaAtual() : _desktopBody(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _carregando,
      builder: (context, carregando, _) {
        if (carregando) return _loadingScaffold();
        return _mainScaffold(useDrawer: _useDrawer(context));
      },
    );
  }
}

Widget _perfilDialog(UsuarioModel usuario) {
  return Dialog(
    backgroundColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    child: PerfilPage(usuario: usuario),
  );
}
