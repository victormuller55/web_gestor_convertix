import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart';
import 'package:web_gestor_site_covertix/app_config/app_auth.dart';
import 'package:web_gestor_site_covertix/app_config/const/app_theme.dart';
import 'package:web_gestor_site_covertix/app_config/const/covertix_colors.dart';
import 'package:web_gestor_site_covertix/models/dashboard_stats_model.dart';
import 'package:web_gestor_site_covertix/models/usuario_model.dart';
import 'package:web_gestor_site_covertix/pages/menu_admin/inicio/inicio_service.dart';
import 'package:web_gestor_site_covertix/widgets/app_reload_button.dart';

class InicioPage extends StatefulWidget {
  const InicioPage({super.key});

  @override
  State<InicioPage> createState() => _InicioPageState();
}

class _InicioViewData {
  const _InicioViewData({
    required this.usuario,
    required this.isAdmin,
    required this.isLoading,
    required this.stats,
    required this.erro,
  });

  final UsuarioModel? usuario;
  final bool isAdmin;
  final bool isLoading;
  final DashboardStatsModel stats;
  final String? erro;

  static const initial = _InicioViewData(
    usuario: null,
    isAdmin: false,
    isLoading: true,
    stats: DashboardStatsModel.empty,
    erro: null,
  );

  _InicioViewData copyWith({
    UsuarioModel? usuario,
    bool? isAdmin,
    bool? isLoading,
    DashboardStatsModel? stats,
    String? erro,
    bool clearErro = false,
  }) {
    return _InicioViewData(
      usuario: usuario ?? this.usuario,
      isAdmin: isAdmin ?? this.isAdmin,
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      erro: clearErro ? null : (erro ?? this.erro),
    );
  }
}

class _InicioPageState extends State<InicioPage> {
  final ValueNotifier<_InicioViewData> _viewData = ValueNotifier(_InicioViewData.initial);
  final ValueNotifier<bool> _isReloading = ValueNotifier(false);

  @override
  void dispose() {
    _viewData.dispose();
    _isReloading.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    final usuario = await getUsuarioLogado();
    final isAdmin = await isAdminLogado();
    if (!mounted) return;
    _viewData.value = _viewData.value.copyWith(
      usuario: usuario,
      isAdmin: isAdmin,
    );
    await _carregarStats();
  }

  Future<void> _carregarStats({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      _viewData.value = _viewData.value.copyWith(isLoading: true, clearErro: true);
    } else {
      _isReloading.value = true;
      _viewData.value = _viewData.value.copyWith(clearErro: true);
    }

    try {
      final stats = await carregarDashboardStats(forceRefresh: forceRefresh);
      if (!mounted) return;
      _viewData.value = _viewData.value.copyWith(
        stats: stats,
        isLoading: false,
        clearErro: true,
      );
    } catch (_) {
      if (!mounted) return;
      _viewData.value = _viewData.value.copyWith(
        isLoading: false,
        erro: 'Não foi possível carregar os dados do painel.',
      );
    } finally {
      if (mounted) _isReloading.value = false;
    }
  }

  void _onReload() => _carregarStats(forceRefresh: true);

  int _crossAxisCount(double maxWidth) {
    if (maxWidth < 520) return 1;
    if (maxWidth < 900) return 2;
    return 3;
  }

  Widget _statCardIcon(IconData icon) {
    return Icon(icon, color: ConvertixColors.primary, size: 22);
  }

  Widget _statCardValue(String value) {
    return appText(
      value,
      fontSize: AppFontSizes.verySmall,
      bold: true,
      color: ConvertixColors.textPrimary,
    );
  }

  Widget _statCardLabel(String label) {
    return appText(label, color: ConvertixColors.textSecondary);
  }

  Widget _statCard(String label, String value, IconData icon) {
    return appContainer(
      padding: const EdgeInsets.all(20),
      backgroundColor: ConvertixColors.surface,
      radius: BorderRadius.circular(AppTheme.radiusCard),
      border: Border.all(color: ConvertixColors.border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _statCardIcon(icon),
          appSizedBox(height: AppSpacing.normal),
          _statCardValue(value),
          appSizedBox(height: AppSpacing.small),
          _statCardLabel(label),
        ],
      ),
    );
  }

  List<Widget> _cards(_InicioViewData data) {
    final value = data.isLoading ? '…' : null;

    final cards = <Widget>[
      _statCard('Sites', value ?? '${data.stats.totalSites}', Icons.language_outlined),
      _statCard('Sites ativos', value ?? '${data.stats.sitesAtivos}', Icons.check_circle_outline),
      _statCard('BioLinks', value ?? '${data.stats.totalBioLinks}', Icons.link_outlined),
      _statCard('Sites BioLink', value ?? '${data.stats.sitesBioLink}', Icons.hub_outlined),
    ];

    if (data.isAdmin) {
      cards.addAll([
        _statCard('Clientes', value ?? '${data.stats.totalClientes}', Icons.business_outlined),
        _statCard('Usuários', value ?? '${data.stats.totalUsuarios}', Icons.people_outline),
      ]);
    }

    return cards;
  }

  Widget _statsGrid(_InicioViewData data) {
    final cards = _cards(data);

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _crossAxisCount(constraints.maxWidth);

        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: AppSpacing.normal,
          crossAxisSpacing: AppSpacing.normal,
          childAspectRatio: crossAxisCount == 1 ? 3.2 : 1.55,
          children: cards,
        );
      },
    );
  }

  Widget _erroWidget(String erro) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpacing.normal),
      child: appText(erro, color: Colors.red.shade400),
    );
  }

  Widget _welcomeTitle(UsuarioModel? usuario) {
    return appText(
      'Olá, ${usuario?.nome}',
      fontSize: AppFontSizes.medium,
      bold: true,
      color: ConvertixColors.textPrimary,
    );
  }

  Widget _welcomeSubtitle(UsuarioModel? usuario) {
    return appText('Empresa: ${usuario?.nomeEmpresa}', color: ConvertixColors.textSecondary);
  }

  Widget _welcomeSection(_InicioViewData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _welcomeTitle(data.usuario),
        appSizedBox(height: AppSpacing.small),
        _welcomeSubtitle(data.usuario),
        appSizedBox(height: AppSpacing.medium),
      ],
    );
  }

  Widget _bodyContent(_InicioViewData data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _welcomeSection(data),
          if (data.erro != null) _erroWidget(data.erro!),
          _statsGrid(data),
        ],
      ),
    );
  }

  List<Widget> _scaffoldActions() {
    return [
      ValueListenableBuilder<bool>(
        valueListenable: _isReloading,
        builder: (_, loading, __) => AppReloadButton(
          isLoading: loading,
          onPressed: _onReload,
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: 'Início',
      hideBackIcon: true,
      appBarColor: ConvertixColors.surface,
      titleColor: ConvertixColors.textPrimary,
      background: ConvertixColors.background,
      actions: _scaffoldActions(),
      body: ValueListenableBuilder<_InicioViewData>(
        valueListenable: _viewData,
        builder: (_, data, __) => _bodyContent(data),
      ),
    );
  }
}
